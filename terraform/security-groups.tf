# CREATE SECURITY GROUPS
resource "aws_security_group" "rancher_elb_sg" {
    name = "rancher-elb-sg"
    description = "Security Group for Rancher Management ELB"
    vpc_id = "${aws_vpc.datagov.id}"

    # HTTP Access for Aquilent
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${split(",", var.aquilent-ips)}","${split(",", var.gsa-ips)}", "52.200.234.106/32", "0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "datagov_jumphost" {
    name = "datagov_jumphost"
    description = "Access to the jump host for Data.gov"
    vpc_id = "${aws_vpc.datagov.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${split(",", var.aquilent-ips)}","${split(",", var.gsa-ips)}", "0.0.0.0/0"]
    }
     egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rancher" {
    name = "rancher"
    description = "Main SG for Rancher"
    vpc_id = "${aws_vpc.datagov.id}"
    ingress {
        from_port = 0
        to_port= 65535
        protocol = "tcp"
        security_groups = ["${aws_security_group.datagov_jumphost.id}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        security_groups = ["${aws_security_group.datagov_jumphost.id}"]
    }
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        self = true
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        security_groups = ["${aws_security_group.rancher_elb_sg.id}"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}
