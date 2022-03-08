resource "aws_lb" "main" {
  name               = "${var.name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.subnets.*.id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.name}-alb-${var.environment}"
    Environment = var.environment
  }
}

# 1) smartsearch app
# --------------------------------------------
resource "aws_lb_target_group" "ss-app-tg" {
  name        = "${var.name}-ss-app-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

 # stickiness {    
  #  type            = "lb_cookie"    
  #  cookie_duration = 1800    
  #  enabled         = true 
 # } 

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "10"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.name}-ss-app-tg-${var.environment}"
    Environment = var.environment
  }
}

# Redirect to https listener
resource "aws_alb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {    
    target_group_arn = "${aws_lb_target_group.ss-app-tg.arn}"
    type             = "forward"  
  }

  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  #default_action {
  #  type = "redirect"

  #  redirect {
  #    port        = 443
  #    protocol    = "HTTPS"
  #    status_code = "HTTP_301"
  #  }
  #}
}

resource "aws_lb_listener_rule" "ss_app_lrule" {
  listener_arn = aws_alb_listener.lb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ss-app-tg.arn
  }

  condition {
    path_pattern {
      values = ["/ssa*"]
    }
  }
}

resource "aws_autoscaling_attachment" "ss_app_autoscale" {
  lb_target_group_arn   = aws_lb_target_group.ss-app-tg.arn
  autoscaling_group_name = var.ss_app_asg
}

output "ss_app_tg_arn" {
  value = aws_lb_target_group.ss-app-tg.arn
}

# 2) App API
# --------------------------------------------
resource "aws_lb_target_group" "app-api-tg" {
  name        = "${var.name}-app-api-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

 # stickiness {    
  #  type            = "lb_cookie"    
  #  cookie_duration = 1800    
  #  enabled         = true 
 # } 

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "10"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.name}-app-api-tg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_listener_rule" "app_api_lrule" {
  listener_arn = aws_alb_listener.lb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-api-tg.arn
  }

  condition {
    path_pattern {
      values = ["/app-api*"]
    }
  }
}

resource "aws_autoscaling_attachment" "app_api_autoscale" {
  lb_target_group_arn   = aws_lb_target_group.app-api-tg.arn
  autoscaling_group_name = var.app_api_asg
}

output "app_api_tg_arn" {
  value = aws_lb_target_group.app-api-tg.arn
}

# 3) API
# --------------------------------------------
resource "aws_lb_target_group" "api-tg" {
  name        = "${var.name}-api-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

 # stickiness {    
  #  type            = "lb_cookie"    
  #  cookie_duration = 1800    
  #  enabled         = true 
 # } 

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "10"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "${var.name}-api-tg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_listener_rule" "api_lrule" {
  listener_arn = aws_alb_listener.lb_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api-tg.arn
  }

  condition {
    path_pattern {
      values = ["/api*"]
    }
  }
}

resource "aws_autoscaling_attachment" "api_autoscale" {
  lb_target_group_arn   = aws_lb_target_group.api-tg.arn
  autoscaling_group_name = var.api_asg
}

output "api_tg_arn" {
  value = aws_lb_target_group.api-tg.arn
}



/*
# Redirect traffic to target group
resource "aws_alb_listener" "https" {
    load_balancer_arn = aws_lb.main.id
    port              = 443
    protocol          = "HTTPS"

    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = var.alb_tls_cert_arn

    default_action {
        target_group_arn = aws_alb_target_group.main.id
        type             = "forward"
    }
}
*/