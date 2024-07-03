<!-- BEGIN_TF_DOCS -->
# Overview
Resources created by this code repository.


## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_custom_policies"></a> [aws\_custom\_policies](#module\_aws\_custom\_policies) | ./modules/aws-policies | n/a |
| <a name="module_iam_oidc_gha_incubator"></a> [iam\_oidc\_gha\_incubator](#module\_iam\_oidc\_gha\_incubator) | ./modules/aws-gha-oidc-providers | n/a |
| <a name="module_iam_read_only_group"></a> [iam\_read\_only\_group](#module\_iam\_read\_only\_group) | ./modules/aws-groups | n/a |
| <a name="module_iam_services_supervisor_group"></a> [iam\_services\_supervisor\_group](#module\_iam\_services\_supervisor\_group) | ./modules/aws-groups | n/a |
| <a name="module_iam_user_JimmyJuarez10"></a> [iam\_user\_JimmyJuarez10](#module\_iam\_user\_JimmyJuarez10) | ./modules/aws-users | n/a |
| <a name="module_iam_user_abbyz123"></a> [iam\_user\_abbyz123](#module\_iam\_user\_abbyz123) | ./modules/aws-users | n/a |
| <a name="module_iam_user_awlFCCamp"></a> [iam\_user\_awlFCCamp](#module\_iam\_user\_awlFCCamp) | ./modules/aws-users | n/a |
| <a name="module_iam_user_brittanyms"></a> [iam\_user\_brittanyms](#module\_iam\_user\_brittanyms) | ./modules/aws-users | n/a |
| <a name="module_iam_user_chelseyb"></a> [iam\_user\_chelseyb](#module\_iam\_user\_chelseyb) | ./modules/aws-users | n/a |
| <a name="module_iam_user_freaky4wrld"></a> [iam\_user\_freaky4wrld](#module\_iam\_user\_freaky4wrld) | ./modules/aws-users | n/a |
| <a name="module_iam_user_jbubar"></a> [iam\_user\_jbubar](#module\_iam\_user\_jbubar) | ./modules/aws-users | n/a |
| <a name="module_iam_user_samuelusc"></a> [iam\_user\_samuelusc](#module\_iam\_user\_samuelusc) | ./modules/aws-users | n/a |
| <a name="module_iam_user_shikha0428"></a> [iam\_user\_shikha0428](#module\_iam\_user\_shikha0428) | ./modules/aws-users | n/a |
| <a name="module_iam_user_shinjonathan"></a> [iam\_user\_shinjonathan](#module\_iam\_user\_shinjonathan) | ./modules/aws-users | n/a |
| <a name="module_iam_user_spiteless"></a> [iam\_user\_spiteless](#module\_iam\_user\_spiteless) | ./modules/aws-users | n/a |
| <a name="module_iam_user_testiamuser"></a> [iam\_user\_testiamuser](#module\_iam\_user\_testiamuser) | ./modules/aws-users | n/a |
| <a name="module_iam_user_tylerthome"></a> [iam\_user\_tylerthome](#module\_iam\_user\_tylerthome) | ./modules/aws-users | n/a |





 

# Directory Structure
Terraform directory structure

- 📁 [terraform](https://github.com/hackforla/ops-security/tree/cb/example/terraform)
  - 📁  [aws-custom-policies](https://github.com/hackforla/ops-security/tree/cb/example/terraform/aws-custom-policies) - JSON configurations for customer-managed policies (AWS-managed policies are referenced by ARN and not needed here)
      - 📁 [existing-policies](https://github.com/hackforla/ops-security/tree/cb/example/terraform/aws-custom-policies/existing-policies) - a few of our current policy configurations for reference
  - 📁 [modules](https://github.com/hackforla/ops-security/tree/cb/example/terraform/modules) - reusable Terraform configurations
  - 📄 [aws-custom-policies.tf](https://github.com/hackforla/ops-security/tree/cb/example/terraform/modules/aws-groups) - maintain custom policies here
  - 📄 [aws-groups.tf](https://github.com/hackforla/ops-security/tree/cb/example/terraform/modules/aws-groups) - maintain groups here
  - 📄 [aws-users.tf](https://github.com/hackforla/ops-security/tree/cb/example/terraform/modules/aws-users) - maintain users here
    
To automatically update this documentation, install terraform-docs on your local machine run the following: 
`cd <directory of README location to update>`
`terraform-docs -c .terraform.docs.yml .`
<!-- END_TF_DOCS -->    