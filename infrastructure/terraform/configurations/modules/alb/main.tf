resource "aws_alb_target_group" "simple-app" {
  name     = "${var.name}"
  port     = "${var.target_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  stickiness {
    type = "lb_cookie"
  }
}

resource "aws_alb" "simple-app" {
  name            = "${var.name}"
  subnets         = ["${var.subnets}"]
  security_groups = ["${var.security_groups}"]
}

resource "aws_alb_listener" "simple-app" {
  load_balancer_arn = "${aws_alb.simple-app.id}"
  port              = "${var.listener_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.simple-app.id}"
    type             = "forward"
  }
}
