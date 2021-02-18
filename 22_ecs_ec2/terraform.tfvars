# Get ECS optimized AMIs from here
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html

region = "eu-west-2"
prefix = "xxx"
ami = "ami-0cd4858f2b923aa6b"
key_name = "dx-eu-west-2"
availability_zones = ["eu-west-2a", "eu-west-2b"]
instance_type = "g4dn.xlarge"
desired_count = 1
