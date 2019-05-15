variable "aws_region" {
  description = "AWS region"
}

variable "namespace" {
  description = "Unique name to use for DNS and resource naming"
}

variable "bucket_name" {
   description = "Name of the PTFE source bucket to create"
}

variable "cidr_block" {
  description = "CIDR block to use for VPC"
  default = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "number of subnets to create"
  default = "2"
}
