import type { Logger } from "../logger";
import type { DirectMessage, MessageSender } from "./types";

// Not deployed: index.ts wires the Lambda to SlackMessageSender. Kept for local runs and
// tests, where sending a real DM is unwanted. It sends nothing and logs who would have
// been messaged, never the message itself.
export class StubMessageSender implements MessageSender {
  constructor(private readonly logger: Logger) {}

  async send(message: DirectMessage): Promise<void> {
    this.logger.warn("Slack DM not sent: no Slack transport is configured", {
      userName: message.userName,
      slackId: message.slackId,
    });
  }
}
