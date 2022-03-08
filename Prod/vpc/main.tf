resource "aws_vpc" "main-vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.name}-vpc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "main-ig" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name        = "${var.name}-igw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main-natgw" {
  count        = length(var.private_subnets)
  #count         = 1
  allocation_id = element(aws_eip.natgw-ip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main-ig]

  tags = {
    Name        = "${var.name}-nat-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_eip" "natgw-ip" {
  count = length(var.private_subnets)
  vpc = true

  tags = {
    Name        = "${var.name}-eip-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)

  tags = {
    Name        = "${var.name}-private-subnet-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_subnet" "db_private" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = element(var.db_private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.db_private_subnets)

  tags = {
    Name        = "${var.name}-db_private-subnet-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.name}-public-subnet-${var.environment}-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name        = "${var.name}-routing-table-public"
    Environment = var.environment
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-ig.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name        = "${var.name}-routing-table-private-${format("%03d", count.index+1)}"
    Environment = var.environment
  }
}

resource "aws_route" "private" {
  count                  = length(compact(var.private_subnets))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main-natgw.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

output "id" {
  value = aws_vpc.main-vpc.id
}

output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}

output "rds_subnets" {
  value = aws_subnet.db_private
}