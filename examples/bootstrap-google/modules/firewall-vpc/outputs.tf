output "vpc" {
  value = "${google_compute_network.ptfe_vpc.name}"
}

output "ptfe_subnet" {
  value = "${google_compute_subnetwork.ptfe_subnet.name}"
}

output "ptfe_firewall" {
  value = "${google_compute_firewall.ptfe.name}"
}

output "ptfe_healthchk_firewall" {
  value = "${google_compute_firewall.lb-healthchecks.name}"
}