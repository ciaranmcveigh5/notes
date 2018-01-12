# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
}

variable "autoscale_min" {
}

variable "autoscale_max" {
}

variable "autoscale_desired" {
}

variable "instance_type" {
}

variable "subnet_ids" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

variable "key_name" {
}

variable "instance_profile" {
}

variable "ami" {
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "allow_inbound_ports_and_cidr_blocks" {
  type = "map"
  default = {}
}

variable "key_pair_name" {
  default = ""
}

variable "allow_ssh_from_cidr_blocks" {
  type = "list"
  default = []
}
