resource "aws_security_group" "alb" {
  name   = "${var.name}-sg-alb-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-sg-alb-${var.environment}"
    Environment = var.environment
  }
}


resource "aws_security_group" "rds_sg" {
  name   = "${var.name}-sg-rds-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "crm_rds"
  }
}

resource "aws_security_group" "bastion" {
  name   = "${var.name}-bastion-sg-${var.environment}"
  vpc_id = var.vpc_id

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-bastion-sg-${var.environment}"
    Environment = var.environment
  }
}

// use this only on ec2 instances inside private subnet to allow ssh from bastion
resource "aws_security_group" "ssh_ec2_sg" {
  name   = "${var.name}-sg-ec2-${var.environment}"
  vpc_id = var.vpc_id

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-ssh_ec2_sg-${var.environment}"
    Environment = var.environment
  }
}


output "alb" {
  value = aws_security_group.alb.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "bastion_sg" {
  value = aws_security_group.bastion.id
}

output "ssh_ec2_sg_id" {
  value = aws_security_group.ssh_ec2_sg.id
}
