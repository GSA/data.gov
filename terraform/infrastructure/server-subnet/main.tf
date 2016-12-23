# -----------------------------------------------------------------------------
#  Input Variables
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

resource "aws_route_table_association" "server_subnet_routing" {
    subnet_id = "${aws_subnet.server_subnet.id}"
    route_table_id = "${var.route_table_id}"
}

# -----------------------------------------------------------------------------
#  Outputs
# -----------------------------------------------------------------------------

output "subnet_id" {
    value = "aws_subnet.server_subnet.id"
}
