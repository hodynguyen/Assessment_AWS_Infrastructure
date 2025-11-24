data "aws_iam_policy_document" "cw_agent_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_url}:sub"
      values   = ["system:serviceaccount:observability:cloudwatch-agent"]
    }
  }
}

resource "aws_iam_role" "cw_agent_irsa" {
  name               = "CWAgentIRSA"
  assume_role_policy = data.aws_iam_policy_document.cw_agent_assume.json
}

resource "aws_iam_policy" "cw_agent_policy" {
  name   = "CWAgentFullAccess"
  policy = file("${path.module}/policies/cloudwatch-agent.json")
}

resource "aws_iam_role_policy_attachment" "cw_agent_attach" {
  role       = aws_iam_role.cw_agent_irsa.name
  policy_arn = aws_iam_policy.cw_agent_policy.arn
}
