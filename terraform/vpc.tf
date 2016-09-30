
# CREATE VPC
resource "aws_vpc" "datagov" {
	cidr_block = "${var.vpc_cidr}"
	tags = {
		Name = "Data.gov - ${var.environment}"
	}
}

# ELASTIC IP FOR NAT-GATEWAY
resource "aws_eip" "nat" {
	vpc = true
}

# CREATE SUBNETS
resource "aws_subnet" "datagov-publica" {
	vpc_id = "${aws_vpc.datagov.id}"
	cidr_block = "${lookup(var.subnet_cidrs, "publicA")}"
	availability_zone = "${lookup(var.vpc_azs, "A")}"
	tags = {
		Name = "Data.gov - ${var.environment} - PublicA"
	}
}

resource "aws_subnet" "datagov-publicb" {
	vpc_id = "${aws_vpc.datagov.id}"
	cidr_block = "${lookup(var.subnet_cidrs, "publicB")}"
	availability_zone = "${lookup(var.vpc_azs, "B")}"
	tags = {
		Name = "Data.gov - ${var.environment} - PublicB"
	}
}

resource "aws_subnet" "datagov-privatea" {
	vpc_id = "${aws_vpc.datagov.id}"
	cidr_block = "${lookup(var.subnet_cidrs, "privateA")}"
	availability_zone = "${lookup(var.vpc_azs, "A")}"
	tags = {
		Name = "Data.gov - ${var.environment} - PrivateA"
	}
}

resource "aws_subnet" "datagov-privateb" {
	vpc_id = "${aws_vpc.datagov.id}"
	cidr_block = "${lookup(var.subnet_cidrs, "privateB")}"
	availability_zone = "${lookup(var.vpc_azs, "B")}"
	tags = {
		Name = "Data.gov - ${var.environment} - PrivateB"
	}
}

# CREATE INTERNET GATEWAY
resource "aws_internet_gateway" "datagov-igw" {
    vpc_id = "${aws_vpc.datagov.id}"

    tags {
        Name = "Data.gov - ${var.environment} - IGW"
    }
}

# CREATE NAT-GATEWAY
resource "aws_nat_gateway" "datagov-natgw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.datagov-publica.id}"
    depends_on = ["aws_internet_gateway.datagov-igw"]
}

# CREATE ROUTE TABLES
resource "aws_route_table" "public" {
  vpc_id         = "${aws_vpc.datagov.id}"
  route = {
	  cidr_block = "0.0.0.0/0"
	  gateway_id             = "${aws_internet_gateway.datagov-igw.id}"
  }
   tags {
        Name = "Data.gov - ${var.environment} - Public Route"
    }
}

resource "aws_route_table" "private" {
  vpc_id         = "${aws_vpc.datagov.id}"
  route = {
	  cidr_block = "0.0.0.0/0"
	  nat_gateway_id             = "${aws_nat_gateway.datagov-natgw.id}"
  }
   tags {
        Name = "Data.gov - ${var.environment} - Private Route"
    }
}

# ASSOCIATE ROUTE TABLES
resource "aws_route_table_association" "publicA" {
    subnet_id = "${aws_subnet.datagov-publica.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "publicB" {
    subnet_id = "${aws_subnet.datagov-publicb.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "privateA" {
    subnet_id = "${aws_subnet.datagov-privatea.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "privateB" {
    subnet_id = "${aws_subnet.datagov-privateb.id}"
    route_table_id = "${aws_route_table.private.id}"
}
