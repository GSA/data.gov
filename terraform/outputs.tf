output "datagov_jumphost_ip" {
	value = "${aws_eip.jump.public_ip}"
}

output "rancher_main_ip" {
    value = "${aws_instance.rancher_main.private_ip}"
}

output "rancher_rds_endpoint" {
	value = "${aws_db_instance.rancher_db.endpoint}"
}

output "rancher_elb" {
    value = "${aws_elb.rancher_elb.dns_name}"
}

#output "rancher_dns" {
#    value = "${aws_route53_record.rancher.fqdn}"
#}

output "setup" {
value = "Logs for the setup of the rancher manager host(s) will be located at /var/log/rancher-server-setup.log"
}

output "ProxyProtocol" {
	value = "In order for the ELB to work with WebSockets you must enable the ProxyProtocol, instructions can be found healthy_threshold http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/enable-proxy-protocol.html#enable-proxy-protocol-cli"
}

output "ELBinfo" {
	value = "ELBName is ${aws_elb.rancher_elb.name} and the backend port for step 3 from the docs above is 8080"
}
