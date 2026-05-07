resource "aws_s3_bucket" "image_bucket" {
  bucket        = "image-processor-${var.environment}-images-${var.suffix}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "private_access" {
  bucket                  = aws_s3_bucket.image_bucket.id 
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.image_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.image_bucket.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.image_bucket.id

  rule {
    id = "expired-uploads"
    status = "Enabled"
    filter { prefix = "uploads/" }
    expiration { days = 30 }
  }
  
  rule {
    id = "expired-processed"
    status = "Enabled"
    filter { prefix = "processed/" }
    expiration { days = 90 }
  }
}

# --- CONFIGURACIÓN DE SQS (DLQ y Principal) ---

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-${var.environment}-dlq"
  message_retention_seconds = 1209600 # 14 días
}

resource "aws_sqs_queue" "main_queue" {
  name                       = "${var.project_name}-${var.environment}-queue"
  visibility_timeout_seconds = 360
  receive_wait_time_seconds  = 20
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

# Permite a S3 enviar mensajes a SQS
resource "aws_sqs_queue_policy" "s3_to_sqs" {
  queue_url = aws_sqs_queue.main_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.main_queue.arn
      Condition = { ArnLike = { "aws:SourceArn" = aws_s3_bucket.image_bucket.arn } }
    }]
  })
}

# Gatillo de S3 a SQS
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.image_bucket.id
  queue {
    queue_arn     = aws_sqs_queue.main_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "uploads/"
  }
  depends_on = [aws_sqs_queue_policy.s3_to_sqs]
}