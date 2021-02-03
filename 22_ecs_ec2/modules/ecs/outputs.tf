output "cluster_id" {
    value = aws_ecs_cluster.my_ecs.id
    description = "Cluster ID"
}

output "task_execution_role_arn" {
    value = aws_iam_role.task_execution_role.arn
}

