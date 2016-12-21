
# -----------------------------------------------------------------------------
#  Input Variables
# -----------------------------------------------------------------------------

variable "system" {}
variable "branch" {}
variable "stack" {}
variable "ami" {}
variable "security_context" {}
variable "securitygroup_id" {}
variable "subnet_id" {}
variable "instance_type" { default = "m3.medium" }

variable "volume_type" { default = "gp2" }
variable "volume_size" { default = "8" }


# -----------------------------------------------------------------------------
#  Bastion server
# -----------------------------------------------------------------------------

resource "aws_instance" "monitor" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.system}_${var.security_context}_${var.stack}_monitor"
    vpc_security_group_ids = ["${var.securitygroup_id}"]
    associate_public_ip_address = true
    subnet_id = "${var.subnet_id}"
    root_block_device = {
        volume_type = "${var.volume_type}"
        volume_size = "${var.volume_size}"
    }
    tags = {
        Name = "${var.system}_${var.stack}_${var.branch}_monitor"
        System = "${var.system}"
        Stack = "${var.stack}"
        Branch = "${var.branch}"
        Resource = "monitor"
    }
}

# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "instance_id" {
    value = "${aws_instance.monitor.id}"
}
output "public_ip" {
    value = "${aws_instance.monitor.public_ip}"
}
