# NGINX Service
resource "aws_ecs_service" "test-service" {
  name            = "v1"
  cluster         = "${aws_ecs_cluster.test-cluster.id}"
  task_definition = "${aws_ecs_task_definition.nginx.arn}"
  desired_count   = 4
  iam_role        = "${aws_iam_role.ecs-service-role.arn}"
  depends_on      = ["aws_iam_role_policy_attachment.ecs-service-attach"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.nginx.id}"
    container_name   = "nginx"
    container_port   = "80"
  }

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family = "test-task"

  container_definitions = <<EOF
[
  {
    "portMappings": [
      {
        "hostPort": 80,
        "protocol": "tcp",
        "containerPort": 80
      }
    ],
    "cpu": 256,
    "memory": 300,
    "image": ${jsonencode(var.nginx_image)},
    "essential": true,
    "name": ${jsonencode(var.nginx_name)},
    "links": [
      ${jsonencode(var.web_name)}
    ],
    "logConfiguration": {
    "logDriver": "awslogs",
      "options": {
        "awslogs-group": ${jsonencode(var.nginx_name)},
        "awslogs-region": ${jsonencode(var.aws_region)},
        "awslogs-stream-prefix": ${jsonencode(var.nginx_name)}
      }
    }
  },
  {
    "portMappings": [
      {
        "hostPort": 5000,
        "protocol": "tcp",
        "containerPort": 5000
      }
    ],
    "cpu": 256,
    "memory": 300,
    "image": ${jsonencode(var.web_image)},
    "essential": true,
    "name": ${jsonencode(var.web_name)},
    "logConfiguration": {
    "logDriver": "awslogs",
      "options": {
        "awslogs-group": ${jsonencode(var.web_name)},
        "awslogs-region": ${jsonencode(var.aws_region)},
        "awslogs-stream-prefix": ${jsonencode(var.web_name)}
      }
    }
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = "/ecs-test/nginx"
}

resource "aws_cloudwatch_log_group" "web_project" {
  name = "/ecs-test/web_project"
}