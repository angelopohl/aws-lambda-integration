resource "aws_cloudwatch_log_group" "upload_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-upload"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "crop_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-crop"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "apigw_logs" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = 14
}

resource "aws_sns_topic" "dlq_notifications" {
  name = "${var.project_name}-${var.environment}-dlq-topic"
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-dlq-messages-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_actions       = [aws_sns_topic.dlq_notifications.arn]
  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }
}