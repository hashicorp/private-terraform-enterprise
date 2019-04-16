terraform {
  required_version = ">= 0.11.13"
}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_route53_zone" "hashidemos" {
  name = "${var.route53_zone}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars {
    hostname       = "${var.namespace}.hashidemos.io"
    replicated_pwd = ""
  }
}

data "aws_s3_bucket" "source" {
  bucket = "${var.source_bucket_name}"
}

module "pes" {
  source                 = "pes/"
  namespace              = "${var.namespace}"
  aws_instance_ami       = "${var.aws_instance_ami}"
  aws_instance_type      = "${var.aws_instance_type}"
  subnet_ids             = ["${split(",", var.subnet_ids)}"]
  vpc_security_group_ids = "${var.security_group_id}"
  user_data              = "${data.template_file.user_data.rendered}"
  ssh_key_name           = "${var.ssh_key_name}"
  hashidemos_zone_id     = "${data.aws_route53_zone.hashidemos.zone_id}"
  database_name          = "${var.database_name}"
  database_username      = "${var.database_username}"
  database_pwd           = "${var.database_password}"
  owner                  = "${var.owner}"
  ttl                    = "${var.ttl}"
  ssl_certificate_id     = "${var.ssl_certificate_id}"
  source_bucket_id       = "${data.aws_s3_bucket.source.id}"
}
