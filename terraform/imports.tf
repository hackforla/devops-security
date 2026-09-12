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

// Adopts the two CloudTrail trails and their two log buckets. See
// hackforla/devops-security#191 and the commentary in cloudtrail.tf.
//
// A trail imports by its full ARN, NOT by its name. The name fails against the pinned
// provider with `could not parse import ID "management-events" as ARN: arn: invalid
// prefix`. Every S3 resource below imports by bucket name, including the policy, public
// access block, encryption and ownership controls, each of which is its own resource.

import {
  to = aws_cloudtrail.tf_backend_logs
  id = "arn:aws:cloudtrail:us-west-2:035866691871:trail/devops-security-tf-backend-logs"
}

import {
  to = aws_s3_bucket.tf_backend_logs
  id = "aws-cloudtrail-logs-035866691871-4b8654bf"
}

import {
  to = aws_s3_bucket_policy.tf_backend_logs
  id = "aws-cloudtrail-logs-035866691871-4b8654bf"
}

import {
  to = aws_s3_bucket_public_access_block.tf_backend_logs
  id = "aws-cloudtrail-logs-035866691871-4b8654bf"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.tf_backend_logs
  id = "aws-cloudtrail-logs-035866691871-4b8654bf"
}

import {
  to = aws_s3_bucket_ownership_controls.tf_backend_logs
  id = "aws-cloudtrail-logs-035866691871-4b8654bf"
}

import {
  to = aws_cloudtrail.management_events
  id = "arn:aws:cloudtrail:us-west-2:035866691871:trail/management-events"
}

import {
  to = aws_s3_bucket.management_events
  id = "aws-cloudtrail-logs-035866691871-6539ef03"
}

import {
  to = aws_s3_bucket_policy.management_events
  id = "aws-cloudtrail-logs-035866691871-6539ef03"
}

import {
  to = aws_s3_bucket_public_access_block.management_events
  id = "aws-cloudtrail-logs-035866691871-6539ef03"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.management_events
  id = "aws-cloudtrail-logs-035866691871-6539ef03"
}
