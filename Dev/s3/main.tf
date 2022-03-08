resource "aws_s3_bucket" "crm-bucket" {
  bucket = "${var.name}-bucket-${var.environment}"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.crm-bucket.id
  acl    = "private"
}

resource "aws_kms_key" "bucketkey" {
  description = "This key is used to encrypt bucket objects" 
} 

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption_config" {
  bucket = aws_s3_bucket.crm-bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucketkey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "publicblock" {
  bucket = aws_s3_bucket.crm-bucket.id

  block_public_acls   = true
  block_public_policy = true
}