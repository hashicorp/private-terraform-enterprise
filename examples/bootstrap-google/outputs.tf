output "vpc" {
  value = "${module.firewall.vpc}"
}

output "subnet" {
  value = "${module.firewall.ptfe_subnet}"
}

output "ptfe_firewall" {
  value = "${module.firewall.ptfe_firewall}"
}

output "healthcheck_firewall" {
  value = "${module.firewall.ptfe_healthchk_firewall}"
}

output "FrondEnd_IP" {
  value = "${module.dns-cert.frontend_ip}"
}

output "DNS_Entry" {
  value = "${module.dns-cert.dns_entry}"
}

output "Certificate" {
  value = "${module.dns-cert.cert}"
}
