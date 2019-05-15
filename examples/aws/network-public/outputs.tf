output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "subnet_ids" {
  value = "${aws_subnet.main.*.id}"
}

output "security_group_id" {
  value = "${aws_security_group.main.id}"
}

output "kms_id" {
  value = "${aws_kms_key.s3.key_id}"
}
