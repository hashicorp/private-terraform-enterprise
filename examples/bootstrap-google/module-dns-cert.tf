module "dns-cert" {
  source   = "./modules/dns-cert"
  domain   = "${var.domain}"
  zone     = "${var.zone}"
  dnszone  = "${var.dnszone}"
  frontenddns = "${var.frontenddns}"
}
