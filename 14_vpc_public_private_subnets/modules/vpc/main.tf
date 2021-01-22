resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
        Name = format("%s_HelloVPC", var.prefix),
  }
}

######## Public Subnets ##########

resource "aws_subnet" "public" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  cidr_block = "10.0.${count.index}.0/24"
  
  tags = {
    Name = format("%s_HelloPublicSubnet_${count.index}", var.prefix)
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s_HelloIGW", var.prefix)
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s_HelloPublicRouteTable", var.prefix)
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

######## Private Subnets ##########

resource "aws_subnet" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count.index]
  
  cidr_block = "10.0.${10+count.index}.0/24"
  
  tags = {
    Name = format("%s_HelloPrivateSubnet_${count.index}", var.prefix)
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = format("%s_HelloElasticIP", var.prefix)
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = format("%s_HelloNAT", var.prefix)
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = format("%s_HelloPrivateRouteTable", var.prefix)
  }
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

########## Security Group ##########

resource "aws_security_group" "ssh_only" {
  name        = format("%s_ssh_only", var.prefix)
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