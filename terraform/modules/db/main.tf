resource "aws_security_group" "db" {
  name        = "db-${var.cluster_name}"
  description = "Allow access to database"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.cluster_name}"
  subnet_ids = ["${var.subnet_ids}"]

  tags {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "master" {
  allocated_storage    = 10
  identifier_prefix    = "${var.cluster_name}-master-"
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.6"
  allow_major_version_upgrade = true
  instance_class       = "db.t2.micro"
  name           = "${var.db_name}"
  username         = "${var.db_user}"
  password         = "${var.db_password}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"

  # For testing
  backup_retention_period = 1
  skip_final_snapshot = true
  apply_immediately    = true
}

resource "aws_db_instance" "replica" {
  count              = "${var.count_replicas}"
  identifier_prefix    = "${var.cluster_name}-replica${count.index}-"
  instance_class     = "db.t2.micro"
  replicate_source_db = "${aws_db_instance.master.id}"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]

  # For testing
  skip_final_snapshot = true
  apply_immediately    = true
}
