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

variable "security_context" { default = "dev" }

variable "network" { 
    type = "map"
    default = {
        region = "us-east-1" 
    }
}
variable "ami_type" { default = "not-hardened" }
variable "bastion_subnet_id" {}
variable "bastion_security_group_id" {}
variable "bastion_instance_type" { default = "m3.medium" }

variable "wordpress_web_subnet_id" {}
variable "wordpress_web_security_group_id" {}
variable "wordpress_web_instance_type" { default = "m3.medium" }


# -----------------------------------------------------------------------------
#  Local Variables
# -----------------------------------------------------------------------------

variable "amis" {
    default = {
        # ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-20160114.5
        us-east-1-not-hardened = "ami-fce3c696"
        us-east-2-not-hardened = "ami-0becb76e"
        # Ubuntu 14.04 pre-CIS
        us-east-1-hardened = "ami-857f5392"
        us-east-2-hardened = "ami-3c6d4859"
    }
}


# -----------------------------------------------------------------------------
#  Bastion server
# -----------------------------------------------------------------------------

provider "aws" {
    region  = "${var.network["region"]}"
}

# -----------------------------------------------------------------------------
#  Bastion server
# -----------------------------------------------------------------------------
module "bastion" {
    source = "./bastion"
    system = "${var.system}"
    environment = "${var.environment}"
    stack = "${var.stack}"
    security_context = "${var.security_context}"
    ami = "${lookup(var.amis, format("%s-%s", var.network["region"], var.ami_type))}"
    instance_type = "${var.bastion_instance_type}"
    security_group_id = "${var.bastion_security_group_id}"
    subnet_id = "${var.bastion_subnet_id}"
}

# -----------------------------------------------------------------------------
#  Monitoring server
# -----------------------------------------------------------------------------
module "wordpress_web" {
    source = "./wordpress-web"
    system = "${var.system}"
    environment = "${var.environment}"
    stack = "${var.stack}"
    security_context = "${var.security_context}"
    ami = "${lookup(var.amis, format("%s-%s", var.network["region"], var.ami_type))}"
    instance_type = "${var.wordpress_web_instance_type}"
    security_group_id = "${var.wordpress_web_security_group_id}"
    subnet_id = "${var.wordpress_web_subnet_id}"
}

# -----------------------------------------------------------------------------
#  Output Variables
# -----------------------------------------------------------------------------

output "bastion_instance_id" {
    value = "${module.bastion.instance_id}"
}
output "bastion_public_ip" {
    value = "${module.bastion.public_ip}"
}


output "wordpress_web_instance_id" {
    value = "${module.wordpress_web.instance_id}"
}
output "wordpress_web_public_ip" {
    value = "${module.wordpress_web.public_ip}"
}
