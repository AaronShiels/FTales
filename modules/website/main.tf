locals {
  website_hostname     = var.domain_name
  website_hostname_www = "www.${var.domain_name}"
}

resource "aws_s3_bucket" "website" {
  bucket = var.domain_name

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website.json
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  aliases             = [local.website_hostname, local.website_hostname_www]
  default_root_object = "index.html"

  origin {
    origin_id   = aws_s3_bucket.website.bucket_domain_name
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = aws_s3_bucket.website.bucket_domain_name
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
  }

  ordered_cache_behavior {
    path_pattern           = "/index.html"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = aws_s3_bucket.website.bucket_domain_name
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # Managed-CachingDisabled
  }

  viewer_certificate {
    acm_certificate_arn = var.certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "website_a" {
  name    = local.website_hostname
  zone_id = var.hosted_zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "website_cname_www" {
  name    = local.website_hostname_www
  zone_id = var.hosted_zone_id
  type    = "CNAME"
  ttl     = "300"
  records = [local.website_hostname]
}

resource "aws_cloudfront_origin_access_identity" "website" {
}

module "template_files" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = var.content_dir
}

resource "aws_s3_bucket_object" "website" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.website.bucket
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
}
