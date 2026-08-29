terraform {
  // Pins major and minor; patch releases are still picked up. Without this the
  // dflook plan/apply actions take whatever the latest Terraform release is, so
  // CI silently upgraded itself -- state has been written by 1.7 through 1.16.
  // This line alone chooses the CI Terraform version.
  required_version = "~> 1.16.0"
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
