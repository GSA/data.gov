
resource "aws_db_subnet_group" "rancher" {
    name = "rancher"
    description = "Datagov Rancher DB Subnet"
    subnet_ids = ["${aws_subnet.datagov-privatea.id}", "${aws_subnet.datagov-privateb.id}"]
    tags {
        Name = "Rancher DB subnet group"
    }
    depends_on = ["aws_subnet.datagov-privatea", "aws_subnet.datagov-privateb"]
}

resource "aws_db_instance" "rancher_db" {
    engine = "mysql"
    engine_version = "5.6.27"
    allocated_storage = "${var.rds_disk_size}"
    storage_type = "gp2"
    instance_class = "${var.rds_size}"
    identifier = "rancher"
    final_snapshot_identifier = "datagov-rancher"
    copy_tags_to_snapshot = true
    name = "cattle"
    username = "${var.rds_user}"
    password = "${var.rds_pass}"
    publicly_accessible = false
    db_subnet_group_name = "${aws_db_subnet_group.rancher.id}"
    vpc_security_group_ids = ["${aws_security_group.rancher.id}"]
    tags {
    	Name = "Rancher Database"
    }
    depends_on = ["aws_db_subnet_group.rancher"]
}
