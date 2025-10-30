resource "aws_s3_bucket" "bucket" {
  bucket = "${var.DOMAIN_NAME}-website"
  force_destroy = true

  tags = {
    Environment = "Production"
    Website = var.DOMAIN_NAME
  }
}

# See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

locals {
  s3_origin_id = "myS3Origin"
}

data "aws_acm_certificate" "my_domain_cert" {
  region   = "us-east-1"
  domain   = "${var.DOMAIN_NAME}"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "oac-${var.DOMAIN_NAME}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  aliases = ["www.${var.DOMAIN_NAME}", "${var.DOMAIN_NAME}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_index_fn.arn
    }
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.my_domain_cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = "Production"
    Website = var.DOMAIN_NAME
  }
}

data "cloudflare_zone" "cf_zone" {
  filter = {
    name = var.DOMAIN_NAME
  }
}

resource "cloudflare_dns_record" "www_cname_record" {
  zone_id = data.cloudflare_zone.cf_zone.zone_id
  name    = "www"
  type    = "CNAME"
  content = aws_cloudfront_distribution.s3_distribution.domain_name
  ttl     = 60
  proxied = false
}

resource "cloudflare_dns_record" "root_cname_record" {
  zone_id = data.cloudflare_zone.cf_zone.zone_id
  name    = var.DOMAIN_NAME
  type    = "CNAME"
  content = aws_cloudfront_distribution.s3_distribution.domain_name
  ttl     = 60
  proxied = false
}

# aws cloudfront function to allow non root paths e.g. /blog to be accessible
resource "aws_cloudfront_function" "rewrite_index_fn" {
  name    = "${replace(var.DOMAIN_NAME, ".", "")}-rewrite-index-fn"
  runtime = "cloudfront-js-1.0"
  comment = "Rewrite extensionless paths to index.html"

  code = <<-EOF
    function handler(event) {
      var req = event.request;
      var uri = req.uri;

      // If no file extension, rewrite to /index.html
      if (!uri.includes('.')) {
        if (uri.endsWith('/')) {
          req.uri = uri + 'index.html';
        } else {
          req.uri = uri + '/index.html';
        }
      }
      return req;
    }
  EOF
  publish = true
}