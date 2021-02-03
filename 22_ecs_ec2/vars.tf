variable "region" {
  type = string
}

variable "prefix" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "ami" {
  type = string
}

variable "key_name" {
  type = string
}
