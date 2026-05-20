output "role_arn" {
  description = "The new role's ARN."
  value       = aws_iam_role.unity_catalog.arn
}

output "role_name" {
  description = "The name of the dedicated IAM role for Unity access."
  value       = aws_iam_role.unity_catalog.name
}
