output "cluster_id" {
    value = aws_ecs_cluster.my_ecs.id
    description = "Cluster ID"
}

output "execution_role_arn" {
    value = aws_iam_role.ecs.arn
}

# output "public_subnet_id" {
#   value       = aws_subnet.public[*].id
#   description = "IDs of the public subnet"
# }

# output "private_subnet_id" {
#   value       = aws_subnet.private[*].id
#   description = "IDs of the private subnet"
# }

# output "security_group_id" {
#   value       = aws_security_group.ssh_only.id
#   description = "ID of the security group"
# }