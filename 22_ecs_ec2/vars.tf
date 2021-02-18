variable "region" {
  description = "Deploy infrastrucutrue to this AWS region"
  type = string
}

variable "prefix" {
  description = "Prefix applied to all created resources"
  type = string
}

variable "availability_zones" {
  description = "Availability zones for public and private subnets"
  type = list(string)
}

variable "ami" {
  description = "AMI to use for ECS cluster, must be from specified region"
  type = string
}

variable "key_name" {
  description = "SSH key attached to EC2 instances, must already exist"
  type = string
}

variable "instance_type" {
  description = "AWS instance type, e.g. t2.micro or g4dn.xlarge for GPU"
  type = string
}

variable "desired_count" {
  description = "How many copies of service to spin up in the cluster"
  type = number
}
