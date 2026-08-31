// Legacy IAM customer-managed policies.
//
// Declared as bare resources rather than through ./modules/aws-policies for the
// same reason as aws-users-legacy.tf and aws-groups-legacy.tf: the module owns
// the name, description and document of a policy it created, and these predate
// it. The document below is the one already committed under
// aws-custom-policies/existing-policies/, which was verified byte-for-byte
// against the live policy before importing.
//
// ManageAccessKeys is attached to the ops-leads group by
// aws_iam_group_policy_attachment.manageAccessKeys in aws-groups.tf, which
// still refers to it by literal ARN. That attachment is unchanged here.

resource "aws_iam_policy" "manage_access_keys" {
  name = "ManageAccessKeys"
  // description is ForceNew on aws_iam_policy. Omitting it plans a replacement
  // of the live policy, which detaches it from ops-leads. This is the string
  // already on the policy in the account.
  description = "Policy for creating, listing, and updating Access Keys"
  policy      = file("${path.module}/aws-custom-policies/existing-policies/manage-access-keys-policy.json")
}

import {
  to = aws_iam_policy.manage_access_keys
  id = "arn:aws:iam::035866691871:policy/ManageAccessKeys"
}
