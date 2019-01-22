# ECS cluster
resource "aws_ecs_cluster" "test-cluster" {
  name = "test"
}
#Compute
resource "aws_autoscaling_group" "test-cluster" {
  name                      = "test-cluster"
  vpc_zone_identifier       = ["${var.subnets}"]
  min_size                  = "1"
  max_size                  = "6"
  desired_capacity          = "4"
  launch_configuration      = "${aws_launch_configuration.test-cluster-lc.name}"
  health_check_grace_period = 120
  default_cooldown          = 30
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "ECS-test"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "test-cluster" {
  name                      = "test-ecs-auto-scaling"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "90"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.test-cluster.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}

resource "aws_launch_configuration" "test-cluster-lc" {
  name_prefix     = "test-cluster-lc"
  security_groups = ["${var.security_groups}"]

  # key_name                    = "${aws_key_pair.demodev.key_name}"
  image_id                    = "${data.aws_ami.latest_ecs.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-ec2-role.id}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}