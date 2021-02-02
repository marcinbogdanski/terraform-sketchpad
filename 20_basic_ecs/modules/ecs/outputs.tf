output "cluster_id" {
    value = aws_ecs_cluster.my_ecs.id
    description = "Cluster ID"
}

output "execution_role_arn" {
    value = aws_iam_role.ecs.arn
}

