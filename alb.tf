# ALB
resource "aws_alb" "test-alb" {
  name            = "test-alb"
  subnets         = ["${var.subnets}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]
  enable_http2    = "true"
  idle_timeout    = 600
}

output "alb_output" {
  value = "${aws_alb.test-alb.dns_name}"
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.test-alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nginx.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "nginx" {
  name       = "nginx"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = "${var.vpc}"
  depends_on = ["aws_alb.test-alb"]

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "${var.vpc}"
  name   = "test-ALB"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}