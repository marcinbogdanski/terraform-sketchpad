provider "aws" {
  region = "eu-west-2"  # London
}

terraform {
  backend "s3" {
    bucket = "dronex-test-bucket"
    key = "03-state"
    region = "eu-west-2"
  }
}

resource "aws_security_group" "ssh_only" {
  name        = "ssh_only"
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
  ami           = "ami-0ff4c8fb495a5a50d"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }

  security_groups = [ aws_security_group.ssh_only.name ]
  key_name = "dx-eu-west-2"
}
