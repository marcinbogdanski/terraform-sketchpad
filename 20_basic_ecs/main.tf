provider "aws" {
  region = var.region  # London
}

terraform {
  backend "s3" {
    bucket = "dronex-test-bucket"
    key = "20-state"
    region = "eu-west-2"
  }
}

##########  VPC  ##########

module "my_vpc" {
  source = "./modules/vpc"

  prefix = var.prefix
  availability_zones = var.availability_zones
}

module "my_ecs" {
  source = "./modules/ecs"

  prefix = var.prefix
  ami = var.ami
  security_group_id = module.my_vpc.security_group_id
  subnet_ids = module.my_vpc.private_subnet_ids
}


# resource "aws_ecr_repository" "my_ecr" {
#   name                 = format("%s_HelloECR", var.prefix)
# }



##########  EC2  ##########

# resource "aws_instance" "my_bastion" {
#   ami           = var.ami
#   instance_type = "t2.micro"

#   tags = {
#     Name = format("%s_HelloWorld", var.name)
#   }

#   subnet_id = module.my_vpc.public_subnet_id[1]
#   vpc_security_group_ids = [ module.my_vpc.security_group_id ]
#   key_name = var.key_name
# }


# resource "aws_instance" "my_example" {
#   ami           = var.ami
#   instance_type = "t2.micro"

#   tags = {
#     Name = format("%s_HelloWorld", var.name)
#   }

#   subnet_id = module.my_vpc.private_subnet_id[1]
#   vpc_security_group_ids = [ module.my_vpc.security_group_id ]
#   key_name = var.key_name
# }
