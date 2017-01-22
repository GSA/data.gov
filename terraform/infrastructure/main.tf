# -----------------------------------------------------------------------------
#  Input Variables
# -----------------------------------------------------------------------------

variable "system" {
    description = "Name of the system (used to name and tag resources)"
    default = "datagov"
}
variable "stack" {
    description = "Name of the system (used to name and tag resources)"
    default = "pilot"
}
variable "environment" {}

variable "ami_type" { default = "hardened" }
variable "security_context" { default = "dev" }

variable "network" { 
    type = "map"
    default = {
        region = "us-east-1"
        az1 = "us-east-1b"
        az2 = "us-east-1c"
        cidr_prefix = "172.27"
        # Maps in input/output variales require homogeneous types,
        # so you cannot use a list type here
        privileged_access_cidr = "54.197.42.13/32, 12.153.61.2/32"
    }
}

variable "nat" { 
    type = "map"
    default = {
        instance_type = "m3.medium" 
        volume_type = "gp2"
        volume_size = "8"
    }
}

# -----------------------------------------------------------------------------
#  Provider
# -----------------------------------------------------------------------------

provider "aws" {
    region  = "${var.network["region"]}"
}

# -----------------------------------------------------------------------------
#  VPC
# -----------------------------------------------------------------------------

module "vpc" {
    source = "./vpc"
    system = "${var.system}"
    environment = "${var.environment}"
    stack = "${var.stack}"
    security_context = "${var.security_context}"
    network = "${var.network}"
    nat = "${var.nat}"
}

module "bastion_subnet" {
    source = "./server-subnet"
    name = "bastion"
    index = "1"
    system = "${var.system}"
    stack = "${var.stack}"
    environment = "${var.environment}"
    vpc_id = "${module.vpc.vpc_id}"
    network = "${var.network}"
    network_segment = "10"
    route_table_id = "${module.vpc.public_route_table_id}"
}

module "wordpress_web_subnet" {
    source = "./server-subnet"
    name = "wordpress_web"
    index = "1"
    system = "${var.system}"
    stack = "${var.stack}"
    environment = "${var.environment}"
    vpc_id = "${module.vpc.vpc_id}"
    network = "${var.network}"
    network_segment = "11"
    #route_table_id = "${module.vpc.az1_private_route_table_id}"
    route_table_id = "${module.vpc.public_route_table_id}"
    http_server_count = "1"
}


# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}

output "bastion_subnet_id" {
    value = "${module.bastion_subnet.subnet_id}"
}
output "bastion_security_group_id" {
    value = "${module.bastion_subnet.security_group_id}"
}
output "bastion_subnet_prefix" {
    value = "${module.bastion_subnet.subnet_prefix}"
}

output "wordpress_web_subnet_id" {
    value = "${module.wordpress_web_subnet.subnet_id}"
}
output "wordpress_web_security_group_id" {
    value = "${module.wordpress_web_subnet.security_group_id}"
}
