<!-- BEGIN_TF_DOCS -->
# Users

This module declares all of the resources necessary to create AWS IAM users.



## Resources

| Name | Type |
|------|------|
| [aws_iam_user.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.user_group_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_login_profile.user_login](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_slack_id"></a> [slack\_id](#input\_slack\_id) | Slack member ID of the person this user belongs to (Slack profile > Copy member ID). Stored as the user's slack\_id tag, which the user-bot Lambda reads to DM them a temporary console password. | `string` | `null` | no |
| <a name="input_user_groups"></a> [user\_groups](#input\_user\_groups) | List of IAM groups the user should be a member of | `list(string)` | `[]` | no |
| <a name="input_user_name"></a> [user\_name](#input\_user\_name) | The name of the IAM user | `string` | n/a | yes |
| <a name="input_user_path"></a> [user\_path](#input\_user\_path) | Path in which to create the user | `string` | `"/"` | no |
| <a name="input_user_tags"></a> [user\_tags](#input\_user\_tags) | Tags to assign to the user | `map(string)` | `{}` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_arn"></a> [user\_arn](#output\_user\_arn) | The ARN of the IAM user |
| <a name="output_user_name"></a> [user\_name](#output\_user\_name) | The name of the IAM user |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

<!-- END_TF_DOCS -->    