variable "aws_region" {
  description = "AWS region"
}

variable "namespace" {
  description = "Unique name to use for DNS and resource naming"
}

variable "aws_instance_ami" {
  description = "Amazon Machine Image ID"
}

variable "aws_instance_type" {
  description = "EC2 instance type"
}

variable "ssh_key_name" {
  description = "AWS key pair name to install on the EC2 instance"
}

variable "owner" {
  description = "EC2 instance owner"
}

variable "ttl" {
  description = "EC2 instance TTL"
  default     = "168"
}

variable "ssl_certificate_id" {
  description = "ARN of an SSL certificate uploaded to IAM or AWS Certificate Manager for use with PTFE ELB"
}

variable "route53_zone" {
  description = "name of Route53 zone to use"
  default = "hashidemos.io"
}
