# Copyright IBM Corp. 2018, 2026

provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file("${var.creds}")}"
}

provider "google-beta" {
  project     = "${var.project}"
  region      = "${var.region}"
  credentials = "${file("${var.creds}")}"
}