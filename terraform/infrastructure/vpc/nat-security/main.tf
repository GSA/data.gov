# -----------------------------------------------------------------------------
#  NOTE: Cannot create network ACL here, because Terreform does not allow 
#      associating subnets with network ACLs fafter-the-fact, only upon 
#      NACL creation, and the NAT has not been created yet
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
#  Input Variables
# -----------------------------------------------------------------------------

variable "system" {}
variable "environment" {}
variable "stack" {}
variable "security_context" {}
variable "vpc_id" {}
variable "network_prefix" {}

# -----------------------------------------------------------------------------
#  NAT Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "nat_security_group" {
    name = "${var.system}_${var.environment}_nat"
    vpc_id = "${var.vpc_id}"
    ingress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.network_prefix}.0.0/0"]
    }
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.system}_${var.environment}_nat"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "nat_security_group"
    }
}

resource "aws_security_group_rule" "allow_ephemeral_tcp_ingress" {
    security_group_id = "${aws_security_group.nat_security_group.id}"
    type = "ingress"
    from_port = 1025
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ephemeral_udp_ingress" {
    security_group_id = "${aws_security_group.nat_security_group.id}"
    type = "ingress"
    from_port = 1025
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
}


# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "security_group_id" {
    value = "${aws_security_group.nat_security_group.id}"
}

