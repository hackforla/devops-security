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

module "iam_user_ale210" {
  source = "./modules/aws-users"

  user_name = "ale210"
  slack_id  = "U078B1S0XDM"
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


module "iam_user_benettonkkb" {
  source = "./modules/aws-users"

  user_name = "benettonkkb"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_Ganeshswaminathan1912" {
  source = "./modules/aws-users"

  user_name = "Ganeshswaminathan1912"
  user_tags = {
    "Project"      = "vrms"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}


module "iam_user_Sbairamian" {
  source = "./modules/aws-users"

  user_name = "sbairamian"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}

module "iam_user_here" {
  source = "./modules/aws-users"

  user_name = "here"
  slack_id  = "U07PKPHF7QQ"
  user_tags = {
    "Project"      = "devops-security"
    "Access Level" = "1"
  }
  user_groups = ["read-only-group"]
}
