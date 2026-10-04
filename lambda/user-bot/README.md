# user-bot

A Lambda that gives each new IAM user a temporary AWS console password and sends it to them as a Slack DM, with sign-in instructions. Built in [#209](https://github.com/hackforla/devops-security/issues/209); connected to Slack in [#212](https://github.com/hackforla/devops-security/issues/212).

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

1. reads the Slack bot token (see [The Slack token](#the-slack-token)). **If that fails, it stops here and the user's password is not touched;**
2. generates a 20-character password containing all four character classes;
3. sets it with `UpdateLoginProfile` and `PasswordResetRequired: true`, so the user must replace it at first sign-in;
4. DMs the user, as the Slack app, with the sign-in page, their IAM user name and the temporary password.

Step 1 comes before the reset on purpose. Reading the token at send time would mean a bad token leaves the user with a new password that nobody received.

Every skip is logged with its reason and the user name. **The password is never logged**, on any path; the tests assert this.

The `managed-by` check is also enforced by IAM. The execution role may call `UpdateLoginProfile` only on users carrying that tag, so a bug or a hand-crafted invocation still cannot reset anyone else's password, such as an admin or a user tagged `exempt`. If you change the check in `src/handler.ts`, change the policy in `terraform/user-bot.tf` with it.

If sending fails after the password was changed, the function throws. Lambda's asynchronous retry then runs it again from the start, which sets a fresh password and sends again.

## The Slack token

The bot posts as a Slack app with the `chat:write` bot scope, and the app's **Messages tab** is turned on so that users can see the DM thread. Its bot token (`xoxb-…`) is stored in the SSM Parameter Store `SecureString` **`/user-bot/slack-bot-token`**, in us-east-1. The function finds it through its `SLACK_TOKEN_PARAMETER` environment variable.

Terraform (`terraform/user-bot.tf`) creates the parameter with a placeholder through the write-only `value_wo`. The real token is set by hand, so it never appears in git **or in Terraform state**. Read the comment above that resource before changing it: bumping `value_wo_version` writes the placeholder back over the real token.

To set or rotate the token, run this from your own terminal. It reads the token from a prompt, so it stays out of your shell history:

```bash
read -rs SLACK_TOKEN && MSYS_NO_PATHCONV=1 aws ssm put-parameter --region us-east-1 \
  --name /user-bot/slack-bot-token --type SecureString --overwrite --value "$SLACK_TOKEN"; unset SLACK_TOKEN
```

`MSYS_NO_PATHCONV=1` only matters in Git Bash on Windows, which would otherwise rewrite `/user-bot/...` into a Windows path.

The function keeps the token for the life of an execution environment, so a rotated token is picked up as environments are recycled. To pick it up at once, redeploy: run **Deploy user-bot Lambda** from the Actions tab.

If the token is missing, unreadable, or still the placeholder (anything not starting `xoxb-`), every user the bot would act on is **refused**:
- the password is left unchanged;
- an error naming the parameter is logged (never its value);
- the invocation fails, so it shows up in the function's error metrics.

A failed read is not cached, so the next new user is tried again.

## Layout

```
src/
  index.ts             Lambda entry point; wires the handler to SlackMessageSender
  handler.ts           the logic above
  slack-token.ts       reads and caches the token from SSM
  password.ts          password generation
  message.ts           the message text and sign-in URL
  logger.ts            JSON-line logger
  senders/
    types.ts           MessageSender interface
    slack.ts           SlackMessageSender (chat.postMessage)
    stub.ts            StubMessageSender (logs only; not deployed, kept for local runs and tests)
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
| The function's configuration, execution role, log group, EventBridge rule, the token parameter (not its value), and the deploy role | `terraform/user-bot.tf` and `terraform/aws-gha-oidc-providers.tf`, via the existing `terraform-plan.yaml` / `terraform-apply.yaml` | a `.tf` file changes |
| The function's **code** | `.github/workflows/user-bot-deploy.yml` | a change under `lambda/user-bot/` merges to `main` |

Pull requests touching `lambda/user-bot/` run `.github/workflows/user-bot-test.yml`, which typechecks, tests and builds with no AWS credentials.

Terraform created the function from a do-nothing placeholder and ignores changes to its code, so a deploy never shows up as drift and Terraform never reverts one.

The deploy workflow assumes `devops-security-user-bot-deploy`. That role only trusts runs on `main` and can only update this one function's code. To redeploy without a new commit, run **Deploy user-bot Lambda** from the Actions tab with `main` selected. Dispatching from any other branch fails at the credentials step by design.

## Logs

CloudWatch log group `/aws/lambda/user-bot` in **us-east-1**, kept for 90 days. Each line is JSON with `level`, `message` and fields such as `userName`, `slackId` and `reason`.
