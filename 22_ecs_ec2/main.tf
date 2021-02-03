provider "aws" {
  region = var.region  # London
}

terraform {
  backend "s3" {
    bucket = "dronex-test-bucket"
    key = "22-state"
    region = "eu-west-2"
  }
}

##########  VPC + ECS  ##########

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
  subnet_ids = module.my_vpc.public_subnet_ids
  key_name = var.key_name
}

##########  ECR  ##########

resource "aws_ecr_repository" "my_ecr" {
    name  = format("%s-hello-world-loop", var.prefix)
}

output "ecr_url" {
  value = aws_ecr_repository.my_ecr.repository_url
}

##########  FarGate Service  ##########

resource "aws_ecs_task_definition" "hello_world_loop" {
  family                   = "hello-world-loop"
  network_mode             = "awsvpc"
  execution_role_arn       = module.my_ecs.task_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = <<DEFINITION
[
  {
    "essential": true,
    "name": "hello-world-loop",
    "image": "467525903542.dkr.ecr.eu-west-2.amazonaws.com/xxx-hello-world-loop:latest",
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/xxx-hello-world-loop",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "hello_world_loop" {
  name            = "hello-world-loop"
  cluster         = module.my_ecs.cluster_id
  task_definition = aws_ecs_task_definition.hello_world_loop.arn
  desired_count   = 2
  launch_type = "FARGATE"

  network_configuration {
    security_groups  = [module.my_vpc.security_group_id]
    subnets          = module.my_vpc.private_subnet_ids
  }
}

resource "aws_cloudwatch_log_group" "hello_world_loop" {
  name              = "/fargate/service/xxx-hello-world-loop"
}

##########  EC2 Service  ##########

resource "aws_ecs_task_definition" "hello_world_loop_ec2" {
  family                   = "hello-world-loop-ec2"
  requires_compatibilities = ["EC2"]
  memory                   = "512"
  container_definitions    = <<DEFINITION
[
  {
    "essential": true,
    "name": "hello-world-loop-ec2",
    "image": "467525903542.dkr.ecr.eu-west-2.amazonaws.com/xxx-hello-world-loop:latest",
    "environment": []
  }
]
DEFINITION
}

resource "aws_ecs_service" "hello_world_loop_ec2" {
  name            = "hello-world-loop-ec2"
  cluster         = module.my_ecs.cluster_id
  task_definition = aws_ecs_task_definition.hello_world_loop_ec2.arn
  desired_count   = 2
  launch_type = "EC2"
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
