data "archive_file" "upload_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/upload"
  output_path = "${path.module}/../upload.zip"
}

data "archive_file" "crop_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/crop"
  output_path = "${path.module}/../crop.zip"
}

resource "aws_lambda_function" "upload_lambda" {
  function_name    = "${var.project_name}-${var.environment}-upload"
  filename         = data.archive_file.upload_zip.output_path
  source_code_hash = data.archive_file.upload_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 30
  memory_size      = 256
  role             = aws_iam_role.upload_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.upload_lambda.id]
  }

  environment {
    variables = {
      BUCKET_NAME   = aws_s3_bucket.image_bucket.bucket
      SQS_QUEUE_URL = aws_sqs_queue.main_queue.url
      UPLOAD_PREFIX = "uploads/"
    }
  }
}

resource "aws_lambda_function" "crop_lambda" {
  function_name    = "${var.project_name}-${var.environment}-crop"
  filename         = data.archive_file.crop_zip.output_path
  source_code_hash = data.archive_file.crop_zip.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = 60
  memory_size      = 512
  role             = aws_iam_role.crop_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_group_ids = [aws_security_group.crop_lambda.id]
  }

  environment {
    variables = {
      BUCKET_NAME      = aws_s3_bucket.image_bucket.bucket
      PROCESSED_PREFIX = "processed/"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_crop" {
  event_source_arn        = aws_sqs_queue.main_queue.arn
  function_name           = aws_lambda_function.crop_lambda.arn
  batch_size              = 5
  function_response_types = ["ReportBatchItemFailures"]
}