terraform {
  required_version = ">= 0.10.3"
}

provider "aws" {
  region = "${var.aws_region}"
}

data "aws_route53_zone" "hashidemos" {
  name = "${var.dns_zone}."
}

#------------------------------------------------------------------------------
# instance user data 
#------------------------------------------------------------------------------

resource "random_pet" "replicated-pwd" {
  length = 2
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars {
    hostname         = "${var.namespace}.hashidemos.io"
    replicated_pwd   = "${random_pet.replicated-pwd.id}"
    pg_password      = "<postgres_password>"
    s3_region        = "eu-west-1"
    s3_bucket        = "<s3_bucket_name>"
    pg_netloc        = "${module.pes.endpoint}"
    console_password = "<console_password>"
  }
}

#------------------------------------------------------------------------------
# network 
#------------------------------------------------------------------------------

module "network" {
  source    = "network/"
  namespace = "${var.namespace}"
}

#------------------------------------------------------------------------------
# alb
#------------------------------------------------------------------------------

module "alb" {
  source       = "alb/"
  namespace    = "${var.namespace}"
  vpc_id       = "${module.network.vpc_id}"
  instance_ids = "${module.pes.instance_ids}"
  dns_zone     = "${var.dns_zone}"
  subnet_ids   = "${module.network.subnet_ids}"
  sg_ids       = "${module.network.security_group_id}"
}

#------------------------------------------------------------------------------
# demo/poc ptfe 
#------------------------------------------------------------------------------

module "demo" {
  source                 = "demo/"
  namespace              = "${var.namespace}"
  aws_instance_ami       = "${var.aws_instance_ami}"
  aws_instance_type      = "${var.aws_instance_type}"
  subnet_id              = "${module.network.subnet_ids[0]}"
  vpc_security_group_ids = "${module.network.security_group_id}"
  user_data              = ""
  ssh_key_name           = "${var.ssh_key_name}"
  hashidemos_zone_id     = "${data.aws_route53_zone.hashidemos.zone_id}"
  owner                  = "${var.owner}"
  ttl                    = "${var.ttl}"
}

#------------------------------------------------------------------------------
# production mounted disk ptfe 
#------------------------------------------------------------------------------

module "pmd" {
  source                 = "pmd/"
  namespace              = "${var.namespace}"
  aws_instance_ami       = "${var.aws_instance_ami}"
  aws_instance_type      = "${var.aws_instance_type}"
  subnet_id              = "${module.network.subnet_ids[0]}"
  vpc_security_group_ids = "${module.network.security_group_id}"
  user_data              = ""
  ssh_key_name           = "${var.ssh_key_name}"
  hashidemos_zone_id     = "${data.aws_route53_zone.hashidemos.zone_id}"
  owner                  = "${var.owner}"
  ttl                    = "${var.ttl}"
}

#------------------------------------------------------------------------------
# production external-services ptfe 
#------------------------------------------------------------------------------

module "pes" {
  source                 = "pes/"
  namespace              = "${var.namespace}"
  aws_instance_count     = "1"
  aws_instance_ami       = "${var.aws_instance_ami}"
  aws_instance_type      = "${var.aws_instance_type}"
  subnet_ids             = "${module.network.subnet_ids}"
  vpc_security_group_ids = "${module.network.security_group_id}"
  user_data              = "${data.template_file.user_data.rendered}"
  ssh_key_name           = "${var.ssh_key_name}"
  hashidemos_zone_id     = "${data.aws_route53_zone.hashidemos.zone_id}"
  database_pwd           = "${random_pet.replicated-pwd.id}"
  db_subnet_group_name   = "${module.network.db_subnet_group_id}"
  owner                  = "${var.owner}"
  ttl                    = "${var.ttl}"
}
