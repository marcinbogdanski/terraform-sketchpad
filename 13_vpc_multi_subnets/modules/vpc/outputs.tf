output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID of the VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public[*].id
  description = "IDs of the public subnet"
}

output "security_group_id" {
  value       = aws_security_group.ssh_only.id
  description = "ID of the security group"
}