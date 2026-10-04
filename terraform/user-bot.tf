// The user-bot Lambda: when a new IAM user gets a console login profile, it sets a
// temporary password and DMs it to the person on Slack. See
// hackforla/devops-security#209 and lambda/user-bot/README.md.
//
// Terraform owns everything about the function except its code. The real code is
// built and shipped by .github/workflows/user-bot-deploy.yml, which assumes the
// devops-security-user-bot-deploy role declared in aws-gha-oidc-providers.tf. Here the
// function is created from a placeholder, and ignore_changes stops Terraform reverting
// whatever the deploy workflow last pushed.
//
// Everything that is regional lives in us-east-1, not the provider's us-west-2. IAM is
// a global service and its CloudTrail events are delivered to EventBridge only in
// us-east-1, and an EventBridge rule can only target a Lambda in its own region. The
// events come from the management-events trail in cloudtrail.tf, which is multi-region
// and includes global service events.

data "aws_caller_identity" "current" {}

locals {
  user_bot_region = "us-east-1"
}

// ---------------------------------------------------------------------------
// Trigger
// ---------------------------------------------------------------------------

// CreateLoginProfile rather than CreateUser: the aws-users module calls CreateUser a
// moment before CreateLoginProfile, so a Lambda triggered by CreateUser could try to
// update a login profile that does not exist yet. By the time this event fires, the
// user, its tags and its login profile all exist.
//
// Failed calls are recorded by CloudTrail too, with an errorCode. Those are excluded:
// a failed CreateLoginProfile did not create anything to act on.
resource "aws_cloudwatch_event_rule" "user_bot" {
  region = local.user_bot_region

  name        = "user-bot-create-login-profile"
  description = "Invokes the user-bot Lambda when an IAM user is given a console login profile"

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["iam.amazonaws.com"]
      eventName   = ["CreateLoginProfile"]
      errorCode   = [{ exists = false }]
    }
  })
}

resource "aws_cloudwatch_event_target" "user_bot" {
  region = local.user_bot_region

  rule = aws_cloudwatch_event_rule.user_bot.name
  arn  = aws_lambda_function.user_bot.arn
}

resource "aws_lambda_permission" "user_bot_eventbridge" {
  region = local.user_bot_region

  statement_id  = "AllowInvokeFromCreateLoginProfileRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_bot.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.user_bot.arn
}

// ---------------------------------------------------------------------------
// Function
// ---------------------------------------------------------------------------

// Declared so it carries the default tags and a retention period. Without it, Lambda
// creates the group on first invocation, untagged and never expiring.
resource "aws_cloudwatch_log_group" "user_bot" {
  region = local.user_bot_region

  name              = "/aws/lambda/user-bot"
  retention_in_days = 90
}

// Stands in until the deploy workflow ships the real code. It deliberately does
// nothing: an event arriving before the first deploy must not reset anyone's password.
data "archive_file" "user_bot_placeholder" {
  type        = "zip"
  output_path = "${path.module}/.terraform/user-bot-placeholder.zip"

  source {
    filename = "index.js"
    content  = <<-EOT
      exports.handler = async () => {
        console.log("user-bot placeholder: no code deployed yet, taking no action");
      };
    EOT
  }
}

resource "aws_lambda_function" "user_bot" {
  region = local.user_bot_region

  function_name = "user-bot"
  description   = "DMs new IAM users a temporary console password. Code is deployed by user-bot-deploy.yml in hackforla/devops-security."
  role          = aws_iam_role.user_bot.arn

  // Must match lambda/user-bot/.nvmrc, which is what CI builds and tests with.
  runtime     = "nodejs24.x"
  handler     = "index.handler"
  timeout     = 30
  memory_size = 128

  filename         = data.archive_file.user_bot_placeholder.output_path
  source_code_hash = data.archive_file.user_bot_placeholder.output_base64sha256

  // The name, not the token. The function reads and decrypts the value at cold start.
  environment {
    variables = {
      SLACK_TOKEN_PARAMETER = aws_ssm_parameter.user_bot_slack_token.name
    }
  }

  depends_on = [aws_cloudwatch_log_group.user_bot]

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

// ---------------------------------------------------------------------------
// Slack bot token
// ---------------------------------------------------------------------------

// The Slack app's bot token (xoxb-...). Terraform creates the parameter with a
// placeholder; the real token is set by hand with `aws ssm put-parameter --overwrite`
// (see lambda/user-bot/README.md), so it never appears in git or in Terraform state.
// See hackforla/devops-security#212.
//
// value_wo rather than value is what keeps the token out of state. With `value`, the
// provider reads the decrypted parameter back into state on every refresh. With the
// write-only value_wo, its read sets `value` to null, and the value is only ever
// written when value_wo_version changes.
//
// Two traps, both because the real value lives outside Terraform:
//   - Never change value_wo_version. That writes the placeholder over the real token,
//     and the bot refuses to send until the token is set again.
//   - Do not change other arguments, such as description, in place. The provider then
//     sends an empty value and the apply fails.
resource "aws_ssm_parameter" "user_bot_slack_token" {
  region = local.user_bot_region

  name        = "/user-bot/slack-bot-token"
  description = "Slack bot token for the user-bot Lambda. Set by hand; see lambda/user-bot/README.md in hackforla/devops-security."
  type        = "SecureString"

  value_wo         = "placeholder-set-by-hand"
  value_wo_version = 1

  lifecycle {
    prevent_destroy = true
  }
}

// ---------------------------------------------------------------------------
// Execution role
// ---------------------------------------------------------------------------

resource "aws_iam_role" "user_bot" {
  name = "user-bot"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

// The tag condition on UpdateLoginProfile is the important part. Without it this role
// could reset the console password of any user in the account, including admins and
// the users tagged managed-by = exempt. The Lambda checks the same tag in code; this
// makes IAM enforce it even if the code is wrong or the function is invoked with a
// crafted event.
resource "aws_iam_role_policy" "user_bot" {
  name = "user-bot"
  role = aws_iam_role.user_bot.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadUserTags"
        Effect   = "Allow"
        Action   = "iam:ListUserTags"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
      },
      {
        Sid      = "ResetPasswordOfDevopsSecurityUsersOnly"
        Effect   = "Allow"
        Action   = "iam:UpdateLoginProfile"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
        Condition = {
          StringEquals = {
            "iam:ResourceTag/managed-by" = "terraform-devops-security"
          }
        }
      },
      // No kms:Decrypt statement: the parameter uses the AWS-managed aws/ssm key, whose
      // key policy already allows decryption through SSM for principals in the account.
      {
        Sid      = "ReadSlackToken"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = aws_ssm_parameter.user_bot_slack_token.arn
      },
      {
        Sid      = "WriteOwnLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.user_bot.arn}:*"
      }
    ]
  })
}
