variable "namespace" {}
variable "subnet_ids" {
  type = "list"
}
variable "vpc_security_group_ids" {}
variable "database_name" {}
variable "database_username" {}
variable "database_pwd" {}
variable "database_storage" {}
variable "database_instance_class" {}
variable "database_multi_az" {}
