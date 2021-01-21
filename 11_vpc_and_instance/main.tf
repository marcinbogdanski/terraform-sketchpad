provider "aws" {
  region = "eu-west-2"  # London
}

terraform {
  backend "s3" {
    bucket = "dronex-test-bucket"
    key = "11-state"
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
  map_public_ip_on_launch = true

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

resource "aws_security_group" "ssh_only" {
  name        = format("%s_ssh_only", var.name)
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

##########  EC2  ##########

resource "aws_instance" "my_example" {
  ami           = var.ami
  instance_type = "t2.micro"

  tags = {
    Name = format("%s_HelloWorld", var.name)
  }

  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [ aws_security_group.ssh_only.id ]
  key_name = var.key_name
}