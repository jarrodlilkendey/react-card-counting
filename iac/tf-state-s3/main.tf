resource "aws_s3_bucket" "tf_state" {
  bucket = "tf-state-${var.DOMAIN_NAME}"
  force_destroy = true

  tags = {
    Name = "terraform-state"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# (Optional but good) deny non-TLS requests
resource "aws_s3_bucket_policy" "deny_insecure" {
  bucket = aws_s3_bucket.tf_state.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid = "DenyInsecureTransport",
      Effect = "Deny",
      Principal = "*",
      Action = "s3:*",
      Resource = [
        aws_s3_bucket.tf_state.arn,
        "${aws_s3_bucket.tf_state.arn}/*"
      ],
      Condition = { Bool = { "aws:SecureTransport" = "false" } }
    }]
  })
}