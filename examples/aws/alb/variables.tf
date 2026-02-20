variable "vpc_id" {}
variable "namespace" {}

variable "sg_ids" {
  type = "list"
}

variable "subnet_ids" {
  type = "list"
}

variable "dns_zone" {}
variable "instance_ids" {}
