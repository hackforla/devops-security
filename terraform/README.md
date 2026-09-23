<!-- BEGIN_TF_DOCS -->
# Overview
Resources created by this code repository.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_custom_policies"></a> [aws\_custom\_policies](#module\_aws\_custom\_policies) | ./modules/aws-policies | n/a |
| <a name="module_iam_oidc_gha_incubator"></a> [iam\_oidc\_gha\_incubator](#module\_iam\_oidc\_gha\_incubator) | ./modules/aws-gha-oidc-providers | n/a |
| <a name="module_iam_read_only_group"></a> [iam\_read\_only\_group](#module\_iam\_read\_only\_group) | ./modules/aws-groups | n/a |
| <a name="module_iam_user_Ganeshswaminathan1912"></a> [iam\_user\_Ganeshswaminathan1912](#module\_iam\_user\_Ganeshswaminathan1912) | ./modules/aws-users | n/a |
| <a name="module_iam_user_Sbairamian"></a> [iam\_user\_Sbairamian](#module\_iam\_user\_Sbairamian) | ./modules/aws-users | n/a |
| <a name="module_iam_user_alexe"></a> [iam\_user\_alexe](#module\_iam\_user\_alexe) | ./modules/aws-users | n/a |
| <a name="module_iam_user_benettonkkb"></a> [iam\_user\_benettonkkb](#module\_iam\_user\_benettonkkb) | ./modules/aws-users | n/a |
| <a name="module_iam_user_rsakuma"></a> [iam\_user\_rsakuma](#module\_iam\_user\_rsakuma) | ./modules/aws-users | n/a |
| <a name="module_iam_user_testiamuser"></a> [iam\_user\_testiamuser](#module\_iam\_user\_testiamuser) | ./modules/aws-users | n/a |
| <a name="module_iam_user_tylerthome"></a> [iam\_user\_tylerthome](#module\_iam\_user\_tylerthome) | ./modules/aws-users | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudtrail.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_group.ops_leads_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group.project_leads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_group_policy_attachment.manageAccessKeys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.manage_access_keys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.incubator_tf_apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.incubator_tf_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_apply_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_plan_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_plan_secrets_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_user.fangyiliu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.jack_pashayan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_s3_bucket.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.management_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.tf_backend_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_only"></a> [iam\_only](#input\_iam\_only) | Manage IAM resources only, skipping the Hack for LA account's CloudTrail trails and log buckets. Set to false for the Hack for LA account. | `bool` | `true` | no |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.64.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.64.0 |
 

# Directory Structure
Terraform directory structure

- 📁 [terraform](https://github.com/hackforla/devops-security/tree/main/terraform)
  - 📁  [aws-custom-policies](https://github.com/hackforla/devops-security/tree/main/terraform/aws-custom-policies) - JSON configurations for customer-managed policies (AWS-managed policies are referenced by ARN and not needed here)
      - 📁 [existing-policies](https://github.com/hackforla/devops-security/tree/main/terraform/aws-custom-policies/existing-policies) - a few of our current policy configurations for reference
  - 📁 [modules](https://github.com/hackforla/devops-security/tree/main/terraform/modules) - reusable Terraform configurations
  - 📄 [aws-custom-policies.tf](https://github.com/hackforla/devops-security/tree/main/terraform/modules/aws-groups) - maintain custom policies here
  - 📄 [aws-groups.tf](https://github.com/hackforla/devops-security/tree/main/terraform/modules/aws-groups) - maintain groups here
  - 📄 [aws-users.tf](https://github.com/hackforla/devops-security/tree/main/terraform/modules/aws-users) - maintain users here
    
To automatically update this documentation, install terraform-docs on your local machine run the following: 
`cd <directory of README location to update>`
`terraform-docs -c .terraform.docs.yml .`
<!-- END_TF_DOCS -->    