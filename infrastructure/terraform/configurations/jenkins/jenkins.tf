provider "aws" {
    region = "eu-west-2"
}

# AUTO SCALING GROUP

resource "aws_autoscaling_group" "ecs-cluster-jenkins" {
    availability_zones = ["${var.availability_zone}"]
    name = "ECS ${var.ecs_cluster_name}"
    min_size = "${var.autoscale_min}"
    max_size = "${var.autoscale_max}"
    desired_capacity = "${var.autoscale_desired}"
    health_check_type = "EC2"
    termination_policies = ["NewestInstance"]
    protect_from_scale_in = true
    launch_configuration = "${aws_launch_configuration.ecs-jenkins.name}"
    vpc_zone_identifier = ["${data.terraform_remote_state.vpc.project_public_subnet}"]
    enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
    force_delete = true
}

resource "aws_launch_configuration" "ecs-jenkins" {
    image_id = "${var.amis}"
    instance_type = "${var.instance_type}"
    security_groups = ["${data.terraform_remote_state.vpc.project_base_sg}", "${aws_security_group.jenkins.id}"]
    iam_instance_profile = "${aws_iam_instance_profile.jenkins_admin.name}"
    # TODO: is there a good way to make the key configurable sanely?
    key_name = "${aws_key_pair.jenkins_key.key_name}"
    associate_public_ip_address = true
    user_data = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_policy" "autopolicy-up" {
  name = "cpu-scale-up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster-jenkins.name}"
}

resource "aws_cloudwatch_metric_alarm" "asg-cpu-high-alarm" {
  alarm_name = "jenkins-asg-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = "${var.cpu_high_limit}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs-cluster-jenkins.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.autopolicy-up.arn}"]

}

resource "aws_autoscaling_policy" "autopolicy-down" {
  name = "cpu-scale-down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs-cluster-jenkins.name}"
}

resource "aws_cloudwatch_metric_alarm" "asg-cpu-low-alarm" {
  alarm_name = "jenkins-asg-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = "${var.cpu_low_limit}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs-cluster-jenkins.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.autopolicy-down.arn}"]

}

# SECURITY GROUP

resource "aws_security_group" "jenkins" {
    vpc_id     = "${data.terraform_remote_state.vpc.project_vpc}"
    name        = "jenkins"
    description = "jenkins security group"

    ingress {
        from_port   = "${var.jenkins_port}"
        to_port     = "${var.jenkins_port}"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port   = "${var.bitbucket_port}"
    to_port     = "${var.bitbucket_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# CLUSTER

resource "aws_ecs_cluster" "jenkins" {
    name = "${var.ecs_cluster_name}"
}

# ECS TASK DEFINITIONS

resource "aws_ecs_task_definition" "jenkins" {
    family = "jenkins"
    container_definitions = "${file("./task-definitions/jenkins.json")}"

    volume {
        name = "dockerbin"
        host_path = "/usr/bin/docker"
    }

    volume {
        name = "dockersock"
        host_path = "/var/run/docker.sock"
    }

    # volume {
    #   name = "jenkins"
    #   host_path = "/home/ec2-user"
    # }
}

# ECS SERVICE

resource "aws_ecs_service" "jenkins" {
    name = "jenkins"
    cluster = "${aws_ecs_cluster.jenkins.id}"
    task_definition = "${aws_ecs_task_definition.jenkins.arn}"
    iam_role = "${aws_iam_role.jenkins_admin.arn}"
    desired_count = "${var.container_desired}"
    deployment_maximum_percent = "${var.container_max_percent}"
    deployment_minimum_healthy_percent = "${var.container_min_percent}"
    # depends_on = ["aws_iam_role_policy.ecs_service_role_policy"]

    placement_strategy {
      type  = "binpack"
      field = "cpu"
    }

    load_balancer {
      target_group_arn = "${aws_alb_target_group.jenkins_test.id}"
      container_name = "jenkins"
      container_port = "${var.jenkins_port}"
    }

    depends_on = [
      "aws_alb_listener.jenkins"
    ]
}

resource "aws_cloudwatch_metric_alarm" "ecs-cpu-high-alarm" {
  alarm_name = "jenkins-ecs-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = "${var.cpu_high_limit}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.jenkins.name}"
    ServiceName = "${aws_ecs_service.jenkins.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_appautoscaling_policy.jenkins_scale_up.arn}"]

}

