# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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