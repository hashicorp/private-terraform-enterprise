# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

module "dns-cert" {
  source   = "modules/dns-cert"
  domain   = "${var.domain}"
  zone     = "${var.zone}"
  dnszone  = "${var.dnszone}"
  frontenddns = "${var.frontenddns}"
}
