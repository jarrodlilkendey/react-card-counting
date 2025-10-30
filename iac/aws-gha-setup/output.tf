output "role_arn" {
  description = "GitHub Actions Role ARN"
  value = aws_iam_role.github_actions_role.arn
}