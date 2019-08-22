variable "prefix" {
  description = "The prefix to use on all resources, will generate one if not set."
  default     = ""
}

variable "location" {
  description = "The Azure location to build resources in."
  default     = "Central US"
}

variable "address_space" {
  description = "CIDR block range to use for the network."
  default     = "10.0.0.0/16"
}

variable "subnet_address_space" {
  description = "CIDR block range to use for the subnet if a subset of `address_space`. Defaults to `address_space`"
  default     = ""
}

variable "additional_tags" {
  type        = "map"
  description = "A map of additional tags to attach to all resources created."
  default     = {}
}

variable "address_space_allowlist" {
  description = "CIDR block range to use to allow traffic from"
  default     = "*"
}

variable "key_vault_tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault."
}

variable "key_vault_object_id" {
  description = "The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault."
}

locals {
  prefix               = "${element(coalescelist(random_pet.prefix.*.id, list(var.prefix)), 0)}"
  rendered_subnet_cidr = "${coalesce(var.subnet_address_space, var.address_space)}"

  default_tags = {
    Application = "Terraform Enterprise"
    Environment = "Beta-Testing"
  }

  tags = "${merge(local.default_tags, var.additional_tags)}"
}

resource "random_pet" "prefix" {
  count     = "${var.prefix == "" ? 1 : 0}"
  prefix    = "tfe"
  length    = 1
  separator = "-"
}
