// Create user and assign to group(s)
module "iam_user_gwenstacy" {
  source = "./modules/aws-users"

  user_name = "gwenstacy"
  user_tags = {
    "Environment" = "Development"
    "Project"     = "spiderverse"
  }
  user_groups = ["read-only-group"]
}
