# user-bot

A Lambda that gives each new IAM user a temporary AWS console password and sends it to them as a Slack DM, with sign-in instructions. Tracked in [#209](https://github.com/hackforla/devops-security/issues/209).

> **Not sending DMs yet.** The deployed function uses `StubMessageSender`, which sends nothing and logs who would have been messaged. `SlackMessageSender` is written and tested, but switching to it needs a Slack app, its bot token, a secret the function can read, and permission to read it. None of these exist yet. Until then, the bot resets the password and the new user does not receive it, which is no worse than before: the password Terraform generates was never sent to anyone either.

## When it runs

1. A new user is added to `terraform/aws-users.tf` and merged. `Terraform Apply` creates the user and then its console login profile.
2. The `CreateLoginProfile` call is recorded by CloudTrail, which delivers it to EventBridge in **us-east-1**, the only region IAM events reach.
3. The rule `user-bot-create-login-profile` invokes the `user-bot` function, also in us-east-1. Failed `CreateLoginProfile` calls are filtered out.

The trigger is `CreateLoginProfile`, not `CreateUser`. Terraform calls `CreateUser` a moment before it creates the login profile, so a `CreateUser` trigger could try to update a profile that does not exist yet.

## What it does

It reads the user's tags and **does nothing at all** (no password change, no message) unless **both** of these hold:

| Tag | Required value |
|---|---|
| `managed-by` | exactly `terraform-devops-security`, i.e. the user was created by this repo's Terraform |
| `slack_id` | a Slack member ID such as `U0123456789`, set with the `slack_id` input of the `aws-users` module |

When both hold, it:

1. generates a 20-character password containing all four character classes;
2. sets it with `UpdateLoginProfile` and `PasswordResetRequired: true`, so the user must replace it at first sign-in;
3. sends the user a message with the sign-in page, their IAM user name and the temporary password.

Every skip is logged with its reason and the user name. **The password is never logged**, on any path; the tests assert this.

The `managed-by` check is also enforced by IAM. The execution role may call `UpdateLoginProfile` only on users carrying that tag, so a bug or a hand-crafted invocation still cannot reset anyone else's password, such as an admin or a user tagged `exempt`. If you change the check in `src/handler.ts`, change the policy in `terraform/user-bot.tf` with it.

If sending fails after the password was changed, the function throws. Lambda's asynchronous retry then runs it again from the start, which sets a fresh password and sends again.

## Layout

```
src/
  index.ts             Lambda entry point; wires the handler to the stub sender
  handler.ts           the logic above
  password.ts          password generation
  message.ts           the message text and sign-in URL
  logger.ts            JSON-line logger
  senders/
    types.ts           MessageSender interface
    slack.ts           SlackMessageSender (chat.postMessage)
    stub.ts            StubMessageSender (logs only)
test/                  Vitest unit tests; AWS is mocked with aws-sdk-client-mock, Slack by mocking fetch
```

## Running the tests

Use the Node version in `.nvmrc` (24), the same as the Lambda runtime. A dependency's native binding requires Node `^20.19.0` or `>=22.12.0`, and an older Node skips installing it.

```bash
cd lambda/user-bot
npm ci
npm run typecheck
npm test
npm run build      # writes dist/index.js, the file that is deployed
```

None of these needs AWS credentials or a Slack token.

## How it is deployed

Two halves, each with its own workflow:

| | Managed by | Runs when |
|---|---|---|
| The function's configuration, execution role, log group, EventBridge rule, and the deploy role | `terraform/user-bot.tf` and `terraform/aws-gha-oidc-providers.tf`, via the existing `terraform-plan.yaml` / `terraform-apply.yaml` | a `.tf` file changes |
| The function's **code** | `.github/workflows/user-bot-deploy.yml` | a change under `lambda/user-bot/` merges to `main` |

Pull requests touching `lambda/user-bot/` run `.github/workflows/user-bot-test.yml`, which typechecks, tests and builds with no AWS credentials.

Terraform created the function from a do-nothing placeholder and ignores changes to its code, so a deploy never shows up as drift and Terraform never reverts one.

The deploy workflow assumes `devops-security-user-bot-deploy`. That role only trusts runs on `main` and can only update this one function's code. To redeploy without a new commit, run **Deploy user-bot Lambda** from the Actions tab with `main` selected. Dispatching from any other branch fails at the credentials step by design.

## Logs

CloudWatch log group `/aws/lambda/user-bot` in **us-east-1**, kept for 90 days. Each line is JSON with `level`, `message` and fields such as `userName`, `slackId` and `reason`.
