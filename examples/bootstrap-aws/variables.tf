variable "cidr_block" {
  description = "CIDR block range to use for the network."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block range to use for the public subnet."
  default     = "10.0.0.0/17"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block range to use for the private subnet."
  default     = "10.0.128.0/17"
}

variable "additional_tags" {
  type        = "map"
  description = "A map of additional tags to attach to all resources created."
  default     = {}
}

variable "availability_zones" {
  description = "List of the Availability zones to use."
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "domain_name" {
  description = "The domain to create a route53 zone for. (eg. `tfe.example.com`), will not create if left empty."
  default     = ""
}

variable "prefix" {
  description = "The prefix to use on all resources, will generate one if not set."
  default     = ""
}

locals {
  prefix = "${element(coalescelist(list(var.prefix), random_pet.prefix.*.id), 0)}"
  tags   = "${merge(local.default_tags, var.additional_tags)}"

  default_tags = {
    Application = "Terraform Enterprise"
    Environment = "Beta-Testing"
  }
}
