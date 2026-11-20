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
// New users still go in aws-users.tf through the module. The one exception is
// food-oasis-local-dev below, which carries a legacy arrangement forward and must
// not have a console login.

resource "aws_iam_user" "fangyiliu" {
  name = "fangyiliu"
}

resource "aws_iam_user" "jack_pashayan" {
  name = "jack.pashayan"
}

// food-oasis-local-dev: a shared, program-only user for Food Oasis developers'
// local setups. Their .env files have always held an AWS access key, and the old
// one belongs to the Food Oasis account, which is being deleted
// (hackforla/incubator#284). The deployed services use their task roles instead.
//
// No login profile and no group, which is why it is a bare resource: the module
// would give it a console password and trigger the user-bot. The access key is
// created by hand and kept in the FOLA - DevOps vault, so it never enters the
// Terraform state.
//
// The policy covers exactly the two AWS calls the Food Oasis server makes, and
// no more: sending email as donotreply@foodoasis.net (the app's EMAIL_USER) and
// searching the staging place index. SES has production access in this account,
// so the From restriction is what stops a local run sending as any other address.
locals {
  food_oasis_region = "us-west-2"
}

resource "aws_iam_user" "food_oasis_local_dev" {
  name = "food-oasis-local-dev"

  tags = {
    "Project" = "food-oasis"
  }
}

resource "aws_iam_policy" "food_oasis_local_dev" {
  name        = "food-oasis-local-dev"
  description = "Food Oasis local development: send email as donotreply@foodoasis.net and search the staging place index"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SendAsDoNotReply"
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = "arn:aws:ses:${local.food_oasis_region}:${data.aws_caller_identity.current.account_id}:identity/foodoasis.net"
        Condition = {
          StringEquals = {
            "ses:FromAddress" = "donotreply@foodoasis.net"
          }
        }
      },
      {
        Sid      = "SearchStagingPlaceIndex"
        Effect   = "Allow"
        Action   = ["geo:SearchPlaceIndexForText"]
        Resource = "arn:aws:geo:${local.food_oasis_region}:${data.aws_caller_identity.current.account_id}:place-index/food-oasis-stage"
      },
    ]
  })

  tags = {
    "Project" = "food-oasis"
  }
}

resource "aws_iam_user_policy_attachment" "food_oasis_local_dev" {
  user       = aws_iam_user.food_oasis_local_dev.name
  policy_arn = aws_iam_policy.food_oasis_local_dev.arn
}
