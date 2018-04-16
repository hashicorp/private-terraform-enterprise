variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
variable "dc_name" {}

# Comment this line out if you use datastore clusters
variable "datastore_name" {}

# If you use datastore clusters (RDS) please use this variable instaed of datastore_name
#variable "datastore_cluster_name" {}

variable "resourcepool_name" {}
variable "network_name" {}
variable "template_name" {}
variable "hostname" {}
variable "domain" {}
variable "ipaddress" {}
variable "netmask" {}
variable "gateway" {}

variable "dns" {
  type = "list"
}

variable "ssh_password" {}
variable "json_location" {}
variable "replicated_conf" {}
variable "license" {}
