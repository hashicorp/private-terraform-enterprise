locals {
  namespace         = "${var.namespace}-pes"
  main_namespace    = "${local.namespace}-main"
  standby_namespace = "${local.namespace}-standby"
  namespaces        = "${list(local.main_namespace, local.standby_namespace)}"
}

#------------------------------------------------------------------------------
# traffic manager
#------------------------------------------------------------------------------

resource "azurerm_resource_group" "traffic_manager" {
  name     = "${local.namespace}-traffic-manager-rg"
  location = "${var.main_location}"
}

resource "azurerm_traffic_manager_profile" "ptfe" {
  name                = "${local.namespace}-traffic-manager-profile"
  resource_group_name = "${azurerm_resource_group.traffic_manager.name}"

  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "${local.namespace}"
    ttl           = 100
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "main" {
  name                = "${local.main_namespace}-traffic-manager-endpoint"
  resource_group_name = "${azurerm_resource_group.traffic_manager.name}"
  profile_name        = "${azurerm_traffic_manager_profile.ptfe.name}"
  type                = "azureEndpoints"
  target_resource_id  = "${azurerm_public_ip.main.id}"
  priority            = 1
}

resource "azurerm_traffic_manager_endpoint" "standby" {
  name                = "${local.standby_namespace}-traffic-manager-endpoint"
  resource_group_name = "${azurerm_resource_group.traffic_manager.name}"
  profile_name        = "${azurerm_traffic_manager_profile.ptfe.name}"
  type                = "azureEndpoints"
  target_resource_id  = "${azurerm_public_ip.standby.id}"
  priority            = 2
}

#------------------------------------------------------------------------------
# main virtual machine and managed disks
#------------------------------------------------------------------------------

resource "azurerm_public_ip" "main" {
  name                         = "${local.main_namespace}-public_ip"
  location                     = "${var.main_location}"
  resource_group_name          = "${var.main_rg_name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${local.main_namespace}"
}

resource "azurerm_network_interface" "main" {
  name                = "${local.main_namespace}-network_interface"
  location            = "${var.main_location}"
  resource_group_name = "${var.main_rg_name}"

  ip_configuration {
    name                          = "terraform_ip_configuration"
    subnet_id                     = "${var.main_subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = "${local.main_namespace}-managed_disk"
  location             = "${var.main_location}"
  resource_group_name  = "${var.main_rg_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "88"
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${local.main_namespace}-vm"
  location              = "${var.main_location}"
  resource_group_name   = "${var.main_rg_name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_A0"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.main_namespace}-os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.main.name}"
    managed_disk_id = "${azurerm_managed_disk.main.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.main.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${local.main_namespace}-vm"
    admin_username = "ptfe"
    admin_password = "password1234"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ptfe/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/roooms_rsa.pub")}"
    }
  }
}

resource "azurerm_virtual_machine_extension" "main" {
  depends_on                 = ["azurerm_virtual_machine.main"]
  name                       = "CustomScript"
  location                   = "${var.main_location}"
  resource_group_name        = "${var.main_rg_name}"
  virtual_machine_name       = "${local.main_namespace}-vm"
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo bash -c 'apt-get update && apt-get -y install apache2' "
    }
SETTINGS
}

#------------------------------------------------------------------------------
# standby virtual machine and managed disks
#------------------------------------------------------------------------------

resource "azurerm_public_ip" "standby" {
  name                         = "${local.standby_namespace}-public_ip"
  location                     = "${var.standby_location}"
  resource_group_name          = "${var.standby_rg_name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${local.standby_namespace}"
}

resource "azurerm_network_interface" "standby" {
  name                = "${local.standby_namespace}-network_interface"
  location            = "${var.standby_location}"
  resource_group_name = "${var.standby_rg_name}"

  ip_configuration {
    name                          = "terraform_ip_configuration"
    subnet_id                     = "${var.standby_subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.standby.id}"
  }
}

resource "azurerm_managed_disk" "standby" {
  name                 = "${local.standby_namespace}-managed_disk"
  location             = "${var.standby_location}"
  resource_group_name  = "${var.standby_rg_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "88"
}

