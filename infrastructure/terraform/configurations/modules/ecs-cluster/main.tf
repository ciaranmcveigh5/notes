# ECS CLUSTER

resource "aws_ecs_cluster" "example_cluster" {
  name = "${var.name}"
}

# ASG

resource "aws_autoscaling_group" "ecs_cluster_instances" {
  name = "${var.name}"
  min_size = "${var.autoscale_min}"
  max_size = "${var.autoscale_max}"
  desired_capacity = "${var.autoscale_desired}"
  health_check_type = "EC2"
  protect_from_scale_in = true
  launch_configuration = "${aws_launch_configuration.ecs_instance.name}"
  vpc_zone_identifier = ["${var.subnet_ids}"]
  force_delete = true

  tag {
    key = "Name"
    value = "${var.name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "ecs_instance" {
  name_prefix = "${var.name}-"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  iam_instance_profile = "${var.instance_profile}"
  security_groups = ["${var.security_groups}"]
  associate_public_ip_address = true
  image_id = "${var.ami}"
  user_data = <<EOF
#!/bin/bash
echo "ECS_CLUSTER=${var.name}" >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }
}
