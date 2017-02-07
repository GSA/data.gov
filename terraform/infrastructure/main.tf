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
variable "branch" {}

variable "aws_region" { default = "us-east-1" }
variable "ami_type" { default = "hardened" }
variable "security_context" { default = "dev" }

variable "network" { 
    type = "map"
    default = {
        az1 = "us-east-1b"
        az2 = "us-east-1c"
        cidr_prefix = "172.27"
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
#  Local Variables
# -----------------------------------------------------------------------------

variable "amis" {
    default = {
        us-east-1-hardened = "ami-fce3c696"
        us-east-1-not-hardened = "ami-857f5392"
    }
}

# -----------------------------------------------------------------------------
#  Provider
# -----------------------------------------------------------------------------

provider "aws" {
    region  = "${var.aws_region}"
}

# -----------------------------------------------------------------------------
#  VPC
# -----------------------------------------------------------------------------

module "vpc" {
    source = "./vpc"
    system = "${var.system}"
    branch = "${var.branch}"
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
    branch = "${var.branch}"
    vpc_id = "${module.vpc.vpc_id}"
    network = "${var.network}"
    network_segment = "10"
    route_table_id = "${module.vpc.public_route_table_id}"
}

module "monitor_subnet" {
    source = "./server-subnet"
    name = "monitor"
    index = "1"
    system = "${var.system}"
    stack = "${var.stack}"
    branch = "${var.branch}"
    vpc_id = "${module.vpc.vpc_id}"
    network = "${var.network}"
    network_segment = "11"
    route_table_id = "${module.vpc.az1_private_route_table_id}"
}


# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "bastion_subnet_id" {
    value = "${module.bastion_subnet.subnet_id}"
}
output "bastion_security_group_id" {
    value = "${module.bastion_subnet.security_group_id}"
}

output "monitor_subnet_id" {
    value = "${module.monitor_subnet.subnet_id}"
}
output "monitor_security_group_id" {
    value = "${module.monitor_subnet.security_group_id}"
}
