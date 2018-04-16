#------------------------------------------------------------------------------
# production mounted disk ptfe resources
#------------------------------------------------------------------------------

locals {
  namespace = "${var.namespace}-pmd"
}

resource "aws_instance" "pmd" {
  ami                    = "${var.aws_instance_ami}"
  instance_type          = "${var.aws_instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  key_name               = "${var.ssh_key_name}"
  user_data              = "${var.user_data}"

  root_block_device {
    volume_size = 80
    volume_type = "gp2"
  }

  tags {
    Name  = "${local.namespace}-instance"
    owner = "${var.owner}"
    TTL   = "${var.ttl}"
  }
}

resource "aws_eip" "pmd" {
  instance = "${aws_instance.pmd.id}"
  vpc      = true
}

resource "aws_route53_record" "pmd" {
  zone_id = "${var.hashidemos_zone_id}"
  name    = "${local.namespace}.hashidemos.io."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.pmd.public_ip}"]
}

resource "aws_ebs_volume" "pmd" {
  availability_zone = "${aws_instance.pmd.availability_zone}"
  size              = 88
  type              = "gp2"

  tags {
    Name = "${local.namespace}-ebs_volume"
  }
}

resource "aws_volume_attachment" "pmd" {
  device_name = "/dev/xvdb"
  instance_id = "${aws_instance.pmd.id}"
  volume_id   = "${aws_ebs_volume.pmd.id}"
}
