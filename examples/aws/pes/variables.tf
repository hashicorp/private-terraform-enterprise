variable "namespace" {}
variable "aws_instance_ami" {}
variable "aws_instance_type" {}
variable "ssh_key_name" {}
variable "owner" {}
variable "ttl" {}
variable "user_data" {}
variable "subnet_ids" {
  type = "list"
}
variable "vpc_security_group_ids" {}
variable "hashidemos_zone_id" {}
variable "database_name" {}
variable "database_username" {}
variable "database_pwd" {}
variable "ssl_certificate_id" {}
variable "source_bucket_id" {}
