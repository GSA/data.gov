# -----------------------------------------------------------------------------
#  Inputs
# -----------------------------------------------------------------------------

variable "system" {}
variable "stack" {}
variable "environment" {}
variable "index" {}
variable "name" {}
variable "network" { type = "map" }
variable "vpc_id" {}
variable "network_segment" {}
variable "route_table_id" {}

# Change to assigning roles and determining which SG rules to create
# based on the role being played using conditionas and count
variable "http_server_count" { default = "0" }

# -----------------------------------------------------------------------------
#  Subnet
# -----------------------------------------------------------------------------
resource "aws_subnet" "server_subnet" {
    vpc_id = "${var.vpc_id}"
    availability_zone = "${lookup(var.network, format("az%s", var.index))}"
    cidr_block = "${var.network["cidr_prefix"]}.${var.network_segment}.0/24"
    tags = {
        Name = "${var.system}_${var.environment}_az${var.index}_${var.name}"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
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
    #name = "${var.system}_${var.environment}_az${var.index}_${var.name}"
    vpc_id = "${var.vpc_id}"
    tags = {
        Name = "${var.system}_${var.environment}_az${var.index}_${var.name}"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "az${var.index}_${var.name}"
    }
}

resource "aws_security_group_rule" "allow_ssh_ingress" {
    count = "${length(split(",", var.network["privileged_access_cidr"]))}"
    security_group_id = "${aws_security_group.server_security_group.id}"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
        "${element(split(",", var.network["privileged_access_cidr"]), count.index)}"
    ]
}

resource "aws_security_group_rule" "allow_http_ingress" {
    count = "${var.http_server_count}"
    security_group_id = "${aws_security_group.server_security_group.id}"
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_https_ingress" {
    count = "${var.http_server_count}"
    security_group_id = "${aws_security_group.server_security_group.id}"
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_local_ingress" {
    security_group_id = "${aws_security_group.server_security_group.id}"
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["${var.network["cidr_prefix"]}.0.0/16"]
}

resource "aws_security_group_rule" "allow_tcp_egress" {
    security_group_id = "${aws_security_group.server_security_group.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = -1
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

output "subnet_prefix" {
    value = "${var.network["cidr_prefix"]}.${var.network_segment}.0/24"
}