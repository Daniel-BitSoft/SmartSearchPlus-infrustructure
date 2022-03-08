variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
  default     = "prod"
}

variable "subnets" {
    description = "aws RDS subnets"
}

variable "rds_sg_id" {
    description = "RDS security group id"
}

variable "bastion_sg_id" {
  default = "Bastion security group id"
}

variable "db_password" {
    description = "RDS database password"
}

variable "db_username" {
    description = "RDS database username"
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
    description = "instance type. i.e. db.t3.small"
}