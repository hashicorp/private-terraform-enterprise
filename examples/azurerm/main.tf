terraform {
  required_version = ">= 0.10.3"
}

provider "azurerm" {}

#------------------------------------------------------------------------------
# network 
#------------------------------------------------------------------------------

module "network" {
  source           = "network/"
  namespace        = "${var.namespace}"
  main_location    = "${var.main_location}"
  standby_location = "${var.standby_location}"
}

module "pes" {
  source            = "pes/"
  namespace         = "${var.namespace}"
  main_location     = "${var.main_location}"
  main_rg_name      = "${module.network.main_rg_name}"
  main_subnet_id    = "${module.network.main_subnet_id}"
  standby_location  = "${var.standby_location}"
  standby_rg_name   = "${module.network.standby_rg_name}"
  standby_subnet_id = "${module.network.standby_subnet_id}"
}
