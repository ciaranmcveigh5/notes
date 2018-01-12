# VPC

resource "aws_vpc" "project" {
	cidr_block = "${var.vpc_cidr}"

	tags {
		Name = "${var.environment}-project"
	}
}

# GATEWAYS

resource "aws_internet_gateway" "project_igw" {
  vpc_id = "${aws_vpc.project.id}"

  tags {
    Name = "${var.environment}_igw"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat_gw.id}"
  subnet_id     = "${aws_subnet.public_a.id}"
}


# ROUTE TABLE

resource "aws_route_table" "project" {
  vpc_id = "${aws_vpc.project.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.project_igw.id}"
  }

  tags {
    Name = "${var.environment}_project"
  }
}

resource "aws_route_table_association" "project_public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.project.id}"
}

resource "aws_route_table_association" "project_public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.project.id}"
}


# SUBNETS

resource "aws_subnet" "public_a" {
	vpc_id     = "${aws_vpc.project.id}"
	cidr_block = "${var.public_a_cidr}"
	availability_zone = "eu-west-2a"

	tags {
		Name = "${var.environment}_public_a"
	}
}

resource "aws_subnet" "public_b" {
	vpc_id     = "${aws_vpc.project.id}"
	cidr_block = "${var.public_b_cidr}"
	availability_zone = "eu-west-2b"


	tags {
		Name = "${var.environment}_public_b"
	}
}

resource "aws_subnet" "private_a" {
	vpc_id     = "${aws_vpc.project.id}"
	cidr_block = "${var.private_a_cidr}"
	availability_zone = "eu-west-2a"


	tags {
		Name = "${var.environment}_private_a"
	}
}

resource "aws_subnet" "private_b" {
	vpc_id     = "${aws_vpc.project.id}"
	cidr_block = "${var.private_b_cidr}"
	availability_zone = "eu-west-2b"


	tags {
		Name = "${var.environment}_private_b"
	}
}

# EIP

resource "aws_eip" "nat_gw" {
	vpc      = true
}
