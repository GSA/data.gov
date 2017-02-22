# -----------------------------------------------------------------------------
#  Input Variables
# -----------------------------------------------------------------------------

variable "system" {}
variable "environment" {}
variable "stack" {}
variable "vpc_id" {}
variable "az" {}
variable "index" {}
variable "cidr_prefix" {}
variable "ami" { default = "ami-863b6391" }
variable "security_context" {}
variable "route_table_id" {}
variable "security_group_id" {}
variable "nat" { type = "map" }

# -----------------------------------------------------------------------------
#  NAT subnet
# -----------------------------------------------------------------------------

resource "aws_subnet" "nat_subnet" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "${var.az}"
    cidr_block = "${var.cidr_prefix}.${var.index}.0/24"
    tags = {
        Name = "${var.system}_${var.environment}_az${var.index}_nat"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "az${var.index}_nat"
    }
}

resource "aws_instance" "nat" {
    ami = "${var.ami}"
    instance_type = "${var.nat["instance_type"]}"
    key_name = "${var.system}_${var.security_context}_nat"
    vpc_security_group_ids = ["${var.security_group_id}"]
    associate_public_ip_address = true
    source_dest_check = false
    subnet_id = "${aws_subnet.nat_subnet.id}"
    root_block_device = {
        volume_type = "${var.nat["volume_type"]}"
        volume_size = "${var.nat["volume_size"]}"
    }
    tags = {
        Name = "${var.system}_${var.environment}_az${var.index}_nat"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "az${var.index}_nat"
    }
}

# Route all outbound traffic from NAT through Internetgaway (via the public route table)
resource "aws_route_table_association" "nat_subnet_routing" {
    subnet_id = "${aws_subnet.nat_subnet.id}"
    route_table_id = "${var.route_table_id}"
}

# Create a private route table for outbound traffic from internal/private subnets
resource "aws_route_table" "nat_routing" {
    vpc_id = "${var.vpc_id}"
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
    tags {
        Name = "${var.system}_${var.environment}_az${var.index}_nat"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "az${var.index}_nat"
    }
}

# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "subnet_id" {
    value = "${aws_subnet.nat_subnet.id}"
}

output "route_table_id" {
    value = "${aws_route_table.nat_routing.id}"
}

