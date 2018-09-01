output "jumpbox_ip" {
  value = "${aws_instance.jumpbox.public_ip}"
}

output "db_catalog_master" {
  value = "${module.db_catalog.master}"
}

output "db_catalog_replicas" {
  value = ["${module.db_catalog.replicas}"]
}

output "db_pycsw_master" {
  value = "${module.db_pycsw.master}"
}

output "db_pycsw_replicas" {
  value = ["${module.db_pycsw.replicas}"]
}
