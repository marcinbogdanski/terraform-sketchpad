variable "prefix" {
  description = "Prefix applied to all created resources"
  type = string
}

variable "ami" {
  description = "AMI to use for ECS cluster, must be from specified region"
  type = string
}

variable "security_group_id" {
  description = "Security group id to be used with EC2 instances"
  type = string
}

variable "subnet_ids" {
  description = "Ids of subnets to be used to deploy cluster compute instances"
  type = list(string)
}

variable "key_name" {
  description = "SSH key attached to EC2 instances, must already exist"
  type = string
}

variable "instance_type" {
  description = "AWS instance type, e.g. t2.micro or g4dn.xlarge for GPU"
  type = string
}

variable "desired_capacity" {
  description = "How many instances to spin up in the cluster"
  type = number
}
