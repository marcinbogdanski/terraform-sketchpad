provider "aws" {
  region = "eu-west-2"  # London
}

resource "aws_instance" "my_example" {
  ami           = "ami-0ff4c8fb495a5a50d"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld"
  }
}
