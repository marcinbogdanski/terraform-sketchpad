provider "aws" {
  region = "eu-west-2"  # London
}

terraform {
  backend "s3" {
    bucket = "dronex-test-bucket"
    key = "12-state"
    region = "eu-west-2"
  }
}

##########  VPC  ##########

module "my_vpc" {
  source = "./modules/vpc"

  prefix = var.name
}

##########  EC2  ##########

resource "aws_instance" "my_example" {
  ami           = var.ami
  instance_type = "t2.micro"

  tags = {
    Name = format("%s_HelloWorld", var.name)
  }

  subnet_id = module.my_vpc.public_subnet_id
  vpc_security_group_ids = [ module.my_vpc.security_group_id ]
  key_name = var.key_name
}
