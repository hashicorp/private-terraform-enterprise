### Database resources

resource "aws_db_subnet_group" "ptfe" {
  name_prefix = "${var.namespace}"
  description = "${var.namespace}-db-subnet-group"
  subnet_ids  = ["${var.subnet_ids}"]
}

resource "aws_db_instance" "ptfe" {
  allocated_storage         = 50
  engine                    = "postgres"
  engine_version            = "10.1"
  instance_class            = "db.m4.large"
  identifier                = "${var.namespace}-db-instance"
  name                      = "${var.database_name}"
  storage_type              = "gp2"
  username                  = "${var.database_username}"
  password                  = "${var.database_pwd}"
  db_subnet_group_name      = "${aws_db_subnet_group.ptfe.id}"
  multi_az                  = "true"
  vpc_security_group_ids    = ["${var.vpc_security_group_ids}"]
  final_snapshot_identifier = "${var.namespace}-db-instance-final-snapshot"
}
