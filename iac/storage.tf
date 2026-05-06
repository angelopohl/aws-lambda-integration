resource "aws_s3_bucket" "image_bucket" {
  bucket = "image-processor-${var.environment}-images-${var.suffix}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "private_access" {
  bucket = aws_s3_bucket.image_bucket.id 
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.image_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.image_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.image_bucket.id

  rule {
    id = "expired-uploads"
    status = "Enabled"
    filter {
      prefix = "uploads/"
    }
    expiration {
      days = 30
    }
  }
  
  rule {
    id = "expired-processed"
    status = "Enabled"
    filter {
      prefix = "processed/"
    }
    expiration {
      days = 90
    }
  }
}

resource "aws_sqs_queue" "dlq" {
  name = "image-processor-${var.environment}-dlq"
  mendage_retention_seconds = 1209600  
}

resource "aws_sqs_queue" "main_queue"{
  name = "image-processor-${var.environment}-queue"
  visibility_timeout_seconds = 360
  mendage_retention_seconds = 86400
  receive_message_wait_time_seconds = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount = 3
  })
}