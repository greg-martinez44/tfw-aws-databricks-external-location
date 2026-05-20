output "bucket_arn" {
  description = "The new bucket's ARN."
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_name" {
  description = "The new bucket's name."
  value       = aws_s3_bucket.bucket.id
}
