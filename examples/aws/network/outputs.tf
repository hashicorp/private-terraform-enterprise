output "subnet_ids" {
  value = "${aws_subnet.main.*.id}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "db_subnet_group_id" {
  value = "${aws_db_subnet_group.main.id}"
}
