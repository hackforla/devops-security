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
//
// The apply role's sub condition is refs/heads/main ONLY, and that narrowness is
// load-bearing beyond the obvious. terraform-apply.yaml has a workflow_dispatch
// trigger whose runs are auto-approved -- the one path that applies without a
// reviewed plan -- and a dispatch on any other branch presents a different sub,
// so AWS refuses the AssumeRole outright. Widening this to refs/heads/* would
// silently turn that recovery trigger into an unreviewed apply from any branch.
// See hackforla/devops-security#187.

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

// Assumed by .github/workflows/user-bot-deploy.yml in THIS repo to ship the user-bot
// Lambda's code (see user-bot.tf). Unlike devops-security-tf-plan and -apply above, it
// can be declared here: nothing assumes it until Terraform has already run, so there
// is no bootstrap problem, and it carries the normal managed-by tag rather than exempt.
//
// The sub is pinned to main, so neither a pull request nor a workflow_dispatch from
// another branch can deploy. It can update this one function's code and nothing else;
// the function's configuration, role and trigger stay with Terraform.
resource "aws_iam_role" "user_bot_deploy" {
  name = "devops-security-user-bot-deploy"

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
            "token.actions.githubusercontent.com:sub" = "repo:hackforla/devops-security:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

// GetFunction is what `aws lambda wait function-updated-v2` polls. The older
// function-updated waiter polls GetFunctionConfiguration instead, which is not granted.
resource "aws_iam_role_policy" "user_bot_deploy" {
  name = "user-bot-deploy"
  role = aws_iam_role.user_bot_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:UpdateFunctionCode", "lambda:GetFunction"]
        Resource = aws_lambda_function.user_bot.arn
      }
    ]
  })
}

