variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "prod"
}

variable "private_subnets" {
  description = "private subnets"
}

variable "public_subnets" {
  description = "public subnets"
}

variable "ss_app_tg_arn" {
  description = "alb target group"
}

variable "app_api_tg_arn" {
  description = "alb target group"
}

variable "api_tg_arn" {
  description = "alb target group"
}

variable "ss_app_image_id" {
  description = "ec2 ami image"
}

variable "ss_app_ec2_type" {
  description = "ec2 type"
}

variable "bastion_ami" {
    description = "bastion host ami"
}

variable "bastion_sg" {
    description = "bastion host security group"
}

variable "alb_security_group" {
  default = "ALB security group"
}

variable "app_api_image_id" {
  default = "ec2 ami image"
}

variable "app_api_ec2_type" {
  default = "ec2 type"
}

variable "api_image_id" {
  default = "ec2 ami image"
}

variable "api_ec2_type" {
  default = "ec2 type"

}

variable "ssh_ec2_sg_id" {
  description = "security group id for private ec2"
}


