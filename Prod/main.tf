provider "aws" {
  region     = "us-west-1"
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

terraform {
  backend "s3" {
    bucket  = "terraform-state-smartsearch"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-west-1"
    # dynamodb_table = "terraform-state-lock-dynamo" - uncomment this line once the terraform-state-lock-dynamo has been terraformed
  }
}


#resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
#  name           = "terraform-state-lock-dynamo"
#  hash_key       = "LockID"
#  read_capacity  = 20
#  write_capacity = 20
#  attribute {
#    name = "LockID"
#    type = "S"
#  }
#  tags = {
#    Name = "DynamoDB Terraform State Lock Table"
#  }
#}


module "vpc" {
  source             = "./vpc"
  name               = var.name
  environment        = var.environment
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  db_private_subnets = var.db_private_subnets
}


module "security_groups" {
  source      = "./security-groups"
  name        = var.name
  environment = var.environment
  vpc_id      = module.vpc.id 
}

module "ec2" {
  source                = "./ec2"
  name                  = var.name
  environment           = var.environment
  alb_security_group    = module.security_groups.alb
  private_subnets       = module.vpc.private_subnets
  public_subnets        = module.vpc.public_subnets  
  bastion_ami           = var.bastion_ami
  bastion_sg            = module.security_groups.bastion_sg
  ssh_ec2_sg_id         = module.security_groups.ssh_ec2_sg_id

  # ss app vars
  ss_app_tg_arn         = module.alb.ss_app_tg_arn
  ss_app_image_id       = var.ss_app_image_id
  ss_app_ec2_type       = var.ss_app_ec2_type
  
  # app api vars
  app_api_tg_arn        = module.alb.app_api_tg_arn
  app_api_image_id      = var.app_api_image_id
  app_api_ec2_type      = var.app_api_ec2_type

  # api vars
  api_tg_arn            = module.alb.api_tg_arn
  api_image_id          = var.api_image_id
  api_ec2_type          = var.api_ec2_type
}


module "alb" {
  source              = "./alb"
  name                = var.name
  environment         = var.environment
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets 
  alb_security_groups = [module.security_groups.alb]
# alb_tls_cert_arn    = var.tsl_certificate_arn
  health_check_path   = var.health_check_path
  ss_app_asg          = module.ec2.ss_app_asg
  app_api_asg         = module.ec2.app_api_asg
  api_asg             = module.ec2.api_asg
}

module "rds" {
  source                  = "./rds"
  name                    = var.name
  environment             = var.environment
  subnets                 = module.vpc.rds_subnets
  rds_sg_id               = module.security_groups.rds_sg_id
  bastion_sg_id           = module.security_groups.bastion_sg
  db_password             = var.db_password
  db_username             = var.db_username
  backup_retention_period = var.backup_retention_period
  engine                  = var.engine
  engine_version          = var.engine_version
  rds_instance_type       = var.rds_instance_type
}

module "s3" {
  source  = "./s3" 
  name                  = var.name
  environment           = var.environment
}