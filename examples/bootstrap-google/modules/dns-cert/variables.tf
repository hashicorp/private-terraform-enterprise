# Copyright IBM Corp. 2018, 2026

variable "domain" {
  type        = "string"
  description = "Domain name for PTFE server"
}

variable "zone" {
  type        = "string"
  description = "Preferred zone"
}

variable "dnszone" {
  type        = "string"
  description = "name of the managed dns zone"
}

variable "frontenddns" {
  type        = "string"
  description = "DNS name for load balancer"
}