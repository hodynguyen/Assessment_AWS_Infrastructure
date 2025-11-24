resource "aws_db_instance" "acme" {
  identifier = "acme-postgres"

  engine               = "postgres"
  engine_version       = "17.6"
  instance_class       = "db.t4g.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  multi_az             = true
  publicly_accessible  = false

  username = local.postgres_secret.username
  password = local.postgres_secret.password

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.acme.name

  backup_retention_period     = 7
  skip_final_snapshot         = true
  performance_insights_enabled = true

  tags = {
    Name = "acme-postgres"
  }
}
