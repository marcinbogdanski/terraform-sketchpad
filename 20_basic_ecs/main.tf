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

resource "aws_ecr_repository" "my_ecr" {
    name  = format("%s-hello-world-loop", var.prefix)
}

output "ecr_url" {
  value = aws_ecr_repository.my_ecr.repository_url
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "hello-world-loop"
  network_mode             = "awsvpc"
  execution_role_arn = module.my_ecs.execution_role_arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = file("hello-world-loop.json")
}

resource "aws_ecs_service" "worker" {
  name            = "hello-world-loop"
  cluster         = module.my_ecs.cluster_id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
  launch_type = "FARGATE"

  network_configuration {
    security_groups  = [module.my_vpc.security_group_id]
    subnets          = module.my_vpc.private_subnet_ids
  }
}



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
