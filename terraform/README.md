<!-- BEGIN_TF_DOCS -->
# Overview
Resources created by this code repository.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_custom_policies"></a> [aws\_custom\_policies](#module\_aws\_custom\_policies) | ./modules/aws-policies | n/a |
| <a name="module_iam_oidc_gha_incubator"></a> [iam\_oidc\_gha\_incubator](#module\_iam\_oidc\_gha\_incubator) | ./modules/aws-gha-oidc-providers | n/a |
| <a name="module_iam_read_only_group"></a> [iam\_read\_only\_group](#module\_iam\_read\_only\_group) | ./modules/aws-groups | n/a |
| <a name="module_iam_user_Bwoltz"></a> [iam\_user\_Bwoltz](#module\_iam\_user\_Bwoltz) | ./modules/aws-users | n/a |
| <a name="module_iam_user_Ganeshswaminathan1912"></a> [iam\_user\_Ganeshswaminathan1912](#module\_iam\_user\_Ganeshswaminathan1912) | ./modules/aws-users | n/a |
| <a name="module_iam_user_alexe"></a> [iam\_user\_alexe](#module\_iam\_user\_alexe) | ./modules/aws-users | n/a |
| <a name="module_iam_user_benettonkkb"></a> [iam\_user\_benettonkkb](#module\_iam\_user\_benettonkkb) | ./modules/aws-users | n/a |
| <a name="module_iam_user_bltomlin"></a> [iam\_user\_bltomlin](#module\_iam\_user\_bltomlin) | ./modules/aws-users | n/a |
| <a name="module_iam_user_chelseyb"></a> [iam\_user\_chelseyb](#module\_iam\_user\_chelseyb) | ./modules/aws-users | n/a |
| <a name="module_iam_user_drakeredwind01"></a> [iam\_user\_drakeredwind01](#module\_iam\_user\_drakeredwind01) | ./modules/aws-users | n/a |
| <a name="module_iam_user_ezesalvatore4"></a> [iam\_user\_ezesalvatore4](#module\_iam\_user\_ezesalvatore4) | ./modules/aws-users | n/a |
| <a name="module_iam_user_gmgonzal"></a> [iam\_user\_gmgonzal](#module\_iam\_user\_gmgonzal) | ./modules/aws-users | n/a |
| <a name="module_iam_user_here"></a> [iam\_user\_here](#module\_iam\_user\_here) | ./modules/aws-users | n/a |
| <a name="module_iam_user_myronchen-git"></a> [iam\_user\_myronchen-git](#module\_iam\_user\_myronchen-git) | ./modules/aws-users | n/a |
| <a name="module_iam_user_npang4"></a> [iam\_user\_npang4](#module\_iam\_user\_npang4) | ./modules/aws-users | n/a |
| <a name="module_iam_user_raibarra"></a> [iam\_user\_raibarra](#module\_iam\_user\_raibarra) | ./modules/aws-users | n/a |
| <a name="module_iam_user_rsakuma"></a> [iam\_user\_rsakuma](#module\_iam\_user\_rsakuma) | ./modules/aws-users | n/a |
| <a name="module_iam_user_srinipandiyan"></a> [iam\_user\_srinipandiyan](#module\_iam\_user\_srinipandiyan) | ./modules/aws-users | n/a |
| <a name="module_iam_user_testiamuser"></a> [iam\_user\_testiamuser](#module\_iam\_user\_testiamuser) | ./modules/aws-users | n/a |
| <a name="module_iam_user_tylerthome"></a> [iam\_user\_tylerthome](#module\_iam\_user\_tylerthome) | ./modules/aws-users | n/a |
## Resources

| Name | Type |
|------|------|
| [aws_iam_group.ops_leads_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_group_policy_attachment.manageAccessKeys](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_role.incubator_tf_apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.incubator_tf_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_apply_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_plan_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.incubator_tf_plan_secrets_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

 

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