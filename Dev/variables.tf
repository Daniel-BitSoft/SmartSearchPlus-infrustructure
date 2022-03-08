variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "prod"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-east-1"
}

variable "aws-region" {
  type        = string
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws-access-key" {
  type = string
}

variable "aws-secret-key" {
  type = string
}

# variable "application-secrets" {
#  description = "A map of secrets that is passed into the application. Formatted like ENV_VAR = VALUE"
#  type        = map
#}


variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "a list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.0.0/20", "10.0.32.0/20"]
}

variable "db_private_subnets" {
  description = "a list of CIDRs for private subnets in your VPC for RDS to use, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "public_subnets" {
  description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.16.0/20", "10.0.48.0/20"]
}

# EC2 Variables
variable "health_check_path" {
  description = "Http path for task health check"
  default     = "/"
}

variable "ss_app_image_id" {
  description = "ec2 image id" 
}

variable "ss_app_ec2_type" {
  description = "type of ec2 i.e. t2.micro" 
}

variable "bastion_ami" {
    description = "database name"
}

#variable "tsl_certificate_arn" {
#  description = "The ARN of the certificate that the ALB uses for https"
#}

# RDS variables
variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "RDS root user username"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
    description = "backup retention period in days"
}

variable "engine" {
    description = "database name"
}

variable "engine_version" {
    description = "database name"
}

variable "rds_instance_type" {
    description = "instance type"
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
