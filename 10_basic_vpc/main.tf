provider "aws" {
  region = "eu-west-2"  # London
}

terraform {
  backend "s3" {
    bucket = "dronex-test-bucket"
    key = "05-state"
    region = "eu-west-2"
  }
}

##########  VPC  ##########

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
        Name = format("%s_HelloVPC", var.name),
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id

  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = format("%s_HelloPublicSubnet", var.name)
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s_HelloIGW", var.name)
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s_HelloPublicRouteTable", var.name)
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


