terraform {
  required_version = ">= 0.12.26"
}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "terratest" {
  cidr_block = var.main_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.tag_name
  }
}

resource "aws_internet_gateway" "igw_gateway" {
  vpc_id = aws_vpc.terratest.id

  tags = {
    Name = var.tag_name
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.terratest.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = var.tag_name
  }

  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.terratest.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = var.tag_name
  }

  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terratest.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_gateway.id
  }

  tags = {
    Name = var.tag_name
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_nat_gateway" "nat" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.terratest.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.tag_name
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


resource "aws_network_acl" "terratestacl" {
  vpc_id = aws_vpc.terratest.id
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = var.tag_name
  }
}

resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.terratest.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.tag_name
  }
}