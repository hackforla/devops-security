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

