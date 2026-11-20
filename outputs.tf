output "bucket_id" {
  description = "Name of the bucket."
  value       = aws_s3_bucket.this.id
}

output "tags" {
  description = "Tags applied to the bucket, including managed-by."
  value       = aws_s3_bucket.this.tags
}
