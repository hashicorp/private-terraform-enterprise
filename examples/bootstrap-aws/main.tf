resource "random_pet" "prefix" {
  count     = "${var.prefix != "" ? 0 : 1}"
  prefix    = "tfe"
  length    = 1
  separator = "-"
}

module "new_vpc" {
  # 2.X.X versions of this module are for 0.12+ terraform
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.67.0"

  name                = "${local.prefix}-vpc"
  cidr                = "${var.cidr_block}"
  azs                 = ["${var.availability_zones}"]
  private_subnets     = ["${var.private_subnet_cidr_block}"]
  public_subnets      = ["${var.public_subnet_cidr_block}"]
  default_vpc_tags    = "${local.tags}"
  private_subnet_tags = "${local.tags}"
  public_subnet_tags  = "${local.tags}"
  enable_nat_gateway  = true
}

resource "aws_route53_zone" "new" {
  count = "${var.domain_name == "" ? 0 : 1}"
  name  = "${var.domain_name}"
  tags  = "${local.tags}"
}
