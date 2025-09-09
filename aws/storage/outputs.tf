output "bucket_ref" {
  value = var.create_bucket ? aws_s3_bucket.bufstream[0].id : data.aws_s3_bucket.bufstream[0].id
}
