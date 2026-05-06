locals {
  lambda_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "upload_role" {
  name               = "${var.project_name}-${var.environment}-iam-upload-lambda-role"
  assume_role_policy = local.lambda_assume_role_policy
}

resource "aws_iam_policy" "upload_policy" {
  name = "${var.project_name}-${var.environment}-upload-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.image_bucket.arn}/uploads/*"
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.main_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "upload_attach" {
  role       = aws_iam_role.upload_role.name
  policy_arn = aws_iam_policy.upload_policy.arn
}

resource "aws_iam_role_policy_attachment" "upload_vpc_access" {
  role       = aws_iam_role.upload_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "crop_role" {
  name               = "${var.project_name}-${var.environment}-iam-crop-lambda-role"
  assume_role_policy = local.lambda_assume_role_policy
}

resource "aws_iam_policy" "crop_policy" {
  name = "${var.project_name}-${var.environment}-crop-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.image_bucket.arn}/uploads/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.image_bucket.arn}/processed/*"
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = aws_sqs_queue.main_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "crop_attach" {
  role       = aws_iam_role.crop_role.name
  policy_arn = aws_iam_policy.crop_policy.arn
}

resource "aws_iam_role_policy_attachment" "crop_vpc_access" {
  role       = aws_iam_role.crop_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}