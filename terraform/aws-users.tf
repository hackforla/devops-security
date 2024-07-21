// Create user and assign to group(s)
module "iam_user_JimmyJuarez10" {
  source = "./modules/aws-users"

  user_name = "JimmyJuarez10"
  user_tags = {
    "Project" = "civic-tech-jobs"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_tylerthome" {
  source = "./modules/aws-users"

  user_name = "tyler.thome"
  user_tags = {
    "Project"      = "home-unite-us"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_brittanyms" {
  source = "./modules/aws-users"

  user_name = "brittanyms"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_freaky4wrld" {
  source = "./modules/aws-users"

  user_name = "freaky4wrld"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_shikha0428" {
  source = "./modules/aws-users"

  user_name = "shikha0428"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_shinjonathan" {
  source = "./modules/aws-users"

  user_name = "shinjonathan"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_samuelusc" {
  source = "./modules/aws-users"

  user_name = "samuelusc"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_abbyz123" {
  source = "./modules/aws-users"

  user_name = "abbyz123"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_awlFCCamp" {
  source = "./modules/aws-users"

  user_name = "awlFCCamp"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_testiamuser" {
  source = "./modules/aws-users"

  user_name = "testiamuser"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_chelseyb" {
  source = "./modules/aws-users"

  user_name = "chelseyb"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group", "iam-services-supervisor-group"]
}

module "iam_user_jbubar" {
  source = "./modules/aws-users"

  user_name = "jbubar"
  user_tags = {
    "Project"      = "vrms"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_spiteless" {
  source = "./modules/aws-users"

  user_name = "spiteless"
  user_tags = {
    "Project"      = "vrms"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_alexe" {
  source = "./modules/aws-users"

  user_name = "alexe"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}