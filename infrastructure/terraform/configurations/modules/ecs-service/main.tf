# ECS SERVICE

resource "aws_ecs_service" "service" {
  name = "${var.name}"
  cluster = "${var.ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count = "${var.desired_count}"
  iam_role = "${var.iam_role}"

  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent = "${var.deployment_maximum_percent}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name = "${var.name}"
    container_port = "${var.container_port}"
  }
}

# TASK DEFINITION

resource "aws_ecs_task_definition" "task" {
  family = "${var.name}"
  container_definitions = "${var.task}"
}
