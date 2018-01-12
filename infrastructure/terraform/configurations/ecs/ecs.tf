provider "aws" {
	region = "eu-west-2"
}

# --------------------------------------------------------------------
# ECS CLUSTER
# --------------------------------------------------------------------

module "ecs_cluster" {
  source = "../modules/ecs-cluster"

  name = "${terraform.workspace}-simple-backend"
  autoscale_min = 1
	autoscale_max = 3
	autoscale_desired = 2
	instance_type = "t2.medium"
	instance_profile = "${aws_iam_instance_profile.simple-app.name}"
	security_groups = ["${data.terraform_remote_state.vpc.project_base_sg}"]
	key_name = "${data.terraform_remote_state.jenkins.jenkins_key}"
	ami = "${var.amis}"

  subnet_ids = ["${data.terraform_remote_state.vpc.project_public_subnet}"]
}

# --------------------------------------------------------------------
# RENDER TASK DEFINITION
# --------------------------------------------------------------------

data "template_file" "task_definition" {
    template = "${file("./task-definitions/simple-backend.json.tpl")}"
    vars {
        api-gateway = "${var.hash["api-gateway"]}"
				simple-backend = "${var.hash["simple-backend"]}"
				workspace = "${terraform.workspace}"
    }
}

# --------------------------------------------------------------------
# ECS SERVICE
# --------------------------------------------------------------------

module "simple-backend" {
  source = "../modules/ecs-service"

  name = "${terraform.workspace}-simple-app"
  ecs_cluster_id = "${module.ecs_cluster.ecs_cluster_id}"

  desired_count = 2
	deployment_minimum_healthy_percent = 50
	deployment_maximum_percent = 200
	iam_role = "${aws_iam_role.ecs_service_role.arn}"

  container_port = "${var.simple_app_port}"
  target_group_arn = "${module.simple-backend-alb.target_group}"

  task = "${data.template_file.task_definition.rendered}"

}

# --------------------------------------------------------------------
# ECS ALB
# --------------------------------------------------------------------

module "simple-backend-alb" {
  source = "../modules/alb"

  name = "${terraform.workspace}-simple-app"
	subnets = ["${data.terraform_remote_state.vpc.project_public_subnet}", "${data.terraform_remote_state.vpc.project_public_subnet_b}"]
  security_groups = ["${data.terraform_remote_state.vpc.project_base_sg}"]
	target_port = "${var.http_port}"
	listener_port = "${var.http_port}"
	vpc_id = "${data.terraform_remote_state.vpc.project_vpc}"
}

# --------------------------------------------------------------------
# CLUSTER + SERVICE IAM
# --------------------------------------------------------------------

resource "aws_iam_role" "ecs_host_role" {
    name = "simple_app_host_role"
    assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
    name = "simple_app_instance_role_policy"
    policy = "${file("policies/ecs-instance-role-policy.json")}"
    role = "${aws_iam_role.ecs_host_role.id}"
}

resource "aws_iam_role" "ecs_service_role" {
    name = "simple_app_service_role"
    assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
    name = "simple_app_service_role_policy"
    policy = "${file("policies/ecs-service-role-policy.json")}"
    role = "${aws_iam_role.ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "simple-app" {
    name = "simple-app-instance-profile"
    path = "/"
    role = "${aws_iam_role.ecs_host_role.name}"
}
