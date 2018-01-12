output "target_group" {
  value = "${aws_alb_target_group.simple-app.id}"
}
