resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "High-ALB-5xx"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  threshold           = 50
  evaluation_periods  = 2
  period              = 60
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "High rate of 5xx from ALB"
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "High-RDS-CPU"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  threshold           = 80
  evaluation_periods  = 3
  period              = 60
  comparison_operator = "GreaterThanThreshold"
}
