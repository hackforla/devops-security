// Legacy IAM users.
//
// These accounts predate this Terraform and were created by hand, so they are
// declared as bare resources rather than through ./modules/aws-users. Two
// reasons, both deliberate:
//
//   1. The module also creates an aws_iam_user_login_profile. A login profile's
//      password cannot be read back from the IAM API, so importing one plans a
//      change against a live console password. These users keep their existing
//      login profiles, unmanaged.
//   2. The module assumes a user the module itself created, with a uniform tag
//      set and group membership. These accounts have neither.
//
// New users still go in aws-users.tf through the module. Nothing should be
// added here that is not already live in the account.

resource "aws_iam_user" "fangyiliu" {
  name = "fangyiliu"
}

resource "aws_iam_user" "jack_pashayan" {
  name = "jack.pashayan"
}

import {
  to = aws_iam_user.fangyiliu
  id = "fangyiliu"
}

import {
  to = aws_iam_user.jack_pashayan
  id = "jack.pashayan"
}
