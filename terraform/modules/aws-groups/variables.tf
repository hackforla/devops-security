# groups/variables.tf

variable "group_name" {
  description = "The name of the IAM group"
  type        = string
}

variable "group_path" {
  description = "Path in which to create the group"
  type        = string
  default     = "/"
}

variable "policy_arn" {
  description = "Map of policy names to ARNs to attach to the group"
  type        = map(string)
}
