variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "subnets" {
  description = "list of subnet IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "alb_security_groups" {
  description = "list of security groups"
}

#variable "alb_tls_cert_arn" {
#  description = "The ARN of the certificate that the ALB uses for https"
#}

variable "health_check_path" {
  description = "Path to check if the service is healthy, e.g. \"/status\""
}

// Auto scaling groups to add to load balancer
variable "ss_app_asg" {
  description = "auto scaling group id"
}

variable "app_api_asg" {
  description = "auto scaling group id"
}

variable "api_asg" {
  description = "auto scaling group id"
}
