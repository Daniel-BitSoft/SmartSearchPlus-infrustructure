name                 = "ssp"
environment          = "prod"
availability_zones   = ["us-west-1a", "us-west-1b"]
private_subnets      = ["10.0.0.0/24", "10.0.2.0/24"]
public_subnets       = ["10.0.6.0/24", "10.0.8.0/24"]
#tsl_certificate_arn = "mycertificatearn"

# RDS configs:
db_private_subnets      = ["10.0.4.0/24", "10.0.5.0/24"]
backup_retention_period = 1
engine                  = "aurora-mysql"
engine_version          = "5.7.mysql_aurora.2.10.2"
rds_instance_type       = "db.r5.xlarge"

# EC2 instances:
bastion_ami                 = "ami-0573b70afecda915d"

ss_app_image_id             = "ami-0573b70afecda915d"
ss_app_ec2_type             = "m5.large"

app_api_image_id            = "ami-0573b70afecda915d"
app_api_ec2_type            = "m5.large"

api_image_id                = "ami-0573b70afecda915d"
api_ec2_type                = "m5.large"