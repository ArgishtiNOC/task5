resource "aws_launch_configuration" "task4" {
  name_prefix     = "task4"
  image_id        = "${var.aws_launch_configuration_image_id}"
  instance_type   = "${var.aws_launch_configuration_instance_type}"
  user_data       = file("userdata.sh")
  security_groups = var.aws_launch_configuration_security_group
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "task4" {
  name                 = "task4"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.task4.name
  vpc_zone_identifier  = var.aws_autoscaling_group_vpc_zone_identifier

  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "task4"
    propagate_at_launch = true
  }
}

resource "aws_lb" "task4" {
  name               = "task4"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.task4_lb.id]
  subnet_mapping {
    subnet_id = var.aws_lb_subnet_mapping_1
    allocation_id = null
  }  
  subnet_mapping {
    subnet_id = var.aws_lb_subnet_mapping_2  
    allocation_id = null
  } 

}

resource "aws_lb_listener" "task4" {
  load_balancer_arn = aws_lb.task4.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task4.arn
  }
}

resource "aws_lb_target_group" "task4" {
  name     = "asg-task4"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "task4" {
  target_group_arn = aws_lb_target_group.task4.arn
  target_id        = var.aws_lb_target_group_attachment_target_id 
  port             = 80
}

resource "aws_autoscaling_attachment" "task4" {
  autoscaling_group_name = aws_autoscaling_group.task4.id
  lb_target_group_arn   = aws_lb_target_group.task4.arn
}

resource "aws_security_group" "task4_lb" {
  name = "learn-asg-terramino-lb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
}