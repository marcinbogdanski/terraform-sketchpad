variable "prefix" {
  type = string
}

variable "ami" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}