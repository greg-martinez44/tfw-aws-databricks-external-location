output "storage_credential_name" {
  description = "The new storage credential's name."
  value       = databricks_storage_credential.storage_credential.id
}

output "storage_credential_aws_iam_role_arn" {
  description = "The ARN of the dedicated IAM role for Unity access."
  value       = aws_iam_role.unity_catalog.arn
}

output "storage_credential_aws_iam_role_name" {
  description = "The name of the dedicated IAM role for Unity access."
  value       = aws_iam_role.unity_catalog.name
}

output "external_location_name" {
  description = "The new external location's name."
  value       = databricks_external_location.external_location.id
}

output "external_location_url" {
  description = "The new external location's URL."
  value       = databricks_external_location.external_location.url
}
