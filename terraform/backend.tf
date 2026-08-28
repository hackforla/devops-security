terraform {
  backend "s3" {
  }
}

// Region and profile come from the ambient environment at run time, not from here.
// managed-by is deliberately distinct from incubator's "terraform-incubator": account
// 035866691871 is written to by two Terraform states, and the tag says which one owns
// a resource. IAM groups and policy attachments cannot be tagged by any AWS API, so
// they carry no managed-by regardless of this block.
provider "aws" {
  default_tags {
    tags = {
      managed-by = "terraform-devops-security"
    }
  }
}
