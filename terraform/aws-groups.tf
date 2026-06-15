// Create read only group
module "iam_read_only_group" {
  source = "./modules/aws-groups"

  group_name = "read-only-group"
  policy_arn = {
    "ReadOnlyAccess"        = "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "IAMUserChangePassword" = "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "EnforceMFAForUsers"    = module.aws_custom_policies.policy_arns["EnforceMFAForUsers"]
  }
}

//import ops-leads group
resource "aws_iam_group" "ops_leads_group" {
	name = "ops-leads"
}

resource "aws_iam_group_policy_attachment" "admin"{
	group = aws_iam_group.ops_leads_group.name
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
} 

resource "aws_iam_group_policy_attachment" "manageAccessKeys"{
	group = aws_iam_group.ops_leads_group.name
	policy_arn = "arn:aws:iam::035866691871:policy/ManageAccessKeys"
} 

	
