output "PostreSQL Password" {
  value = "${random_pet.replicated-pwd.id}"
}
