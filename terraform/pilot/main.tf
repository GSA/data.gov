provider "aws" {
    region = "${var.region}"
}

# CREATE JUMP HOST
resource "aws_instance" "datagov_jump" {
    ami = "${lookup(var.ubuntu_amis, ${var.region}-hardened)}"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["sg-ba1b05c1"]
    
    subnet_id = "subnet-29c04203"
    root_block_device = {
        volume_type = "gp2"
        volume_size = 10
    }
    tags = {
        Name = "datagov_jumphost"
        client = "datagov"
        TerraformGroup = "Neil terraform pilot"
    }

}
