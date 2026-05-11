# Copyright IBM Corp. 2018, 2026

module "dns-cert" {
  source   = "modules/dns-cert"
  domain   = "${var.domain}"
  zone     = "${var.zone}"
  dnszone  = "${var.dnszone}"
  frontenddns = "${var.frontenddns}"
}
