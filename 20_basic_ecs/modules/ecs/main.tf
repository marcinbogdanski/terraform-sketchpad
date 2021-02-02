
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
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs" {
  name               = format("%s_HelloECSRole", var.prefix)
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# resource "aws_iam_instance_profile" "ecs" {
#   name = format("%s_HelloIAMInstanceProfile", var.prefix)
#   role = aws_iam_role.ecs.name
# }

##########  AutoScaling  ##########

# resource "aws_launch_configuration" "launch_config" {
#   name_prefix          = format("%s_", var.prefix)
#   image_id             = var.ami
#   iam_instance_profile = aws_iam_instance_profile.ecs.name
#   security_groups      = [var.security_group_id]
#   user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
#   instance_type        = "t2.micro"
# }

# resource "aws_autoscaling_group" "asg" {
#     name                      = format("%s_HelloASG", var.prefix)
#     vpc_zone_identifier       = var.subnet_ids[*]
#     launch_configuration      = aws_launch_configuration.launch_config.name

#     desired_capacity          = 2
#     min_size                  = 1
#     max_size                  = 10
#     health_check_grace_period = 300
#     health_check_type         = "EC2"
# }

##########  ECS  ##########

resource "aws_ecs_cluster" "my_ecs" {
  name = "my-cluster"
  capacity_providers = [ "FARGATE" ]
}


