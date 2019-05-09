output "ptfe_fqdn" {
  value = "${module.pes.ptfe_fqdn}"
}

output "ptfe_public_ip" {
  value = "${module.pes.ptfe_public_ip}"
}

output "ptfe_private_ip" {
  value = "${module.pes.ptfe_private_ip}"
}

output "ptfe_public_dns" {
  value = "${module.pes.ptfe_public_dns}"
}

output "ptfe_private_dns" {
  value = "${module.pes.ptfe_private_dns}"
}

output "db_endpoint" {
  value = "${module.database.db_endpoint}"
}
