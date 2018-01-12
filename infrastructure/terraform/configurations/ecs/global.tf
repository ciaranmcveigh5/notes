data "terraform_remote_state" "vpc" {
  backend     = "s3"

  config {
    bucket  = "project-spike"
    key     = "env:/${terraform.workspace}/project-vpc"
    region  = "eu-west-2"
  }
}

data "terraform_remote_state" "jenkins" {
  backend     = "s3"

  config {
    bucket  = "project-spike"
    key     = "project-jenkins"
    region  = "eu-west-2"
  }
}

data "terraform_remote_state" "ecs" {
  backend     = "s3"

  config {
    bucket  = "project-spike"
    key     = "env:/${terraform.workspace}/project-ecs"
    region  = "eu-west-2"
  }
}

# PORTS

variable "sonarqube_port" {
  default = 9000
}

variable "jenkins_port" {
  default = 8080
}

variable "bitbucket_port" {
  default = 28
}

variable "ssh_port" {
  default = 22
}

variable "http_port" {
  default = 80
}

variable "https_port" {
  default = 443
}

variable "simple_app_port" {
  default = 8443
}

# VPC CIDR's

variable "project_vpc_cidr_range" {
  type = "map"
  default = {
    static = "10.0.0.0/16"
    baqa = "10.1.0.0/16"
    test = "10.2.0.0/16"
  }
}

# SUBNET CIDR's

variable "public_a_cidr_range" {
  type = "map"
  default = {
    static = "10.0.5.0/24"
    baqa = "10.1.5.0/24"
    test = "10.2.5.0/24"
  }
}

variable "public_b_cidr_range" {
  type = "map"
  default = {
    static = "10.0.6.0/24"
    baqa = "10.1.6.0/24"
    test = "10.2.6.0/24"
  }
}

variable "private_a_cidr_range" {
  type = "map"
  default = {
    static = "10.0.3.0/24"
    baqa = "10.1.3.0/24"
    test = "10.2.3.0/24"
  }
}

variable "private_b_cidr_range" {
  type = "map"
  default = {
    static = "10.0.4.0/24"
    baqa = "10.1.4.0/24"
    test = "10.2.4.0/24"
  }
}


# IPs

# -----Bitbucket-----

variable "bitbucket1_cidr_range" {
  default = "104.192.143.0/24"
}

variable "bitbucket2_cidr_range" {
  default = "34.198.203.127/32"
}

variable "bitbucket3_cidr_range" {
  default = "34.198.178.64/32"
}

variable "bitbucket4_cidr_range" {
  default = "34.198.32.85/32"
}

# -----Homes-----
