# -----------------------------------------------------------------------------
#  Input Variables
# -----------------------------------------------------------------------------

variable "system" {}
variable "stack" {}
variable "environment" {}
variable "security_context" {}
variable "network" { type = "map" }
variable "nat" { type = "map" }

variable "nat_amis" {
    default = {
        # amzn-ami-vpc-nat-hvm-2016.09.0.20161028-x86_64-ebs
        us-east-1 = "ami-863b6391"
        us-east-2 = "ami-8d5a00e8"
    }
}

# -----------------------------------------------------------------------------
#  Resources
# -----------------------------------------------------------------------------

resource "aws_vpc" "main_vpc" {
    cidr_block = "${var.network["cidr_prefix"]}.0.0/16"
    instance_tenancy = "default"
    tags = {
        Name = "${var.system}_${var.environment}_main_vpc"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "main_vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main_vpc.id}"
    tags = {
        Name = "${var.system}_${var.environment}_igw"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "igw"
    }
}


resource "aws_route_table" "public_route_table" {
    vpc_id = "${aws_vpc.main_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
         gateway_id = "${aws_internet_gateway.igw.id}"
    }
    tags {
        Name = "${var.system}_${var.environment}_public"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "public_route_table"
    }
}

module "nat_security" {
    source = "./nat-security"
    system = "${var.system}"
    stack = "${var.stack}"
    environment = "${var.environment}"
    security_context = "${var.security_context}"
    vpc_id = "${aws_vpc.main_vpc.id}"
    network_prefix = "${var.network["cidr_prefix"]}"
}

module "nat_az1" {
    source = "./nat"
    index = "1"
    system = "${var.system}"
    stack = "${var.stack}"
    environment = "${var.environment}"
    security_context = "${var.security_context}"
    vpc_id = "${aws_vpc.main_vpc.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
    cidr_prefix = "${var.network["cidr_prefix"]}"
    az = "${var.network["az1"]}"
    ami = "${var.nat_amis[var.network["region"]]}"
    security_group_id = "${module.nat_security.security_group_id}"
    nat = "${var.nat}"
}
# module "nat_az2" {
#     source = "./nat"
#     index = "2"
#     system = "${var.system}"
#     stack = "${var.stack}"
#     Environment = "${var.environment}"
#     security_context = "${var.security_context}"
#     vpc_id = "${aws_vpc.main_vpc.id}"
#     route_table_id = "${aws_route_table.public_route_table.id}"
#     cidr_prefix = "${var.network["cidr_prefix"]}"
#     az = "${var.network["az2"]}"
#     ami = "${var.nat_amis[var.network["region"]]}"
#     security_group_id = "${module.nat_security.security_group_id}"
#     nat = "${var.nat}"
# }

# resource "aws_network_acl" "nat" {
#     vpc_id = "${aws_vpc.main_vpc.id}"
#     subnet_ids = [
#         "${module.nat_az1.subnet_id}",
#         "${module.nat_az2.subnet_id}" 
#     ]
#     tags {
#         Name = "${var.system}_${var.environment}_nat"
#         System = "${var.system}"
#         Stack = "${var.stack}"
#         Environment = "${var.environment}"
#         Resource = "nat_security_group"
#     }
# }

# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "vpc_id" {
    value = "${aws_vpc.main_vpc.id}"
}

output "public_route_table_id" {
    # Route table to be used by public subnets
    value = "${aws_route_table.public_route_table.id}"
}

output "az1_private_route_table_id" {
    # Route table to be used by private subnets to AZ1 NAT
    value = "${module.nat_az1.route_table_id}"
}

# output "az2_private_route_table_id" {
#     # Route table to be used by private subnets to AZ2 NAT
#     value = "${module.nat_az2.route_table_id}"
# }
