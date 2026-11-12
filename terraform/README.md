# Overview
Resources created by this code repository.

# Directory Structure
Terraform directory structure

- 📁 [terraform](./)
  - 📁 [aws-custom-policies](aws-custom-policies/) - JSON documents for customer-managed policies (AWS-managed policies are referenced by ARN and not needed here)
    - 📁 [existing-policies](aws-custom-policies/existing-policies/) - policy documents captured from the live account; `manage-access-keys-policy.json` is used by `aws-custom-policies-legacy.tf`, the rest are kept for reference
  - 📁 [modules](modules/) - reusable Terraform configurations, each documented in its own README
    - 📁 [aws-gha-oidc-providers](modules/aws-gha-oidc-providers/) - GitHub Actions OIDC identity provider and role
    - 📁 [aws-groups](modules/aws-groups/) - IAM groups
    - 📁 [aws-policies](modules/aws-policies/) - IAM customer-managed policies
    - 📁 [aws-roles](modules/aws-roles/) - IAM roles
    - 📁 [aws-users](modules/aws-users/) - IAM users
  - 📄 [aws-custom-policies.tf](aws-custom-policies.tf) - maintain custom policies here
  - 📄 [aws-custom-policies-legacy.tf](aws-custom-policies-legacy.tf) - policies that predate the module, declared as bare resources
  - 📄 [aws-gha-oidc-providers.tf](aws-gha-oidc-providers.tf) - OIDC roles for hackforla/incubator CI and the user-bot deploy workflow
  - 📄 [aws-groups.tf](aws-groups.tf) - maintain groups here
  - 📄 [aws-groups-legacy.tf](aws-groups-legacy.tf) - groups that predate the module, declared as bare resources
  - 📄 [aws-users.tf](aws-users.tf) - maintain users here
  - 📄 [aws-users-legacy.tf](aws-users-legacy.tf) - users that predate the module, declared as bare resources
  - 📄 [backend.tf](backend.tf) - Terraform and provider version pins, S3 backend and AWS provider
  - 📄 [cloudtrail.tf](cloudtrail.tf) - the account's two CloudTrail trails and their log buckets
  - 📄 [prod.backend.tfvars](prod.backend.tfvars) - backend configuration used by CI
  - 📄 [user-bot.tf](user-bot.tf) - the user-bot Lambda that sends new IAM users their temporary console password on Slack
  - 📄 [variables.tf](variables.tf) - input variables

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.64.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.8.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.64.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_custom_policies"></a> [aws\_custom\_policies](#module\_aws\_custom\_policies) | ./modules/aws-policies | n/a |
| <a name="module_iam_oidc_gha_incubator"></a> [iam\_oidc\_gha\_incubator](#module\_iam\_oidc\_gha\_incubator) | ./modules/aws-gha-oidc-providers | n/a |
| <a name="module_iam_read_only_group"></a> [iam\_read\_only\_group](#module\_iam\_read\_only\_group) | ./modules/aws-groups | n/a |
| <a name="module_iam_user_Ganeshswaminathan1912"></a> [iam\_user\_Ganeshswaminathan1912](#module\_iam\_user\_Ganeshswaminathan1912) | ./modules/aws-users | n/a |
| <a name="module_iam_user_Sbairamian"></a> [iam\_user\_Sbairamian](#module\_iam\_user\_Sbairamian) | ./modules/aws-users | n/a |
| <a name="module_iam_user_ale210"></a> [iam\_user\_ale210](#module\_iam\_user\_ale210) | ./modules/aws-users | n/a |
| <a name="module_iam_user_here"></a> [iam\_user\_here](#module\_iam\_user\_here) | ./modules/aws-users | n/a |
| <a name="module_iam_user_rsakuma"></a> [iam\_user\_rsakuma](#module\_iam\_user\_rsakuma) | ./modules/aws-users | n/a |
| <a name="module_iam_user_testiamuser"></a> [iam\_user\_testiamuser](#module\_iam\_user\_testiamuser) | ./modules/aws-users | n/a |
| <a name="module_iam_user_tylerthome"></a> [iam\_user\_tylerthome](#module\_iam\_user\_tylerthome) | ./modules/aws-users | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudtrail.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_event_rule.user_bot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.user_bot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.user_bot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_group.ops_leads_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group.project_leads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_group_policy_attachment.manageAccessKeys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.manage_access_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.incubator_tf_apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.incubator_tf_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.user_bot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.user_bot_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.user_bot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.user_bot_deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_apply_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_plan_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_plan_secrets_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.fangyiliu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.jack_pashayan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_lambda_function.user_bot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.user_bot_eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_ssm_parameter.user_bot_slack_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [archive_file.user_bot_placeholder](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_only"></a> [iam\_only](#input\_iam\_only) | Manage IAM resources only, skipping the Hack for LA account's CloudTrail trails and log buckets. Set to false for the Hack for LA account. | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
