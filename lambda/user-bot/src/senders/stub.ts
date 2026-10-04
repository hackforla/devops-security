import type { Logger } from "../logger";
import type { DirectMessage, MessageSender } from "./types";

// What the deployed Lambda uses until it is switched to SlackMessageSender, which
// needs a Slack app and bot token that do not exist yet. It sends nothing and logs
// who would have been messaged, never the message itself.
export class StubMessageSender implements MessageSender {
  constructor(private readonly logger: Logger) {}

  async send(message: DirectMessage): Promise<void> {
    this.logger.warn("Slack DM not sent: no Slack transport is configured", {
      userName: message.userName,
      slackId: message.slackId,
    });
  }
}
