module "db_catalog" {
  source = "./modules/db"
  cluster_name = "${var.prefix}-catalog"
  vpc_id = "${module.vpc.vpc_id}"
  db_name = "ckan"
  db_user = "ckan"
  db_password = "ckanpassword"
  subnet_ids = ["${module.vpc.private_subnets}"]
}

module "db_pycsw" {
  source = "./modules/db"
  cluster_name = "${var.prefix}-catalog-pycsw"
  vpc_id = "${module.vpc.vpc_id}"
  db_name = "pycsw"
  db_user = "ckan"
  db_password = "ckanpassword"
  subnet_ids = ["${module.vpc.private_subnets}"]
}
