# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
}

variable "task" {
  description = "Task defintion."
}

variable "ecs_cluster_id" {
}

variable "container_port" {
}

variable "desired_count" {
}

variable "target_group_arn" {
}

variable "iam_role" {
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "deployment_maximum_percent" {
  default = 200
}

variable "deployment_minimum_healthy_percent" {
  default = 100
}
