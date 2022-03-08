resource "aws_db_subnet_group" "rds_subg" {
  name       = "${var.name}-rds-subnetgroup-${var.environment}"
  subnet_ids = var.subnets.*.id

  tags = {
    Name = "rds_crm_subnet_group"
  }
}


resource "aws_rds_cluster" "rds_cluster" {
  backup_retention_period         = var.backup_retention_period
  cluster_identifier              = "${var.name}-${var.environment}"
  db_subnet_group_name            = aws_db_subnet_group.rds_subg.name
  deletion_protection             = false
  enabled_cloudwatch_logs_exports = []
  engine                          = var.engine
  engine_version                  = var.engine_version
  master_username                 = var.db_username
  master_password                 = var.db_password
  #port                            = var.db_port
  skip_final_snapshot             = true
  storage_encrypted               = true
  vpc_security_group_ids          = [var.rds_sg_id, var.bastion_sg_id]
  tags = {
    Name        = "${var.name}-rds-cluster-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "rds_cluster_instances" {
  count              = 2
  identifier         = "${var.name}-rds-intance-${var.environment}-${count.index}"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = var.rds_instance_type
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version
}