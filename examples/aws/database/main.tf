### Database resources

resource "aws_db_subnet_group" "ptfe" {
  name_prefix = "${var.namespace}-db-zone"
  description = "${var.namespace}-db-subnet-group"
  subnet_ids  = ["${var.subnet_ids}"]
}

resource "aws_db_instance" "ptfe" {
  allocated_storage         = "${var.database_storage}"
  engine                    = "postgres"
  engine_version            = "10.1"
  instance_class            = "${var.database_instance_class}"
  identifier                = "${var.namespace}-db-instance"
  name                      = "${var.database_name}"
  storage_type              = "gp2"
  username                  = "${var.database_username}"
  password                  = "${var.database_pwd}"
  db_subnet_group_name      = "${aws_db_subnet_group.ptfe.id}"
  multi_az                  = "${var.database_multi_az}"
  vpc_security_group_ids    = ["${var.vpc_security_group_ids}"]
  final_snapshot_identifier = "${var.namespace}-db-instance-final-snapshot"
}
