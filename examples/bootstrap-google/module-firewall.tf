module "firewall" {
  source = "modules/firewall-vpc"
  region = "${var.region}"
  healthchk_ips = "${var.healthchk_ips}"
  subnet_range = "${var.subnet_range}"
}
