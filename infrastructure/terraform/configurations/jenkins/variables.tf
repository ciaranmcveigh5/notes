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
    default = "jenkins"
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
    default = "3"
    description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
    default = "1"
    description = "Desired autoscale (number of EC2)"
}


variable "instance_type" {
    default = "t2.large"
}

variable "ssh_pubkey_file" {
    description = "Path to an SSH public key"
    default = "~/.ssh/id_rsa.pub"
}

variable "cpu_high_limit" {
  default = "60"
  description = "CPU upper limit for cloudwatch alarm"
}

variable "cpu_low_limit" {
  default = "5"
  description = "CPU lower limit for cloudwatch alarm"
}

variable "container_max" {
  default = "5"
}

variable "container_min" {
  default = "1"
}

variable "container_max_percent" {
  default = "200"
}

variable "container_min_percent" {
  default = "100"
}

variable "container_desired" {
  default = "1"
}
