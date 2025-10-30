# run it once only (not once per website or per github repo etc.)

# setup OpenID Connect (OIDC) with AWS and GitHub Actions
resource "aws_iam_openid_connect_provider" "iam_oidc_provider" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Environment = "Production"
  }
}

# creates an IAM role to give to GitHub Actions for managing s3 + CloudFront static websites
resource "aws_iam_role" "github_actions_role" {
  name = "GitHub-Actions-Static-Website-Builder-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = aws_iam_openid_connect_provider.iam_oidc_provider.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:jarrodlilkendey/*"
          }
          StringEqualsIgnoreCase = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      },
    ]
  })

  tags = {
    Environment = "Production"
  }
}

# deny role chaining via STS:AssumeRole
resource "aws_iam_role_policy" "oidc_safety_policy" {
  name = "OidcSafetyPolicy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid     = "OidcSafeties"
        Effect  = "Deny"
        Action  = ["sts:AssumeRole"]
        Resource = "*"
      }
    ]
  })
}

# allow s3 and cloudfront
resource "aws_iam_role_policy" "github_actions_static_websites_policy" {
  name = "GitHubActionsStaticWebsitesPolicy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid     = "AllowS3Actions"
        Effect  = "Allow"
        Action  = [
          "s3:*",
          # "s3:ListBucket",
          # "s3:ListBucketVersions",
          # "s3:ListBucketMultipartUploads",
          # "s3:GetBucketLocation",
          # "s3:GetObject",
          # "s3:PutObject",
          # "s3:PutObjectAcl",
          # "s3:DeleteObject",
          # "s3:DeleteObjectVersion",
          # "s3:AbortMultipartUpload",
          # "s3:ListMultipartUploadParts",
          # "s3:GetBucketTagging",
          # "s3:CreateBucket",
          # "s3:GetBucketPolicy",
          # "s3:GetBucketAcl",
          # "s3:GetBucketCORS",
          # "s3:GetBucketWebsite"
        ]
        Resource = "arn:aws:s3:::*"
      },
      
      {
        Sid     = "AllowCloudFrontActions"
        Effect  = "Allow"
        Action  = [
          "cloudfront:*",
          # "cloudfront:CreateInvalidation",
          # "cloudfront:GetInvalidation",
          # "cloudfront:ListInvalidations",
          # "cloudfront:GetOriginAccessControl",
          # "cloudfront:CreateOriginAccessControl",
          # "cloudfront:CreateFunction",
          # "cloudfront:PublishFunction",
          # "cloudfront:DescribeFunction",
          # "cloudfront:GetFunction"
        ]
        Resource = "arn:aws:cloudfront::*"
      },
      
      {
        Sid     = "AllowACMActions"
        Effect  = "Allow"
        Action  = [
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "acm:GetCertificate",
          "acm:ListTagsForCertificate"
        ]
        Resource = "*"
      },
    ]
  })
}