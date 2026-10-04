# users/variables.tf

variable "user_name" {
  description = "The name of the IAM user"
  type        = string
}

variable "user_path" {
  description = "Path in which to create the user"
  type        = string
  default     = "/"
}

variable "user_tags" {
  description = "Tags to assign to the user"
  type        = map(string)
  default     = {}
}

variable "user_groups" {
  description = "List of IAM groups the user should be a member of"
  type        = list(string)
  default     = []
}

// The member ID, not the @handle. Handles are not unique and can be changed at any
// time, and Slack's API needs the ID to send a DM, so a handle here would send the
// user-bot's message nowhere. The validation makes that mistake fail at plan time.
variable "slack_id" {
  description = "Slack member ID of the person this user belongs to (Slack profile > Copy member ID). Stored as the user's slack_id tag, which the user-bot Lambda reads to DM them a temporary console password."
  type        = string
  default     = null

  validation {
    condition     = var.slack_id == null ? true : can(regex("^[UW][A-Z0-9]{8,}$", var.slack_id))
    error_message = "slack_id must be a Slack member ID such as U0123456789, not an @handle or display name."
  }
}
