provider "aws" {
    region = "${var.region}"
    profile = "${var.aws_profile}"
}

# CREATE RANCHER ELB
resource "aws_elb" "rancher_elb" {
    name = "rancher-elb"
    subnets = ["${aws_subnet.datagov-publica.id}", "${aws_subnet.datagov-publicb.id}"]
    security_groups = ["${aws_security_group.rancher_elb_sg.id}"]
    instances = ["${aws_instance.rancher_main.id}"]
    listener = {
        instance_port = "8080"
        instance_protocol = "tcp"
        lb_port = "80"
        lb_protocol = "tcp"
    }
    health_check = {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:8080/ping"
        interval = 10
    }
    cross_zone_load_balancing = true
    tags = {
        Name = "rancher-elb"
        client = "datagov"
    }
    depends_on = ["aws_subnet.datagov-publica", "aws_subnet.datagov-publicb"]
}

#resource "aws_route53_record" "rancher" {
#    zone_id ="${var.zone_id}"
#    name = "rancher.${var.environment}.${var.domain}"
#    type = "CNAME"
#    ttl = "60"
#    records = ["${aws_elb.rancher_elb.dns_name}"]
#}
# CREATE JUMP HOST
resource "aws_instance" "datagov_jump" {
    ami = "${lookup(var.ubuntu_amis, var.region)}"
    instance_type = "t2.medium"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.datagov_jumphost.id}"]
    subnet_id = "${aws_subnet.datagov-publica.id}"
    root_block_device = {
        volume_type = "gp2"
        volume_size = 100
    }
    ephemeral_block_device = {
        device_name = "/dev/sdb"
        virtual_name = "ephemeral0"
    }
    tags = {
        Name = "datagov_jumphost"
        client = "datagov"
    }
    depends_on = ["aws_subnet.datagov-publica", "aws_subnet.datagov-publicb"]
}

# ASSOCIATE ELASTIC IP WITH JUMP HOST
resource "aws_eip" "jump" {
    instance = "${aws_instance.datagov_jump.id}"
    vpc = true
    depends_on = ["aws_instance.datagov_jump"]
}

# CREATE RANCHER INSTANCE

resource "aws_instance" "rancher_main" {
    ami = "${lookup(var.ubuntu_amis, var.region)}"
    instance_type = "c3.2xlarge"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.rancher.id}"]
    subnet_id = "${aws_subnet.datagov-privatea.id}"
    root_block_device = {
        volume_type = "gp2"
    }
    ephemeral_block_device = {
        device_name = "/dev/sdb"
        virtual_name = "ephemeral0"
    }
    ebs_block_device = {
        device_name = "/dev/sdd"
        volume_type = "gp2"
        volume_size = 100
    }
    tags = {
        Name = "rancher_main"
        client = "datagov"
    }
    connection {
            user = "ubuntu"
            host = "${aws_instance.rancher_main.private_ip}"
            private_key = "${file("./datagov-rancher.pem")}"
            bastion_host = "${aws_eip.jump.public_ip}"
            bastion_user = "ubuntu"
            bastion_private_key = "${file("./datagov-rancher.pem")}"
        }


    provisioner "file" {
        source = "scripts/rancher-server-setup.sh"
        destination = "/tmp/rancher-server-setup.sh"
    }
    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/rancher-server-setup.sh",
          "sudo /tmp/rancher-server-setup.sh -t ${var.rancher_tag} -r ${aws_db_instance.rancher_db.endpoint} -u ${var.rds_user} -p ${var.rds_pass}"
        ]
    }

    depends_on = ["aws_instance.datagov_jump", "aws_eip.jump"]
}

resource "aws_instance" "rancher_server" {
    count = 2
    ami = "${lookup(var.ubuntu_amis, var.region)}"
    instance_type = "c3.2xlarge"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.rancher.id}"]
    subnet_id = "${aws_subnet.datagov-privatea.id}"
    root_block_device = {
        volume_type = "gp2"
    }
    ephemeral_block_device = {
        device_name = "/dev/sdb"
        virtual_name = "ephemeral0"
    }
    ebs_block_device = {
        device_name = "/dev/sdd"
        volume_type = "gp2"
        volume_size = 100
    }
    tags = {
        Name = "rancher_server"
        client = "datagov"
    }

    depends_on = ["aws_instance.datagov_jump", "aws_eip.jump"]
}

resource "null_resource" "configure-rancher-servers" {
    count = 2
    connection {
            user = "ubuntu"
            host = "${element(aws_instance.rancher_server.*.private_ip, count.index)}"
            private_key = "${file("./datagov-rancher.pem")}"
            bastion_host = "${aws_eip.jump.public_ip}"
            bastion_user = "ubuntu"
            bastion_private_key = "${file("./datagov-rancher.pem")}"
        }


    provisioner "file" {
        source = "scripts/rancher-server-setup.sh"
        destination = "/tmp/rancher-server-setup.sh"
    }
    provisioner "remote-exec" {
        inline = [
          "chmod +x /tmp/rancher-server-setup.sh",
          "sudo /tmp/rancher-server-setup.sh -t ${var.rancher_tag} -r ${aws_db_instance.rancher_db.endpoint} -u ${var.rds_user} -p ${var.rds_pass}"
        ]
    }
}