resource "aws_cloudwatch_metric_alarm" "ecs-cpu-low-alarm" {
  alarm_name = "jenkins-ecs-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 120
  statistic = "Average"
  threshold = "${var.cpu_low_limit}"

  dimensions {
    ClusterName = "${aws_ecs_cluster.jenkins.name}"
    ServiceName = "${aws_ecs_service.jenkins.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_appautoscaling_policy.jenkins_scale_down.arn}"]

}

resource "aws_appautoscaling_policy" "jenkins_scale_up" {
  name = "jenkins-scale-up"
  resource_id = "service/${aws_ecs_cluster.jenkins.name}/${aws_ecs_service.jenkins.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  adjustment_type = "ChangeInCapacity"
  cooldown = 120
  metric_aggregation_type = "Average"
  service_namespace = "ecs"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment = 1
  }

  depends_on = ["aws_appautoscaling_target.jenkins"]
}

resource "aws_appautoscaling_policy" "jenkins_scale_down" {
  name = "jenkins-scale-down"
  resource_id = "service/${aws_ecs_cluster.jenkins.name}/${aws_ecs_service.jenkins.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  adjustment_type = "ChangeInCapacity"
  cooldown = 120
  metric_aggregation_type = "Average"
  service_namespace = "ecs"

  step_adjustment {
     metric_interval_upper_bound = 0
     scaling_adjustment = -1
   }

  depends_on = ["aws_appautoscaling_target.jenkins"]
}

resource "aws_appautoscaling_target" "jenkins" {
  max_capacity       = "${var.container_max}"
  min_capacity       = "${var.container_min}"
  resource_id        = "service/${aws_ecs_cluster.jenkins.name}/${aws_ecs_service.jenkins.name}"
  role_arn           = "arn:aws:iam::123:role/ecsAutoscaleRole"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CLUSTER IAM

resource "aws_iam_role" "jenkins_admin" {
    name = "jenkins_admin_role"
    assume_role_policy = "${file("policies/jenkins-admin-role.json")}"
}

resource "aws_iam_role_policy" "jenkins_admin_policy" {
    name = "jenkins_admin_policy"
    policy = "${file("policies/jenkins-admin-policy.json")}"
    role = "${aws_iam_role.jenkins_admin.id}"
}

resource "aws_iam_instance_profile" "jenkins_admin" {
    name = "jenkins-admin-profile"
    path = "/"
    role = "${aws_iam_role.jenkins_admin.name}"
}

# ALB

resource "aws_alb_target_group" "jenkins_test" {
  name     = "jenkins-test"
  port     = "${var.http_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.project_vpc}"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path = "/login"
  }
}

resource "aws_alb_target_group" "jenkins_sonar" {
  name     = "jenkins-sonar"
  port     = "${var.http_port}"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.project_vpc}"

  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_alb" "jenkins" {
  name            = "jenkins-alb"
  subnets         = ["${data.terraform_remote_state.vpc.project_public_subnet}", "${data.terraform_remote_state.vpc.project_public_subnet_b}"]
  security_groups = ["${aws_security_group.jenkins.id}", "${data.terraform_remote_state.vpc.project_base_sg}"]
}

resource "aws_alb_listener" "jenkins" {
  load_balancer_arn = "${aws_alb.jenkins.id}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins_test.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "sonar_routing" {
  listener_arn = "${aws_alb_listener.jenkins.arn}"
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.jenkins_sonar.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/sonar"]
  }
}

# ROUTE 53

resource "aws_route53_record" "jenkins" {
  zone_id = "${data.terraform_remote_state.vpc.project_zone_id}"
  name    = "jenkins.${data.terraform_remote_state.vpc.project_zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_alb.jenkins.dns_name}"]
}

# KEY PAIR

resource "aws_key_pair" "jenkins_key" {
    key_name   = "id_project"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdSID14SCVumGiJP+7ugDN4DFUAAwe8GEDBOV3gS4WjerE9/qEG10wY9nviej4uZk3d6Hus15I1nE0b1/qG+oF3c/+9Q6i6e1xss+bzsS02tZpvo2VL90kbg47blbaYwrqXJe9ud/Hs6FIcPfWPD8lxYdHRdj6AVmY7bdr8vhascHlejBgNBsoi/bTBMQCqXcy9zjhp5/wligC+PsE0uR6zQVrXXOORSLGsfgjmoaF+crxMv3ugG79f4p1sRSyhdBFM5lZd3SE43tN/pW+HSOX+aumi1w0FOn+mHX/GLDkShQDIqOribj10b3E77k45NWQkz5cZ5jAeorTKDFrN39D project jenkins"
}
