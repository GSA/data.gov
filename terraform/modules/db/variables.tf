variable "cluster_name" {
  description = "Name of the database cluster."
}

variable "vpc_id" {
  description = "The VPC Id in which to create this database cluster."
}

variable "db_name" {
  description = "Name of the database."
}

variable "db_user" {
  description = "Username for the master database user."
}

variable "db_password" {
  description = "Password for the master database user."
}

variable "subnet_ids" {
  description = "List of subnets to create the database in."
  type = "list"
}

variable "count_replicas" {
  description = "Number of read replicas to create."
  default = 1
}
