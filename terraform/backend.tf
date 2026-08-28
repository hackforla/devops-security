terraform {
  backend "s3" {
  }
}

provider "aws" {
  default_tags {
    tags = {
      managed-by = "terraform-devops-security"
    }
  }
}
