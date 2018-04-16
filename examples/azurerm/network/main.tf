locals {
  main_namespace    = "${var.namespace}-main"
  standby_namespace = "${var.namespace}-standby"
}

#------------------------------------------------------------------------------
# resource groups
#------------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = "${local.main_namespace}-rg"
  location = "${var.main_location}"
}

resource "azurerm_resource_group" "standby" {
  name     = "${local.standby_namespace}-rg"
  location = "${var.standby_location}"
}

#------------------------------------------------------------------------------
# virtual networks / subnets
#------------------------------------------------------------------------------

resource "azurerm_virtual_network" "main" {
  name                = "${local.main_namespace}-virtual_network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"

  subnet {
    name           = "${local.main_namespace}-subnet"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_virtual_network" "standby" {
  name                = "${local.standby_namespace}-virtual_network"
  address_space       = ["11.0.0.0/16"]
  location            = "${azurerm_resource_group.standby.location}"
  resource_group_name = "${azurerm_resource_group.standby.name}"

  subnet {
    name           = "${local.standby_namespace}-subnet"
    address_prefix = "11.0.1.0/24"
  }
}

data "azurerm_subnet" "main" {
  name                 = "${local.main_namespace}-subnet"
  virtual_network_name = "${local.main_namespace}-virtual_network"
  resource_group_name  = "${local.main_namespace}-rg"
}

data "azurerm_subnet" "standby" {
  name                 = "${local.standby_namespace}-subnet"
  virtual_network_name = "${local.standby_namespace}-virtual_network"
  resource_group_name  = "${local.standby_namespace}-rg"
}
