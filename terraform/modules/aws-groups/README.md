# Groups

This module declares all of the resources necessary to create AWS IAM groups.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_group.group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.group_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | The name of the IAM group | `string` | n/a | yes |
| <a name="input_group_path"></a> [group\_path](#input\_group\_path) | Path in which to create the group | `string` | `"/"` | no |
| <a name="input_policy_arn"></a> [policy\_arn](#input\_policy\_arn) | Map of policy names to ARNs to attach to the group | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_arn"></a> [group\_arn](#output\_group\_arn) | The ARN of the IAM group |
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | The name of the IAM group |
<!-- END_TF_DOCS -->
