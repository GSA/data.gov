variable "region" {
    description = "AWS region to work in"
    default = "us-east-1"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "datagov-nhunt"
}

variable "ubuntu_amis" {
  description = "Ubuntu AMIs"
  default = {
    us-east-1-hardened = "ami-fce3c696"
    us-east-1-not-hardened = "ami-857f5392"
  }
}

# CREATE JUMP HOST
resource "aws_instance" "datagov_jump" {
    #ami = "${lookup(var.ubuntu_amis, ${var.region}-hardened)}"
    ami = "ami-fce3c696"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["sg-ba1b05c1"]
    associate_public_ip_address = true
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
