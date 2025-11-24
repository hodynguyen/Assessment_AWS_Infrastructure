output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ui_sg_id" {
  value = aws_security_group.ui.id
}

output "api_sg_id" {
  value = aws_security_group.api.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "metrics_sg_id" {
  value = aws_security_group.metrics.id
}
