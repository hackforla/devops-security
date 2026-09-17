// Defaults to true so that a contributor running this against their own AWS account,
// which is how changes are tested (see CONTRIBUTING.md), gets IAM resources only. The
// resources in cloudtrail.tf are specific to the Hack for LA account and cannot be
// created anywhere else.
//
// Any plan or apply against the Hack for LA account MUST set this to false. Both CI
// workflows do. See hackforla/devops-security#196.
variable "iam_only" {
  description = "Manage IAM resources only, skipping the Hack for LA account's CloudTrail trails and log buckets. Set to false for the Hack for LA account."
  type        = bool
  default     = true
}
