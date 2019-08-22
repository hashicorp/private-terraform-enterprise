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
  description                 = "Allow ssh access for debugging."
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "${var.address_space_allowlist}"
  destination_address_prefix  = "*"
  source_port_range           = "*"
  destination_port_range      = "22"
  priority                    = 100
}

resource "azurerm_network_security_rule" "allow_http" {
  name                        = "${local.prefix}-http"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"
  description                 = "Allow http traffic for health checks."
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "${var.address_space_allowlist}"
  destination_address_prefix  = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  priority                    = 110
}

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "${local.prefix}-https"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"
  description                 = "Allow https traffic"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "${var.address_space_allowlist}"
  destination_address_prefix  = "*"
  source_port_range           = "*"
  destination_port_range      = "443"
  priority                    = 120
}

resource "azurerm_network_security_rule" "allow_installer_dashboard" {
  name                        = "${local.prefix}-dash"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"
  description                 = "Allow access to the installer dashboard."
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "${var.address_space_allowlist}"
  destination_address_prefix  = "*"
  source_port_range           = "*"
  destination_port_range      = "8800"
  priority                    = 130
}

resource "azurerm_network_security_rule" "allow_cluster" {
  name                        = "${local.prefix}-cluster"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"
  description                 = "Allow cluster traffic to the load balancer"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "${var.address_space_allowlist}"
  destination_address_prefix  = "*"
  source_port_range           = "*"
  destination_port_range      = "6443"
  priority                    = 140
}

resource "azurerm_network_security_rule" "allow_assistant" {
  name                        = "${local.prefix}-assist"
  resource_group_name         = "${azurerm_resource_group.new.name}"
  network_security_group_name = "${azurerm_network_security_group.new.name}"
  description                 = "Allow traffic to the assistant application"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "${var.address_space_allowlist}"
  destination_address_prefix  = "*"
  source_port_range           = "*"
  destination_port_range      = "23010"
  priority                    = 150
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = "${azurerm_subnet.new.id}"
  network_security_group_id = "${azurerm_network_security_group.new.id}"
}
