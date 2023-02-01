# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  type        = "string"
  description = "The region to install into."
}

variable "healthchk_ips" {
  type        = "list"
  description = "List of gcp health check ips to allow through the firewall"
}

variable "subnet_range" {
  type        = "string"
  description = "CIDR range for subnet"
}