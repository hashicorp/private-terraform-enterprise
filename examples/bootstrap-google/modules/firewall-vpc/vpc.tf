# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "google_compute_network" "ptfe_vpc" {
  name                    = "ptfevpc"
  description             = "PTFE VPC Network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ptfe_subnet" {
  name          = "ptfe-subnet"
  ip_cidr_range = "${var.subnet_range}"
  region        = "${var.region}"
  network       = "${google_compute_network.ptfe_vpc.self_link}"
}
