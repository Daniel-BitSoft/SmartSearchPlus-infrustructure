# EC2 instances under auto scaling:

# 1) smartsearch app
#------------------------------------------------
resource "aws_autoscaling_group" "ss_app_asg" {
  name                      = "${var.name}-ss-app-asg-${var.environment}"
  launch_configuration      = "${aws_launch_configuration.ss_app_lc.id}"
  desired_capacity          = length(var.private_subnets)
  max_size                  = length(var.private_subnets) * 5
  min_size                  = length(var.private_subnets)
  health_check_grace_period = 300
  health_check_type         = "ELB" #This will cause the ASG to replace the instance if the ELB health check fails
  vpc_zone_identifier       = var.private_subnets.*.id
  target_group_arns         = [var.ss_app_tg_arn]
    
  tag {
    key                 = "Name"
    value               = "${var.name}-ss-app-ec2-${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "ss_app_lc" {
  name                        = "${var.name}-ss-app-lc-${var.environment}"
  image_id                    = var.ss_app_image_id
  instance_type               = var.ss_app_ec2_type
  key_name                    = "crm-asg-key" 
  security_groups             = ["${var.bastion_sg}", "${var.alb_security_group}", "${var.ssh_ec2_sg_id}"]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo touch /var/www/html/index.html
              sudo echo "Hello World From ss_app!" > /var/www/html/index.html
              sudo systemctl start httpd

              EOF

  lifecycle {
    create_before_destroy = true
  }

  depends_on                = [aws_iam_role.ec2role]
}

output "ss_app_asg" {
   value = aws_autoscaling_group.ss_app_asg.id
}


# scale up policy with cpu alarm
resource "aws_autoscaling_policy" "ss_app_scaleup" {
    name = "ss-app-asp-scaleup"
    autoscaling_group_name = "${aws_autoscaling_group.ss_app_asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "ss_app_cpu_up_alarm" {
    alarm_name = "ss_app_cpu_up_alarm"
    alarm_description = "ss_app_cpu_up_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "60"
    dimensions = {
      "AutoScalingGroupName" = "${aws_autoscaling_group.ss_app_asg.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.ss_app_scaleup.arn}"]
}

# scale down policy with cpu alarm
resource "aws_autoscaling_policy" "ss_app_scaledown" {
    name = "ss_app_scaledown"
    autoscaling_group_name = "${aws_autoscaling_group.ss_app_asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "-1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "ss_app_cpu_down_alarm" {
    alarm_name = "ss_app_cpu_down_alarm"
    alarm_description = "ss_app_cpu_down_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "10"
    dimensions = {
        "AutoScalingGroupName" = "${aws_autoscaling_group.ss_app_asg.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.ss_app_scaledown.arn}"]
}

# Give above EC2 instances access to s3 and rds
# ------------------------------------------------
data "aws_iam_policy_document" "assumepolicy" {
  statement {
    actions = [
    "sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2role" {
  name                = "${var.name}-ec2role-${var.environment}"
  description         = "Role to grant ec2 instances access various aws resources"
  assume_role_policy  = data.aws_iam_policy_document.assumepolicy.json
}

resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role        = aws_iam_role.ec2role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  depends_on  = [aws_iam_role.ec2role]
}

resource "aws_iam_role_policy_attachment" "ec2_rds" {
  role        = aws_iam_role.ec2role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  depends_on  = [aws_iam_role.ec2role]
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name}-ec2profile-${var.environment}"
  role = aws_iam_role.ec2role.name
}

# bastion host
# ------------------------------------------------
resource "aws_instance" "bastionhost" {
  ami                         = var.bastion_ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.bastion_sg]
  subnet_id                   = element(var.public_subnets, 0).id
  key_name                    = "bastion-key"
  tags = {
    Name        = "${var.name}-bastionhost-${var.environment}"
    Environment = var.environment
  }
} 

# 2) App API
#-------------------------------------------------
resource "aws_autoscaling_group" "app_api_asg" {
  name                      = "${var.name}-app-api-asg-${var.environment}"
  launch_configuration      = "${aws_launch_configuration.app_api_lc.id}"
  desired_capacity          = length(var.private_subnets)
  max_size                  = length(var.private_subnets) * 5
  min_size                  = length(var.private_subnets)
  health_check_grace_period = 300
  health_check_type         = "ELB" #This will cause the ASG to replace the instance if the ELB health check fails
  vpc_zone_identifier       = var.private_subnets.*.id
  target_group_arns         = [var.app_api_tg_arn]
  
  tag {
    key                 = "Name"
    value               = "${var.name}-app-api-ec2-${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "app_api_lc" {
  name                        = "${var.name}-app-api-lc-${var.environment}"
  image_id                    = var.app_api_image_id
  instance_type               = var.app_api_ec2_type
  key_name                    = "crm-asg-key" 
  security_groups             = ["${var.bastion_sg}", "${var.alb_security_group}", "${var.ssh_ec2_sg_id}"]
  associate_public_ip_address = false
  
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo touch /var/www/html/index.html
              sudo echo "Hello World From app-api!" > /var/www/html/index.html
              sudo systemctl start httpd

              EOF

  lifecycle {
    create_before_destroy = true
  }
}

output "app_api_asg" {
   value = aws_autoscaling_group.app_api_asg.id
}

# scale up policy with cpu alarm
resource "aws_autoscaling_policy" "app_api_scaleup" {
    name = "ss-app-asp-scaleup"
    autoscaling_group_name = "${aws_autoscaling_group.app_api_asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "app_api_cpu_up_alarm" {
    alarm_name = "app_api_cpu_up_alarm"
    alarm_description = "app_api_cpu_up_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "60"
    dimensions = {
      "AutoScalingGroupName" = "${aws_autoscaling_group.app_api_asg.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.app_api_scaleup.arn}"]
}

# scale down policy with cpu alarm
resource "aws_autoscaling_policy" "app_api_scaledown" {
    name = "app_api_scaledown"
    autoscaling_group_name = "${aws_autoscaling_group.app_api_asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "-1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "app_api_cpu_down_alarm" {
    alarm_name = "app_api_cpu_down_alarm"
    alarm_description = "app_api_cpu_down_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "10"
    dimensions = {
        "AutoScalingGroupName" = "${aws_autoscaling_group.app_api_asg.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.app_api_scaledown.arn}"]
}


# 3) API
#-------------------------------------------------
resource "aws_autoscaling_group" "api_asg" {
  name                      = "${var.name}-api-asg-${var.environment}"
  launch_configuration      = "${aws_launch_configuration.api_lc.id}"
  desired_capacity          = length(var.private_subnets)
  max_size                  = length(var.private_subnets) * 5
  min_size                  = length(var.private_subnets)
  health_check_grace_period = 300
  health_check_type         = "ELB" #This will cause the ASG to replace the instance if the ELB health check fails
  vpc_zone_identifier       = var.private_subnets.*.id
  target_group_arns         = [var.api_tg_arn]
  
  tag {
    key                 = "Name"
    value               = "${var.name}-api-ec2-${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "api_lc" {
  name                        = "${var.name}-api-lc-${var.environment}"
  image_id                    = var.api_image_id
  instance_type               = var.api_ec2_type
  key_name                    = "crm-asg-key" 
  security_groups             = ["${var.bastion_sg}", "${var.alb_security_group}", "${var.ssh_ec2_sg_id}"]
  associate_public_ip_address = false
  
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo touch /var/www/html/index.html
              sudo echo "Hello World From API!" > /var/www/html/index.html
              sudo systemctl start httpd

              EOF

  lifecycle {
    create_before_destroy = true
  }
}

output "api_asg" {
   value = aws_autoscaling_group.api_asg.id
}

# scale up policy with cpu alarm
resource "aws_autoscaling_policy" "api_scaleup" {
    name = "ss-app-asp-scaleup"
    autoscaling_group_name = "${aws_autoscaling_group.api_asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "api_cpu_up_alarm" {
    alarm_name = "api_cpu_up_alarm"
    alarm_description = "api_cpu_up_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "60"
    dimensions = {
      "AutoScalingGroupName" = "${aws_autoscaling_group.api_asg.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.api_scaleup.arn}"]
}

# scale down policy with cpu alarm
resource "aws_autoscaling_policy" "api_scaledown" {
    name = "api_scaledown"
    autoscaling_group_name = "${aws_autoscaling_group.api_asg.name}"
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = "-1"
    cooldown = "300"
    policy_type = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "api_cpu_down_alarm" {
    alarm_name = "api_cpu_down_alarm"
    alarm_description = "api_cpu_down_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods = "2"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = "120"
    statistic = "Average"
    threshold = "10"
    dimensions = {
        "AutoScalingGroupName" = "${aws_autoscaling_group.api_asg.name}"
    }
    actions_enabled = true
    alarm_actions = ["${aws_autoscaling_policy.api_scaledown.arn}"]
}