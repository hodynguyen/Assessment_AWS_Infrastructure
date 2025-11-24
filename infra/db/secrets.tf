# Get the secret metadata
data "aws_secretsmanager_secret" "postgres" {
  name = "acme/prod/postgres"
}

# Get the latest version of the secret
data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = data.aws_secretsmanager_secret.postgres.id
}

# Convert JSON secret into a map
locals {
  postgres_secret = jsondecode(data.aws_secretsmanager_secret_version.postgres.secret_string)
}
