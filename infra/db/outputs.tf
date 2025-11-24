output "db_endpoint" {
  value = aws_db_instance.acme.address
}

output "db_port" {
  value = aws_db_instance.acme.port
}

output "db_username" {
  value = aws_db_instance.acme.username
}

output "db_name" {
  value = aws_db_instance.acme.db_name
}
