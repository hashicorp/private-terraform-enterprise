resource "random_pet" "prefix" {
  count     = "${var.prefix != "" ? 0 : 1}"
  prefix    = "tfe"
  length    = 1
  seperator = "-"
}

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

resource "azurerm_network_security_group" "new" {
  name                = "${local.prefix}-nsg"
  resource_group_name = "${azurerm_resource_group.new.name}"
  location            = "${var.location}"
  tags                = "${local.tags}"
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "${local.prefix}-ssh"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"

  description                = "Allow ssh access for debugging."
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "${var.address_space_allowlist}"
  destination_address_prefix = "*"
  source_port_range          = "*"
  destination_port_range     = "22"
  priority                   = 100
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "${local.prefix}-http"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"

  description                = "Allow http traffic for health checks."
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "${var.address_space_allowlist}"
  destination_address_prefix = "*"
  source_port_range          = "*"
  destination_port_range     = "80"
  priority                   = 110
}

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "${local.prefix}-https"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"

  description                = "Allow https traffic"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "${var.address_space_allowlist}"
  destination_address_prefix = "*"
  source_port_range          = "*"
  destination_port_range     = "443"
  priority                   = 120
}

resource "azurerm_network_security_rule" "allow_installer_dashboard" {
  name                        = "${local.prefix}-dash"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"

  description                = "Allow access to the installer dashboard."
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "${var.address_space_allowlist}"
  destination_address_prefix = "*"
  source_port_range          = "*"
  destination_port_range     = "8800"
  priority                   = 130
}

resource "azurerm_network_security_rule" "allow_cluster" {
  name                        = "${local.prefix}-cluster"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"

  description                = "Allow cluster traffic to the load balancer"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "${var.address_space_allowlist}"
  destination_address_prefix = "*"
  source_port_range          = "*"
  destination_port_range     = "6443"
  priority                   = 140
}

resource "azurerm_network_security_rule" "allow_assistant" {
  name                        = "${local.prefix}-assist"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"

  description                = "Allow traffic to the assistant application"
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = "${var.address_space_allowlist}"
  destination_address_prefix = "*"
  source_port_range          = "*"
  destination_port_range     = "23010"
  priority                   = 150
}

resource "azurerm_key_vault" "new" {
  name                = "${local.prefix}"
  resource_group_name = "${azurerm_resource_group.new.name}"
  location            = "${var.location}"
  sku_name            = "standard"
  tenant_id           = "${var.key_vault_tenant_id}"
  tags                = "${local.tags}"

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_access_policy" "new" {
  key_vault_id = "${azurerm_key_vault.new.id}"
  tenent_id    = "${var.key_vault_tenant_id}"
  object_id    = "${var.key_vault_object_id}"

  certificate_permissions = [
    "get",
    "list",
    "create",
    "delete",
    "update",
  ]

  key_permissions = [
    "get",
    "list",
    "create",
    "update",
  ]

  secret_permissions = [
    "get",
    "list",
    "set",
    "update",
  ]
}
