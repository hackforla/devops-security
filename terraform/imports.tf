import {
	to = aws_iam_group.ops_leads_group
	id = "ops-leads"
}

import {
 	to = aws_iam_group_policy_attachment.admin
	id = "ops-leads/arn:aws:iam::aws:policy/AdministratorAccess"
}
import {
 	to = aws_iam_group_policy_attachment.manageAccessKeys
	id = "ops-leads/arn:aws:iam::035866691871:policy/ManageAccessKeys"
}
