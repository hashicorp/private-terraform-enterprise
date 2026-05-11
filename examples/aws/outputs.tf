# Copyright IBM Corp. 2018, 2026

output "replicated console password" {
  value = "${random_pet.replicated-pwd.id}"
}
