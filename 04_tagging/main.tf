provider "aws" {
  region = "eu-west-2"  # London
}

terraform {
  backend "s3" {
    bucket = "dronex-test-bucket"
    key = "04-state"
    region = "eu-west-2"
  }
}

resource "aws_security_group" "ssh_only" {
  name        = format("%s_ssh_only", var.name)
  description = "Allow SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = "t2.micro"

  tags = {
    Name = format("%s_HelloWorld", var.name)
  }

  security_groups = [ aws_security_group.ssh_only.name ]
  key_name = var.key_name
}
