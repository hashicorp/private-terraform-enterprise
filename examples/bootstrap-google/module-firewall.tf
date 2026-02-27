module "firewall" {
  source = "./modules/firewall-vpc"
  region = "${var.region}"
  healthchk_ips = "${var.healthchk_ips}"
  subnet_range = "${var.subnet_range}"
  subnet_name = "${var.subnet_name}"
	vpc_name = "${var.vpc_name}"
}
