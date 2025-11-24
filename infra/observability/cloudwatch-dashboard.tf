resource "aws_cloudwatch_dashboard" "eks_dashboard" {
  dashboard_name = "eks-observability"
  dashboard_body = file("${path.module}/dashboards/eks-dashboard.json")
}
