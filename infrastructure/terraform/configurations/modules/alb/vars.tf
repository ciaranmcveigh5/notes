variable "name" {
}

variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "target_port" {
}

variable "listener_port" {
}

variable "vpc_id" {
}
