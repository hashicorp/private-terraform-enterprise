resource "azurerm_resource_group" "new" {
  name     = "${local.prefix}-rg"
  location = "${var.location}"
  tags     = "${local.tags}"
}

resource "azurerm_virtual_network" "new" {
  name                = "${local.prefix}-vnet"
  resource_group_name = "${azurerm_resource_group.new.name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  tags                = "${local.tags}"
}

resource "azurerm_subnet" "new" {
  name                 = "${local.prefix}-subnet"
  resource_group_name  = "${azurerm_resource_group.new.name}"
  virtual_network_name = "${azurerm_virtual_network.new.name}"
  address_prefix       = "${local.rendered_subnet_cidr}"

  service_endpoints = [
    "Microsoft.KeyVault",
  ]
}
