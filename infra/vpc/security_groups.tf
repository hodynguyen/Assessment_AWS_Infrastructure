# ===========================================================
# SECURITY GROUP DEFINITIONS (EMPTY, NO RULES)
# Rules are created separately to avoid circular dependency
# ===========================================================

# ---------------------------
# ALB SG (public-facing)
# ---------------------------
resource "aws_security_group" "alb" {
  name        = "acme-alb-sg"
  description = "Allow public HTTP/HTTPS to ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "acme-alb-sg"
  }
}

# ---------------------------
# UI SG (private)
# ---------------------------
resource "aws_security_group" "ui" {
  name        = "acme-ui-sg"
  description = "UI service security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "acme-ui-sg"
  }
}

# ---------------------------
# API SG (private)
# ---------------------------
resource "aws_security_group" "api" {
  name        = "acme-api-sg"
  description = "API service security group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "acme-api-sg"
  }
}

# ---------------------------
# DB SG (private, internal-only)
# ---------------------------
resource "aws_security_group" "db" {
  name        = "acme-db-sg"
  description = "PostgreSQL database SG"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "acme-db-sg"
  }
}

# ---------------------------
# Metrics SG (private)
# ---------------------------
resource "aws_security_group" "metrics" {
  name        = "acme-metrics-sg"
  description = "Metrics collector SG"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "acme-metrics-sg"
  }
}

# ===========================================================
# SECURITY GROUP RULES (NO CIRCULAR DEPENDENCY)
# ===========================================================

# -----------------------------------------------------------
# ALB inbound rules (public access)
# -----------------------------------------------------------
resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# ALB outbound → allow forwarding to backend services
resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

# -----------------------------------------------------------
# UI RULES
# -----------------------------------------------------------
resource "aws_security_group_rule" "ui_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ui.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ui_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ui.id
}

# -----------------------------------------------------------
# API RULES
# -----------------------------------------------------------

# API receives traffic from ALB
resource "aws_security_group_rule" "api_ingress_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "api_ingress_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api.id
  source_security_group_id = aws_security_group.alb.id
}

# API → DB
resource "aws_security_group_rule" "api_to_db" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api.id
  source_security_group_id = aws_security_group.db.id
}

# API → Metrics
resource "aws_security_group_rule" "api_to_metrics" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.api.id
  source_security_group_id = aws_security_group.metrics.id
}

# -----------------------------------------------------------
# DB RULES (internal only)
# -----------------------------------------------------------

# DB only accepts requests from API
resource "aws_security_group_rule" "db_ingress_from_api" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = aws_security_group.api.id
}

# DB full outbound (internal ops)
resource "aws_security_group_rule" "db_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db.id
}

# -----------------------------------------------------------
# METRICS COLLECTOR RULES
# -----------------------------------------------------------

resource "aws_security_group_rule" "metrics_ingress_from_api" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.metrics.id
  source_security_group_id = aws_security_group.api.id
}

resource "aws_security_group_rule" "metrics_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.metrics.id
}
