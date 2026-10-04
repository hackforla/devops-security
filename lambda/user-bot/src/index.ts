import { IAMClient } from "@aws-sdk/client-iam";
import { SSMClient } from "@aws-sdk/client-ssm";

import { createHandler } from "./handler";
import { consoleLogger } from "./logger";
import { SlackMessageSender } from "./senders/slack";
import { createSlackTokenLoader } from "./slack-token";

// SLACK_TOKEN_PARAMETER names the SSM SecureString holding the Slack bot token; it is
// set by terraform/user-bot.tf. The token is read on the first invocation that needs to
// send, not at import, so a missing token surfaces as a logged refusal for that user
// rather than as a cold-start crash -- and always before their password is touched.
const loadSlackToken = createSlackTokenLoader(new SSMClient({}), process.env.SLACK_TOKEN_PARAMETER);

export const handler = createHandler({
  iam: new IAMClient({}),
  getSender: async () => new SlackMessageSender(await loadSlackToken()),
  logger: consoleLogger,
});
