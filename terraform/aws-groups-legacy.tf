// Legacy IAM groups.
//
// Declared as bare resources rather than through ./modules/aws-groups for the
// same reason as aws-users-legacy.tf: the module attaches a fixed policy set to
// a group it creates, and these groups predate it with policies attached by
// hand. Bringing one under the module would plan those attachments away.
//
// Note IAM groups cannot carry tags at all - AWS exposes no group tagging API -
// so a group never reports as managed in the coverage report no matter what is
// done here. Declaring it is still worth doing: it is what stops the group and
// its memberships drifting further.

resource "aws_iam_group" "project_leads" {
  name = "project-leads"
}

import {
  to = aws_iam_group.project_leads
  id = "project-leads"
}
