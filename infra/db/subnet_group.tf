resource "aws_db_subnet_group" "acme" {
  name       = "acme-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "acme-db-subnet-group"
  }
}
