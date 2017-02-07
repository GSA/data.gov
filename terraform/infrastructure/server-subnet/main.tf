# -----------------------------------------------------------------------------
#  Inputs
# -----------------------------------------------------------------------------

variable "system" {}
variable "stack" {}
variable "branch" {}
variable "index" {}
variable "name" {}
variable "network" { type = "map" }
variable "vpc_id" {}
variable "network_segment" {}
variable "route_table_id" {}

# -----------------------------------------------------------------------------
#  Resources
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
#  Subnet
# -----------------------------------------------------------------------------
resource "aws_subnet" "server_subnet" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "${lookup(var.network, format("az%s", var.index))}"
    cidr_block = "${var.network["cidr_prefix"]}.${var.network_segment}.0/24"
    tags = {
        Name = "${var.system}_${var.branch}_az${var.index}_${var.name}"
        System = "${var.system}"
        Stack = "${var.stack}"
        Branch = "${var.branch}"
        Resource = "az${var.index}_${var.name}"
    }
}

# -----------------------------------------------------------------------------
#  Subnet to RouteTable association
# -----------------------------------------------------------------------------
resource "aws_route_table_association" "server_subnet_routing" {
    subnet_id = "${aws_subnet.server_subnet.id}"
    route_table_id = "${var.route_table_id}"
}

# -----------------------------------------------------------------------------
#  SecurityGroup
# -----------------------------------------------------------------------------
resource "aws_security_group" "server_security_group" {
    name = "${var.system}_${var.branch}_az${var.index}_${var.name}"
    vpc_id = "${var.vpc_id}"
    ingress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.network["cidr_prefix"]}.0.0/0"]
    }
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.system}_${var.branch}_az${var.index}_${var.name}"
        System = "${var.system}"
        Stack = "${var.stack}"
        Branch = "${var.branch}"
        Resource = "az${var.index}_${var.name}"
    }
}

resource "aws_security_group_rule" "allow_ephemeral_tcp_ingress" {
    security_group_id = "${aws_security_group.server_security_group.id}"
    type = "ingress"
    from_port = 1025
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ephemeral_udp_ingress" {
    security_group_id = "${aws_security_group.server_security_group.id}"
    type = "ingress"
    from_port = 1025
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
}

# -----------------------------------------------------------------------------
#  Outputs
# -----------------------------------------------------------------------------

output "subnet_id" {
    value = "${aws_subnet.server_subnet.id}"
}

output "security_group_id" {
    value = "${aws_security_group.server_security_group.id}"
}
