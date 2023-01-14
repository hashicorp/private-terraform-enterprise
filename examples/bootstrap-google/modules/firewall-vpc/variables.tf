variable "region" {
  type        = "string"
  description = "The region to install into."
}

variable "healthchk_ips" {
  type        = "list"
  description = "List of gcp health check ips to allow through the firewall"
}

variable "vpc_name" {
	type				= "string"
	description	= "VPC name for TFE"
}

variable "subnet_name" {
	type				= "string"
	description	= "Subnet name for TFE VPC"
}

variable "subnet_range" {
  type        = "string"
  description = "CIDR range for subnet"
}