resource "azurerm_virtual_machine" "standby" {
  name                  = "${local.standby_namespace}-vm"
  location              = "${var.standby_location}"
  resource_group_name   = "${var.standby_rg_name}"
  network_interface_ids = ["${azurerm_network_interface.standby.id}"]
  vm_size               = "Standard_A0"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.standby_namespace}-os_disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.standby.name}"
    managed_disk_id = "${azurerm_managed_disk.standby.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.standby.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${local.standby_namespace}-vm"
    admin_username = "ptfe"
    admin_password = "password1234"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ptfe/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/roooms_rsa.pub")}"
    }
  }
}

resource "azurerm_virtual_machine_extension" "standby" {
  depends_on                 = ["azurerm_virtual_machine.standby"]
  name                       = "CustomScript"
  location                   = "${var.standby_location}"
  resource_group_name        = "${var.standby_rg_name}"
  virtual_machine_name       = "${local.standby_namespace}-vm"
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo bash -c 'apt-get update && apt-get -y install apache2' "
    }
SETTINGS
}

#------------------------------------------------------------------------------
# virtual machine scale sets
#------------------------------------------------------------------------------


#resource "azurerm_virtual_machine_scale_set" "main" {
#  name                = "${local.namespace}-main_virtual_machine_scale_set"
#  location            = "${var.main_location}"
#  resource_group_name = "${var.main_rg_name}"
#  upgrade_policy_mode = "Manual"
#
#  sku {
#    name     = "Standard_A0"
#    tier     = "Standard"
#    capacity = 1
#  }
#
#  storage_profile_image_reference {
#    publisher = "Canonical"
#    offer     = "UbuntuServer"
#    sku       = "16.04-LTS"
#    version   = "latest"
#  }
#
#  storage_profile_os_disk {
#    name              = ""
#    caching           = "ReadWrite"
#    create_option     = "FromImage"
#    managed_disk_type = "Standard_LRS"
#  }
#
#  storage_profile_data_disk {
#    lun           = 0
#    caching       = "ReadWrite"
#    create_option = "Empty"
#    disk_size_gb  = 10
#  }
#
#  os_profile {
#    computer_name_prefix = "ptfe"
#    admin_username       = "ptfe"
#    admin_password       = "password1234"
#  }
#
#  os_profile_linux_config {
#    disable_password_authentication = true
#
#    ssh_keys {
#      path     = "/home/myadmin/.ssh/authorized_keys"
#      key_data = "${file("~/.ssh/roooms_rsa.pub")}"
#    }
#  }
#
#  network_profile {
#    name    = "terraform_network_profile"
#    primary = true
#
#    ip_configuration {
#      name      = "terraform_ip_configuration"
#      subnet_id = "${var.main_subnet_id}"
#    }
#  }
#}
#
#resource "azurerm_virtual_machine_scale_set" "standby" {
#  name                = "${local.namespace}-standby_virtual_machine_scale_set"
#  location            = "${var.standby_location}"
#  resource_group_name = "${var.standby_rg_name}"
#  upgrade_policy_mode = "Manual"
#
#  sku {
#    name     = "Standard_A0"
#    tier     = "Standard"
#    capacity = 1
#  }
#
#  storage_profile_image_reference {
#    publisher = "Canonical"
#    offer     = "UbuntuServer"
#    sku       = "16.04-LTS"
#    version   = "latest"
#  }
#
#  storage_profile_os_disk {
#    name              = ""
#    caching           = "ReadWrite"
#    create_option     = "FromImage"
#    managed_disk_type = "Standard_LRS"
#  }
#
#  storage_profile_data_disk {
#    lun           = 0
#    caching       = "ReadWrite"
#    create_option = "Empty"
#    disk_size_gb  = 10
#  }
#
#  os_profile {
#    computer_name_prefix = "ptfe"
#    admin_username       = "ptfe"
#    admin_password       = "password1234"
#  }
#
#  os_profile_linux_config {
#    disable_password_authentication = true
#
#    ssh_keys {
#      path     = "/home/myadmin/.ssh/authorized_keys"
#      key_data = "${file("~/.ssh/roooms_rsa.pub")}"
#    }
#  }
#
#  network_profile {
#    name    = "terraform_network_profile"
#    primary = true
#
#    ip_configuration {
#      name      = "terraform_ip_configuration"
#      subnet_id = "${var.standby_subnet_id}"
#    }
#  }
#}

