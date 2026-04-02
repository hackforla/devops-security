module "aws_custom_policies" {
  source = "./modules/aws-policies"
  policies = {
    "IAMServicesSupervisor" = {
      description = "Policy granting IAM services admins permissions to make changes to user accounts"
      filename    = "level-4-iam-services-supervisor-policy.json"
    },
    "EnforceMFAForUsers" = {
      description = "Policy enforcing MFA for devops security users"
      filename    = "enforce-mfa-for-users-policy.json"
    }
    "IncubatorTfPlanSecretsRead" = {
      description = "Allows incubator tf plan role to read specific Secrets Manager secrets needed for terraform plan"
      filename    = "incubator-tf-plan-secrets-read-policy.json"
    }
  }
}
