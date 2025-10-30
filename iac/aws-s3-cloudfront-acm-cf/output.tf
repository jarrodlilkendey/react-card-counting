output "cloudfront_domain_name" {
  description = "The CloudFront distribution domain name to use as the CNAME target in Cloudflare"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_distribution_id" {
  description = "The CloudFront distribution id to use for invalidating the CloudFront cache after a website deployment to s3"
  value       = aws_cloudfront_distribution.s3_distribution.id
}