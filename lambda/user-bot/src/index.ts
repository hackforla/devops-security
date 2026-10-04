import { IAMClient } from "@aws-sdk/client-iam";

import { createHandler } from "./handler";
import { consoleLogger } from "./logger";
import { StubMessageSender } from "./senders/stub";

// Wired to the stub sender on purpose. Switching to SlackMessageSender needs a Slack
// app, its bot token, a secret the function can read, and permission to read it --
// none of which exist yet. See the "Out of scope" section of
// hackforla/devops-security#209.
export const handler = createHandler({
  iam: new IAMClient({}),
  sender: new StubMessageSender(consoleLogger),
  logger: consoleLogger,
});
