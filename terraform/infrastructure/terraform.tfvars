aws_region = "us-east-1"

network = {
    cidr_prefix = "172.27"
    az1 = "us-east-1b"
    az2 = "us-east-1c"
    privileged_access_cidr = "0.0.0.0/0"
}

nat = {
    instance_type = "t2.nano"
}