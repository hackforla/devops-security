module "iam_user_tylerthome" {
  source = "./modules/aws-users"

  user_name = "tyler.thome"
  user_tags = {
    "Project"      = "home-unite-us"
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


module "iam_user_alexe" {
  source = "./modules/aws-users"

  user_name = "alexe"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["ops-leads"]
}

module "iam_user_rsakuma" {
  source = "./modules/aws-users"

  user_name = "rsakuma"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["ops-leads"]
}

module "iam_user_npang4" {
  source = "./modules/aws-users"

  user_name = "npang4"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_drakeredwind01" {
  source = "./modules/aws-users"

  user_name = "drakeredwind01"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_srinipandiyan" {
  source = "./modules/aws-users"

  user_name = "srinipandiyan"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_bltomlin" {
  source = "./modules/aws-users"

  user_name = "bltomlin"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_gmgonzal" {
  source = "./modules/aws-users"

  user_name = "gmgonzal"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_Bwoltz" {
  source = "./modules/aws-users"

  user_name = "Bwoltz"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_raibarra" {
  source = "./modules/aws-users"

  user_name = "raibarra04"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_ezesalvatore4" {
  source = "./modules/aws-users"

  user_name = "ezesalvatore" 
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_here" {
  source = "./modules/aws-users"

  user_name = "here" # Replace with GitHub handle
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}
