resource "aws_lb" "ingress" {
  name               = "${var.name}-lb"
  load_balancer_type = "network"
  internal           = false
  subnets            = var.subnet_ids
}

resource "aws_lb_listener" "ingress" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate.ingress.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingress.arn
  }
}

resource "aws_lb_target_group" "ingress" {
  port        = var.target_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled = true
    path    = var.target_health_check_path
  }
}

resource "aws_route53_record" "ingress" {
  name    = var.hostname
  zone_id = var.hosted_zone_id
  type    = "A"

  alias {
    name                   = aws_lb.ingress.dns_name
    zone_id                = aws_lb.ingress.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "ingress" {
  domain_name       = var.hostname
  validation_method = "DNS"
}

resource "aws_route53_record" "ingress_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ingress.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = var.hosted_zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "ingress" {
  certificate_arn         = aws_acm_certificate.ingress.arn
  validation_record_fqdns = [for record in aws_route53_record.ingress_validation : record.fqdn]
}
