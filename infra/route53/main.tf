############################################
# 1. Create Hosted Zone for acme.com
############################################
resource "aws_route53_zone" "this" {
  name = var.root_domain
}


############################################
# 2. Auto-discover ALB for UI + API
#    ALB Naming pattern (AWS LBC):
#    k8s-<namespace>-<ingress-name>-<hash>
#
#    Vì UI/API chưa tạo được ALB thật,
#    ta tạm dùng FAKE NAME để module chạy.
############################################

# FAKE VALUES – replace when UI/API ALB exist
locals {
  ui_alb_name  = "k8s-default-uiingress-FAKE123456"   # FAKE VALUE
  api_alb_name = "k8s-default-apiingress-FAKE654321" # FAKE VALUE
}

# UI ALB
data "aws_lb" "ui_alb" {
  name = local.ui_alb_name

  # Nếu là fake, AWS sẽ không tìm thấy, Terraform sẽ error.
  # Bạn có thể bật "optional ALB" bằng try() trong data lookup.
}

# API ALB
data "aws_lb" "api_alb" {
  name = local.api_alb_name
}


############################################
# 3. Create DNS Records
############################################

# UI Record -> www.acme.com
resource "aws_route53_record" "ui_record" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www.${var.root_domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.ui_alb.dns_name
    zone_id                = data.aws_lb.ui_alb.zone_id
    evaluate_target_health = false
  }
}

# API Record -> api.acme.com
resource "aws_route53_record" "api_record" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "api.${var.root_domain}"
  type    = "A"

  alias {
    name                   = data.aws_lb.api_alb.dns_name
    zone_id                = data.aws_lb.api_alb.zone_id
    evaluate_target_health = false
  }
}
