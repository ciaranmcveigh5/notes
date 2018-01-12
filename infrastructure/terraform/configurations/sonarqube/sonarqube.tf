provider "aws" {
	region = "eu-west-2"
}

# AUTO SCALING GROUP

resource "aws_autoscaling_group" "ecs-cluster-sonarqube" {
    availability_zones = ["${var.availability_zone}"]
    name = "ECS ${var.ecs_cluster_name}"
    min_size = "${var.autoscale_min}"
    max_size = "${var.autoscale_max}"
    desired_capacity = "${var.autoscale_desired}"
    health_check_type = "EC2"
		termination_policies = ["NewestInstance"]
		protect_from_scale_in = true
    launch_configuration = "${aws_launch_configuration.ecs-sonarqube.name}"
    vpc_zone_identifier = ["${data.terraform_remote_state.vpc.project_public_subnet}"]
		enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
		force_delete = true
}

resource "aws_launch_configuration" "ecs-sonarqube" {
    image_id = "${var.amis}"
    instance_type = "${var.instance_type}"
    security_groups = ["${data.terraform_remote_state.vpc.project_base_sg}", "${aws_security_group.sonarqube.id}"]
    iam_instance_profile = "${data.terraform_remote_state.ecs.ecs}"
    # TODO: is there a good way to make the key configurable sanely?
    key_name = "${data.terraform_remote_state.jenkins.jenkins_key}"
    associate_public_ip_address = true
    user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"

		lifecycle {
				create_before_destroy = true
		}
}

# SECURITY GROUP

resource "aws_security_group" "sonarqube" {
	vpc_id     = "${data.terraform_remote_state.vpc.project_vpc}"
	name        = "sonarqube"
	description = "sonarqube security group"

	ingress {
		from_port   = "${var.sonarqube_port}"
		to_port     = "${var.sonarqube_port}"
		protocol    = "tcp"
		cidr_blocks = ["${var}"]
	}

}

# RENDER TASK DEFINITION

data "template_file" "task_definition" {
    template = "${file("./task-definitions/sonarqube.json.tpl")}"
    vars {
        git_hash = "${var.hash}"
    }
}

# CLUSTER

resource "aws_ecs_cluster" "sonarqube" {
    name = "${var.ecs_cluster_name}"
}

# ECS TASK DEFINITIONS

resource "aws_ecs_task_definition" "sonarqube" {
    family = "sonarqube"
    container_definitions = "${data.template_file.task_definition.rendered}"
}

# ECS SERVICE

resource "aws_ecs_service" "sonarqube" {
    name = "sonarqube"
    cluster = "${aws_ecs_cluster.sonarqube.id}"
    task_definition = "${aws_ecs_task_definition.sonarqube.arn}"
    iam_role = "${data.terraform_remote_state.jenkins.jenkins_iam}" // ecs service iam was stopping containers from registering on ALB
    desired_count = "${var.container_desired}"
		deployment_maximum_percent = "${var.container_max_percent}"
    deployment_minimum_healthy_percent = "${var.container_min_percent}"
    # depends_on = ["aws_iam_role_policy.ecs_service_role_policy"]

    load_balancer {
        target_group_arn = "${aws_alb_target_group.sonarqube.id}"
        container_name = "sonarqube"
        container_port = "${var.sonarqube_port}"
    }

		depends_on = [
			"aws_alb_listener.sonarqube"
		]
}

# ECS ALB

resource "aws_alb_target_group" "sonarqube" {
  name     = "sonarqube"
  port     = "${var.http_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.project_vpc}"

  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_alb" "sonarqube" {
  name            = "sonarqube-alb"
  subnets         = ["${data.terraform_remote_state.vpc.project_public_subnet}", "${data.terraform_remote_state.vpc.project_public_subnet_b}"]
  security_groups = ["${data.terraform_remote_state.vpc.project_base_sg}", "${aws_security_group.sonarqube.id}"]
}

resource "aws_alb_listener" "sonarqube" {
  load_balancer_arn = "${aws_alb.sonarqube.id}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.sonarqube.id}"
    type             = "forward"
  }
}

# ROUTE 53

resource "aws_route53_record" "sonarqube" {
  zone_id = "${data.terraform_remote_state.vpc.project_zone_id}"
  name    = "sonarqube.${data.terraform_remote_state.vpc.project_zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_alb.sonarqube.dns_name}"]
}
