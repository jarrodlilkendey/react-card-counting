data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
        type = "Service"
        identifiers = [
            "lambda.amazonaws.com"
        ]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.FUNCTION_NAME}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# Allow CloudWatch logs + SES SendEmail
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"] # tighten if you like by identity ARN
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${var.FUNCTION_NAME}-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}


data "archive_file" "bootstrap" {
  type        = "zip"
  output_path = "${path.module}/dist/placeholder.zip"

  # Minimal handler using a placeholder function
  source {
    content  = "${path.module}/index.js"
    filename = "index.js"
  }
}

# --- Lambda function (created once) ---
resource "aws_lambda_function" "handler" {
  function_name = "${var.FUNCTION_NAME}"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  filename      = data.archive_file.bootstrap.output_path
  timeout       = 10

  environment {
    variables = {
      FROM_EMAIL      = var.FROM_EMAIL
      TO_EMAIL        = var.TO_EMAIL
      ALLOWED_ORIGINS = join(",", var.ALLOWED_ORIGINS)
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }
}

resource "aws_lambda_function_url" "public" {
  function_name      = aws_lambda_function.handler.arn
  authorization_type = "NONE" # public

  cors {
    allow_origins = var.ALLOWED_ORIGINS            # e.g. ["https://your.site", "https://www.your.site"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 86400
    # allow_credentials = true  # if you need cookies
  }
}

# Optional explicit permission for function URL public access
resource "aws_lambda_permission" "allow_public" {
  statement_id             = "FunctionURLAllowPublicAccess"
  action                   = "lambda:InvokeFunctionUrl"
  function_name            = aws_lambda_function.handler.function_name
  principal                = "*"
  function_url_auth_type   = "NONE"
}

output "function_url" {
  value = aws_lambda_function_url.public.function_url
}