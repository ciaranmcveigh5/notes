output "ecs_cluster_id" {
  value = "${aws_ecs_cluster.example_cluster.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.ecs_cluster_instances.name}"
}
