# roles/outputs.tf

output "role_arn" {
  value       = aws_iam_role.iam_role.arn
  description = "The ARN of the IAM role"
}
