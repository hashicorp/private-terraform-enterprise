output "main_rg_name" {
  value = "${module.network.main_rg_name}"
}

output "standby_rg_name" {
  value = "${module.network.standby_rg_name}"
}

output "main_public_ip" {
  value = "${module.pes.main_public_ip}"
}

output "standby_public_ip" {
  value = "${module.pes.standby_public_ip}"
}
