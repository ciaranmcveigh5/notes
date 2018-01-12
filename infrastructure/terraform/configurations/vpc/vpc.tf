# PROVIDER

provider "aws" {
	region = "eu-west-2"
}

# DATA

data "aws_ami" "ec2_linux" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}


# VPC

module "vpc" {
  source = "../modules/vpc"

  environment = "${terraform.workspace}"
	vpc_cidr = "${var.project_vpc_cidr_range["${terraform.workspace}"]}"
	public_a_cidr = "${var.public_a_cidr_range["${terraform.workspace}"]}"
	public_b_cidr = "${var.public_b_cidr_range["${terraform.workspace}"]}"
	private_a_cidr = "${var.private_a_cidr_range["${terraform.workspace}"]}"
	private_b_cidr = "${var.private_b_cidr_range["${terraform.workspace}"]}"
}

# SECURITY GROUPS

resource "aws_security_group" "project_base" {
	vpc_id = "${module.vpc.project_vpc}"
	name = "${terraform.workspace}_project_base"
	description = "Base security group"

	ingress {
		from_port = "${var.ssh_port}"
		to_port = "${var.ssh_port}"
		protocol = "tcp"
		cidr_blocks = ["${var.}"]
	}

	ingress {
		from_port = "${var.http_port}"
		to_port = "${var.http_port}"
		protocol = "tcp"
		cidr_blocks = ["${var.}"]
	}

	ingress {
		from_port = "${var.ssh_port}"
		to_port = "${var.ssh_port}"
		protocol = "tcp"
		cidr_blocks = ["${var.}"]
	}

	ingress {
		from_port = "${var.http_port}"
		to_port = "${var.http_port}"
		protocol = "tcp"
		cidr_blocks = ["${var.}"]
	}

	ingress {
		from_port = "${var.ssh_port}"
		to_port = "${var.ssh_port}"
		protocol = "tcp"
		cidr_blocks = ["${var.}"]
	}

	ingress {
		from_port = "${var.http_port}"
		to_port = "${var.http_port}"
		protocol = "tcp"
		cidr_blocks = ["${var.}"]
	}

	ingress {
		from_port = "${var.http_port}"
		to_port = "${var.http_port}"
		protocol = "tcp"
		cidr_blocks = ["${var.bitbucket1_cidr_range}", "${var.bitbucket2_cidr_range}", "${var.bitbucket3_cidr_range}", "${var.bitbucket4_cidr_range}"]
	}

	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		self = true
	}

	egress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# ROUTE 53

data "aws_route53_zone" "core" {
  name = "project.co.uk"
}

data "aws_route53_zone" "workspace_zone" {
  name = "${terraform.workspace}.project.co.uk"
}
