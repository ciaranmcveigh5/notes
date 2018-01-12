variable "region" {
    description = "The AWS region to create resources in."
    default = "eu-west-2"
}

# TODO: support multiple availability zones, and default to it.
variable "availability_zone" {
    description = "The availability zone"
    default = "eu-west-2a"
}

variable "ecs_cluster_name" {
    description = "The name of the Amazon ECS cluster."
    default = "sonarqube"
}

variable "amis" {
    description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
    # TODO: support other regions.
    default = "ami-0a85946e"
}


variable "autoscale_min" {
    default = "1"
    description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
    default = "1"
    description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
    default = "1"
    description = "Desired autoscale (number of EC2)"
}


variable "instance_type" {
    default = "t2.medium"
}

variable "ssh_pubkey_file" {
    description = "Path to an SSH public key"
    default = "~/.ssh/id_rsa.pub"
}

variable "container_max_percent" {
  default = "200"
}

variable "container_min_percent" {
  default = "0"
}

variable "container_desired" {
  default = "2"
}

variable "hash" {
  default = "latest"
}
