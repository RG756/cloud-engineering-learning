# ============================================================
# 既存のホストゾーンを参照（AWSが自動作成したものを使う）
# ============================================================
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# ============================================================
# A レコード（IPv4）ALBへのエイリアス
# ============================================================
resource "aws_route53_record" "web_a" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# ============================================================
# AAAA レコード（IPv6）ALBへのエイリアス
# ============================================================
resource "aws_route53_record" "web_aaaa" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "AAAA"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}