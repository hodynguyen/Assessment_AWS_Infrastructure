resource "aws_s3_bucket" "alb_logs" {
  bucket = "alb-access-logs-${var.env}"
}

resource "aws_s3_bucket_acl" "alb_logs_acl" {
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "private"
}
