resource "google_compute_network" "ptfe_vpc" {
  name                    = "${var.vpc_name}"
  description             = "TFE VPC Network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ptfe_subnet" {
  name          = "${var.subnet_name}"
  ip_cidr_range = "${var.subnet_range}"
  region        = "${var.region}"
  network       = "${google_compute_network.ptfe_vpc.self_link}"
}
