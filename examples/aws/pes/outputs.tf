output "instance_ids" {
  value = ["${aws_instance.pes.*.id}"]
}

output "endpoint" {
  value = "${aws_db_instance.pes.endpoint}"
}
