# users/main.tf

resource "aws_iam_user" "user" {
  name = var.user_name
  path = var.user_path

  // Offboarding is done by deleting the module block, so a destroy has to be
  // able to finish on its own. Without this, DeleteUser returns DeleteConflict
  // for any user who still has an MFA device, an access key or a directly
  // attached policy, and the apply fails partway through the batch.
  force_destroy = true

  // slack_id has to be on the user when CreateUser runs: the user-bot Lambda is
  // triggered by the CreateLoginProfile that follows and reads it from here.
  tags = merge(var.user_tags, var.slack_id == null ? {} : { slack_id = var.slack_id })
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
