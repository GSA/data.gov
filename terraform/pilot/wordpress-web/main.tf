
# -----------------------------------------------------------------------------
#  Input Variables
# -----------------------------------------------------------------------------

variable "system" {}
variable "environment" {}
variable "stack" {}
variable "ami" {}
variable "security_context" {}
variable "security_group_id" {}
variable "subnet_id" {}
variable "instance_type" { default = "m3.medium" }

variable "volume_type" { default = "gp2" }
variable "volume_size" { default = "8" }


# -----------------------------------------------------------------------------
#  Monitor server
# -----------------------------------------------------------------------------

resource "aws_instance" "wordpress_web" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.system}_${var.security_context}_wordpress_web"
    vpc_security_group_ids = ["${var.security_group_id}"]
    associate_public_ip_address = true
    subnet_id = "${var.subnet_id}"
    root_block_device = {
        volume_type = "${var.volume_type}"
        volume_size = "${var.volume_size}"
    }
    tags = {
        Name = "${var.system}_${var.environment}_wordpress-web"
        System = "${var.system}"
        Stack = "${var.stack}"
        Environment = "${var.environment}"
        Resource = "wordpress-web"
        Office = "403"
    }
}



# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "instance_id" {
    value = "${aws_instance.wordpress_web.id}"
}
output "public_ip" {
    value = "${aws_instance.wordpress_web.public_ip}"
}
