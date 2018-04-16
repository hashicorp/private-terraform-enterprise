output "main_public_ip" {
  value = "${azurerm_public_ip.main.ip_address}"
}

output "standby_public_ip" {
  value = "${azurerm_public_ip.standby.ip_address}"
}
