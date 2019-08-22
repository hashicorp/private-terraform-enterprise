output "frontend_ip" {
  value = "${google_compute_global_address.frontend_ip.address}"
}

output "cert" {
  value = "${google_compute_managed_ssl_certificate.frontendcert.self_link}"
}

output "dns_entry" {
  value = "${var.frontenddns}.${data.google_dns_managed_zone.dnszone.dns_name}"
}