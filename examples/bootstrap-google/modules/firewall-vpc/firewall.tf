resource "google_compute_firewall" "ptfe" {
  name    = "ptfe-firewall"
  network = "${google_compute_network.ptfe_vpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "6443", "8800", "23010"]
  }
}

resource "google_compute_firewall" "lb-healthchecks" {
  name          = "lb-healthcheck-firewall"
  network       = "${google_compute_network.ptfe_vpc.name}"
  source_ranges = "${var.healthchk_ips}"

  allow {
    protocol = "tcp"
  }
} 
