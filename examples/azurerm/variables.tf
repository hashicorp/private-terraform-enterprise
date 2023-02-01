# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "namespace" {
  description = "Unique name to use for resource naming"
}

variable "main_location" {
  description = "Location to create main resources in"
}

variable "standby_location" {
  description = "Location to create standby resources in"
}
