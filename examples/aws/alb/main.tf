data "aws_acm_certificate" "tfe" {
  domain = "*.${var.dns_zone}"
}

data "aws_route53_zone" "zone" {
  name         = "${var.dns_zone}."
  private_zone = false
}

resource "aws_route53_record" "tfe" {
  name    = "${var.namespace}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.zone.id}"

  alias {
    name                   = "${aws_alb.tfe-alb.dns_name}"
    zone_id                = "${aws_alb.tfe-alb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_alb" "tfe-alb" {
  name                       = "${var.namespace}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${var.sg_ids}"]
  subnets                    = ["${var.subnet_ids}"]
  enable_deletion_protection = false

  tags = {
    Environment = "production"
    Name        = "${var.namespace}-alb"
  }
}

resource "aws_alb_target_group" "tfe" {
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 600
  }

  health_check {
    interval            = 5
    timeout             = 3
    path                = "/_health_check"
    protocol            = "HTTPS"
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 3
    port                = "traffic-port"
  }
}

resource "aws_alb_target_group" "tfe_dashboard" {
  port        = 8800
  protocol    = "HTTPS"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 600
  }

  health_check {
    interval            = 5
    timeout             = 3
    path                = "/_health_check"
    protocol            = "HTTPS"
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 3
    port                = 443
  }
}

resource "aws_lb_target_group_attachment" "tfe" {
  target_group_arn = "${aws_alb_target_group.tfe.arn}"
  target_id        = "${element(var.instance_ids, 0)}"
  port             = 443
}

resource "aws_lb_target_group_attachment" "tfe_dashboard" {
  target_group_arn = "${aws_alb_target_group.tfe_dashboard.arn}"
  target_id        = "${element(var.instance_ids, 0)}"
  port             = 8800
}

resource "aws_alb_listener" "tfe_https_app" {
  load_balancer_arn = "${aws_alb.tfe-alb.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.tfe.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tfe.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "tfe_https_dashboard" {
  load_balancer_arn = "${aws_alb.tfe-alb.id}"
  port              = "8800"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${data.aws_acm_certificate.tfe.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tfe_dashboard.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "tfe_redirect_to_https" {
  load_balancer_arn = "${aws_alb.tfe-alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}
