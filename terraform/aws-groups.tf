// Create read only group
module "iam_read_only_group" {
  source = "./modules/aws-groups"

  group_name = "read-only-group"
  policy_arn = {
    "ReadOnlyAccess"        = "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "IAMUserChangePassword" = "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "EnforceMFAForUsers"    = module.aws_custom_policies.policy_arns["EnforceMFAForUsers"]
  }
}

