# PTFE Production External Services Module

### EC2 instances
resource "aws_instance" "primary" {
  count                  = 1
  ami                    = "${var.aws_instance_ami}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  key_name               = "${var.ssh_key_name}"
  user_data              = "${var.user_data}"
  iam_instance_profile   = "${aws_iam_instance_profile.ptfe.name}"

  root_block_device {
    volume_size = 80
    volume_type = "gp2"
  }

  tags {
    Name  = "${var.namespace}-instance-1"
    owner = "${var.owner}"
    TTL   = "${var.ttl}"
  }
}

resource "null_resource" "delay_secondary" {
  count = "${var.create_second_instance}"
  provisioner "local-exec" {
    command = "sleep 300"
  }

  depends_on = ["aws_instance.primary"]
}

resource "aws_instance" "secondary" {
  count                  = "${var.create_second_instance}"
  ami                    = "${var.aws_instance_ami}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${element(var.subnet_ids, count.index)}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  key_name               = "${var.ssh_key_name}"
  user_data              = "${var.user_data}"
  iam_instance_profile   = "${aws_iam_instance_profile.ptfe.name}"

  root_block_device {
    volume_size = 80
    volume_type = "gp2"
  }

  tags {
    Name  = "${var.namespace}-instance-2"
    owner = "${var.owner}"
    TTL   = "${var.ttl}"
  }

  depends_on = ["null_resource.delay_secondary"]
}

### Routing resources

# Always create a certificate, but use fake domain if
# var.ssl_certificate_arn not blank.
# This is needed to enable conditional in listeners
# Since conditionals in TF 0.11 evaluate both possibilities
resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.ssl_certificate_arn == "" ? var.hostname : format("fake-%s", var.hostname)}"
  validation_method = "DNS"
}

# This allows ACM to validate the new certificate
resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

# This allows ACM to validate the new certificate
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_route53_record" "pes" {
  zone_id = "${var.zone_id}"
  name    = "${var.hostname}"
  type    = "A"

  alias {
    name    = "${aws_lb.ptfe.dns_name}"
    zone_id = "${aws_lb.ptfe.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_lb" "ptfe" {
  name               = "${var.namespace}-alb"
  internal           = "${var.alb_internal}"
  load_balancer_type = "application"
  security_groups    = ["${var.vpc_security_group_ids}"]
  subnets            = ["${var.subnet_ids}"]

  tags {
    owner = "${var.owner}"
  }

}

resource "aws_lb_target_group" "ptfe_443" {
  name               = "${var.namespace}-alb-tg-443"
  port               = 443
  protocol           = "HTTPS"
  vpc_id             = "${var.vpc_id}"
  target_type        = "instance"

  health_check {
    path      = "/app"
    protocol  = "HTTPS"
    matcher   = "200"
  }

  tags {
    owner = "${var.owner}"
  }
}

resource "aws_lb_target_group" "ptfe_8800" {
  name               = "${var.namespace}-alb-tg-8800"
  port               = 8800
  protocol           = "HTTPS"
  vpc_id             = "${var.vpc_id}"
  target_type        = "instance"

  health_check {
  path      = "/_health_check"
  protocol  = "HTTPS"
  matcher   = "200"
  }

  tags {
    owner = "${var.owner}"
  }
}

resource "aws_lb_listener" "ptfe-443" {
  load_balancer_arn   = "${aws_lb.ptfe.arn}"
  port                = "443"
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2016-08"
  certificate_arn     = "${var.ssl_certificate_arn == "" ? aws_acm_certificate.cert.arn : var.ssl_certificate_arn}"

  default_action {
    type              = "forward"
    target_group_arn  = "${aws_lb_target_group.ptfe_443.arn}"
  }

  depends_on = ["aws_acm_certificate_validation.cert"]

}

resource "aws_lb_listener" "ptfe-8800" {
  load_balancer_arn   = "${aws_lb.ptfe.arn}"
  port                = "8800"
  protocol            = "HTTPS"
  ssl_policy          = "ELBSecurityPolicy-2016-08"
  certificate_arn     = "${var.ssl_certificate_arn == "" ? aws_acm_certificate.cert.arn : var.ssl_certificate_arn}"

  default_action {
    type              = "forward"
    target_group_arn  = "${aws_lb_target_group.ptfe_8800.arn}"
  }

  depends_on = ["aws_acm_certificate_validation.cert"]

}

resource "aws_lb_target_group_attachment" "ptfe_443" {
  target_group_arn    = "${aws_lb_target_group.ptfe_443.arn}"
  target_id           = "${aws_instance.primary.id}"
  port                = 443
}

resource "aws_lb_target_group_attachment" "ptfe_8800" {
  target_group_arn    = "${aws_lb_target_group.ptfe_8800.arn}"
  target_id           = "${aws_instance.primary.id}"
  port                = 8800
}

### S3 bucket resorces

data "aws_kms_key" "s3" {
  key_id = "${var.kms_key_id}"
}

resource "aws_s3_bucket" "pes" {
  bucket        = "${var.ptfe_bucket_name}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${data.aws_kms_key.s3.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags {
    Name = "${var.ptfe_bucket_name}"
  }

}

# IAM resources

resource "aws_iam_role" "ptfe" {
  name = "${var.namespace}-iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ptfe" {
  name = "${var.namespace}-iam_instance_profile"
  role = "${aws_iam_role.ptfe.name}"
}

data "aws_iam_policy_document" "ptfe" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.pes.id}",
      "arn:aws:s3:::${aws_s3_bucket.pes.id}/*",
      "arn:aws:s3:::${var.source_bucket_id}",
      "arn:aws:s3:::${var.source_bucket_id}/*",
    ]

    actions = [
      "s3:*",
    ]
  }

  statement {
    sid    = "AllowKMS"
    effect = "Allow"

    resources = [
      "${data.aws_kms_key.s3.arn}",
    ]

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
    ]
  }
}

resource "aws_iam_role_policy" "ptfe" {
  name   = "${var.namespace}-iam_role_policy"
  role   = "${aws_iam_role.ptfe.name}"
  policy = "${data.aws_iam_policy_document.ptfe.json}"
}
