output "security_group_id" {
  value = "${aws_security_group.db.id}"
}

output "master" {
  value = "${aws_db_instance.master.address}"
}

output "replicas" {
  value = ["${aws_db_instance.replica.*.address}"]
}
