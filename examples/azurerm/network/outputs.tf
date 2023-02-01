# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "main_rg_name" {
  value = "${azurerm_resource_group.main.name}"
}

output "main_subnet_id" {
  value = "${data.azurerm_subnet.main.id}"
}

output "standby_rg_name" {
  value = "${azurerm_resource_group.standby.name}"
}

output "standby_subnet_id" {
  value = "${data.azurerm_subnet.standby.id}"
}
