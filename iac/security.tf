data "aws_prefix_list" "s3" {
  name = "com.amazonaws.us-east-1.s3"
}

resource "aws_security_group" "vpce_sqs" {
  name        = "${var.project_name}-${var.environment}-sg-vpce-sqs"
  description = "Security Group para el VPC Endpoint de SQS"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "upload_lambda" {
  name        = "${var.project_name}-${var.environment}-sg-upload-lambda"
  description = "Security Group para Lambda Upload"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group" "crop_lambda" {
  name        = "${var.project_name}-${var.environment}-sg-crop-lambda"
  description = "Security Group para Lambda Crop"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "sqs_from_upload" {
  security_group_id            = aws_security_group.vpce_sqs.id
  referenced_security_group_id = aws_security_group.upload_lambda.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "sqs_from_crop" {
  security_group_id            = aws_security_group.vpce_sqs.id
  referenced_security_group_id = aws_security_group.crop_lambda.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "upload_to_sqs" {
  security_group_id            = aws_security_group.upload_lambda.id
  referenced_security_group_id = aws_security_group.vpce_sqs.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "upload_to_s3" {
  security_group_id = aws_security_group.upload_lambda.id
  prefix_list_id    = data.aws_prefix_list.s3.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "crop_to_sqs" {
  security_group_id            = aws_security_group.crop_lambda.id
  referenced_security_group_id = aws_security_group.vpce_sqs.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "crop_to_s3" {
  security_group_id = aws_security_group.crop_lambda.id
  prefix_list_id    = data.aws_prefix_list.s3.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}