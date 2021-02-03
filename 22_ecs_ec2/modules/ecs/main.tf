
# Source for IAM, AutoScaling and ECS
# - https://medium.com/swlh/creating-an-aws-ecs-cluster-of-ec2-instances-with-terraform-85a10b5cfbe3

##########  IAM Stuff  ##########

data "aws_iam_policy_document" "ecs" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",  # FarGate
        "ecs.amazonaws.com",        # EC2
        "ec2.amazonaws.com"         # EC2
      ]
    }
  }
}

# This is so FarGate/EC2 can pull images from ECR
resource "aws_iam_role" "task_execution_role" {
  name               = format("%s_TaskExecutionRole", var.prefix)
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

# FarGate
resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# EC2
resource "aws_iam_role_policy_attachment" "task_execution_role_2" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# EC2
resource "aws_iam_instance_profile" "task_execution_iam_profile" {
  name = format("%s_TaskExecutionIAMProfile", var.prefix)
  role = aws_iam_role.task_execution_role.name
}

#########  AutoScaling  ##########

resource "aws_launch_configuration" "launch_config" {
  name_prefix          = format("%s_", var.prefix)
  image_id             = var.ami
  iam_instance_profile = aws_iam_instance_profile.task_execution_iam_profile.name
  security_groups      = [var.security_group_id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config;\necho ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;"
  instance_type        = "t2.micro"
  key_name = var.key_name
}

resource "aws_autoscaling_group" "asg" {
    name                      = format("%s_HelloASG", var.prefix)
    vpc_zone_identifier       = var.subnet_ids[*]
    launch_configuration      = aws_launch_configuration.launch_config.name

    desired_capacity          = 2
    min_size                  = 1
    max_size                  = 10
    health_check_grace_period = 300
    health_check_type         = "EC2"
}

##########  ECS  ##########

resource "aws_ecs_cluster" "my_ecs" {
  name = "my-cluster"
  capacity_providers = [ "FARGATE" ]
}


