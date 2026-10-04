import type { DirectMessage, MessageSender } from "./types";

export const SLACK_POST_MESSAGE_URL = "https://slack.com/api/chat.postMessage";

// Messages carry no secrets: they name the failure but never include the token, the
// request, or the message text, any of which could end up in a log.
export class SlackSendError extends Error {
  override name = "SlackSendError";
}

type FetchFn = (input: string, init: RequestInit) => Promise<Response>;

// Sends a DM as the Slack app's bot user. Posting to a member ID as the channel opens
// (or reuses) the DM between the bot and that member, so only the chat:write scope is
// needed.
export class SlackMessageSender implements MessageSender {
  private readonly token: string;
  private readonly fetchFn: FetchFn;

  constructor(token: string, fetchFn: FetchFn = (input, init) => fetch(input, init)) {
    if (!token) {
      throw new SlackSendError("a Slack bot token is required");
    }
    this.token = token;
    this.fetchFn = fetchFn;
  }

  async send(message: DirectMessage): Promise<void> {
    let response: Response;
    try {
      response = await this.fetchFn(SLACK_POST_MESSAGE_URL, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.token}`,
          "Content-Type": "application/json; charset=utf-8",
        },
        body: JSON.stringify({
          channel: message.slackId,
          text: message.text,
          unfurl_links: false,
          unfurl_media: false,
        }),
      });
    } catch {
      // The underlying error is deliberately dropped: its cause can carry the request.
      throw new SlackSendError("request to Slack failed");
    }

    if (!response.ok) {
      throw new SlackSendError(`Slack returned HTTP ${response.status}`);
    }

    let body: unknown;
    try {
      body = await response.json();
    } catch {
      throw new SlackSendError("Slack returned a response that was not JSON");
    }

    // Slack reports most failures (user_not_found, channel_not_found, invalid_auth,
    // ...) as HTTP 200 with "ok": false. Checking only the status would report a DM
    // that was never delivered as sent.
    if (typeof body !== "object" || body === null || (body as { ok?: unknown }).ok !== true) {
      const error = (body as { error?: unknown } | null)?.error;
      throw new SlackSendError(
        `Slack chat.postMessage failed: ${typeof error === "string" ? error : "unknown_error"}`,
      );
    }
  }
}
