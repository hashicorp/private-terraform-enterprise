variable "region" {
  type        = "string"
  description = "The region to install into."
  default     = "us-central1"
}

variable "project" {
  type        = "string"
  description = "Name of the project to deploy into"
}

variable "creds" {
  type        = "string"
  description = "Name of credential file"
}

variable "primaryhostname" {
  type        = "string"
  description = "hostname prefix"
  default     = "ptfe-primary"
}

variable "domain" {
  type        = "string"
  description = "domain name"
}

variable "dnszone" {
  type        = "string"
  description = "Managed DNZ Zone name"
}

variable "frontenddns" {
  type        = "string"
  description = "DNS name for load balancer"
  default     = "ptfe"
}

variable "zone" {
  type        = "string"
  description = "Preferred zone"
  default     = "us-central1-a"
}

variable "healthchk_ips" {
  type        = "list"
  description = "List of gcp health check ips to allow through the firewall"
  default     = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22", "130.211.0.0/22"]
}

variable "subnet_name" {
	type				= "string"
	description = "subnet name for VPC creation"
	default			= "tfe_subnet"
}

variable "vpc_name" {
	type				= "string"
	description = "VPC name for TFE VPC"
	default			= "tfe_vpc"
}

variable "subnet_range" {
  type        = "string"
  description = "CIDR range for subnet"
  default     = "10.1.0.0/16"
}
