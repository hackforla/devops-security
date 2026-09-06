// This file declares the OIDC roles used by hackforla/incubator CI. The two
// roles used by THIS repo's CI -- devops-security-tf-plan and
// devops-security-tf-apply -- are deliberately NOT here. They were created by
// hand in account 035866691871 on 2026-09-05 and are tagged managed-by=exempt,
// which is what keeps them out of the AWS/Terraform coverage report rather than
// showing up as unmanaged.
//
// The reason is a bootstrap problem, not an oversight. The workflow that would
// run the Terraform creating these roles is the same workflow that has to assume
// them to authenticate, so they cannot exist before the first run that needs
// them. Declaring them here would reintroduce that circularity. See
// hackforla/devops-security#182.
//
// Do not "fix" their absence by adding them below.

module "iam_oidc_gha_incubator" {
  source = "./modules/aws-gha-oidc-providers"

  role_name     = "gha-incubator"
  use_wildcard  = true
  github_branch = "refs/heads/*" # allows any branch
  github_repo   = "hackforla/incubator"

  policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

}
resource "aws_iam_role" "incubator_tf_plan" {
  name = "incubator-tf-plan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = module.iam_oidc_gha_incubator.provider_arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:hackforla/incubator:ref:refs/heads/*",
              "repo:hackforla/incubator:pull_request"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "incubator_tf_plan_readonly" {
  role       = aws_iam_role.incubator_tf_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "incubator_tf_plan_secrets_read" {
  role       = aws_iam_role.incubator_tf_plan.name
  policy_arn = module.aws_custom_policies.policy_arns["IncubatorTfPlanSecretsRead"]
}

resource "aws_iam_role" "incubator_tf_apply" {
  name = "incubator-tf-apply"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = module.iam_oidc_gha_incubator.provider_arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:hackforla/incubator:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "incubator_tf_apply_admin" {
  role       = aws_iam_role.incubator_tf_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

