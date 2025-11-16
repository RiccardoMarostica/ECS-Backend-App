resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.vpc_enable_dns_support
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  instance_tenancy     = var.vpc_instance_tenancy

  tags = {
    "Name" = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_subnet_public_a_cidr_block
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.project_name}-${var.environment}-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_subnet_public_b_cidr_block
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${var.project_name}-${var.environment}-public-b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_subnet_private_a_cidr_block
  availability_zone = "${var.aws_region}a"

  tags = {
    "Name" = "${var.project_name}-${var.environment}-private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_subnet_private_b_cidr_block
  availability_zone = "${var.aws_region}b"

  tags = {
    "Name" = "${var.project_name}-${var.environment}-private-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    "Name" = "${var.project_name}-${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.project_name}-${var.environment}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.project_name}-${var.environment}-private"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}