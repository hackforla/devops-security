# users/main.tf

resource "aws_iam_user" "user" {
  name = var.user_name
  path = var.user_path

  tags = var.user_tags
}

resource "aws_iam_user_login_profile" "user_login" {
  user = aws_iam_user.user.name

  password_reset_required = true
  depends_on              = [aws_iam_user.user]

  lifecycle {
    ignore_changes = [
      password_reset_required,
    ]
  }
}

resource "aws_iam_user_group_membership" "user_group_membership" {
  user   = aws_iam_user.user.name
  groups = var.user_groups
}
