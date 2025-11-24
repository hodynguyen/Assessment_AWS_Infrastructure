# Log group for EKS worker node & container logs
resource "aws_cloudwatch_log_group" "eks_nodes" {
  name              = "/eks/nodes"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "eks_containers" {
  name              = "/eks/containers"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "eks_application" {
  name              = "/eks/apps"
  retention_in_days = 14
}
