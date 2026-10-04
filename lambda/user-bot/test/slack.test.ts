import { describe, expect, it, vi } from "vitest";

import { SLACK_POST_MESSAGE_URL, SlackMessageSender, SlackSendError } from "../src/senders/slack";
import { TEST_PASSWORD, TEST_SLACK_ID } from "./helpers";

const TOKEN = "xoxb-test-token-do-not-log";
const MESSAGE = { slackId: TEST_SLACK_ID, userName: "new.member", text: `password: ${TEST_PASSWORD}` };

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
}

function senderReturning(response: Response | Promise<Response>) {
  const fetchFn = vi.fn(async (_input: string, _init: RequestInit) => response);
  return { sender: new SlackMessageSender(TOKEN, fetchFn), fetchFn };
}

async function failureOf(promise: Promise<unknown>): Promise<SlackSendError> {
  const error = await promise.then(
    () => undefined,
    (e: unknown) => e,
  );
  expect(error).toBeInstanceOf(SlackSendError);
  const message = (error as Error).message;
  expect(message).not.toContain(TOKEN);
  expect(message).not.toContain(TEST_PASSWORD);
  expect(JSON.stringify(error)).not.toContain(TOKEN);
  return error as SlackSendError;
}

describe("SlackMessageSender", () => {
  it("posts the message to chat.postMessage as a DM to the member ID", async () => {
    const { sender, fetchFn } = senderReturning(jsonResponse({ ok: true, channel: "D123", ts: "1.2" }));

    await sender.send(MESSAGE);

    expect(fetchFn).toHaveBeenCalledTimes(1);
    const [url, init] = fetchFn.mock.calls[0]!;
    expect(url).toBe(SLACK_POST_MESSAGE_URL);
    expect(init.method).toBe("POST");
    expect(init.headers).toMatchObject({
      Authorization: `Bearer ${TOKEN}`,
      "Content-Type": "application/json; charset=utf-8",
    });
    expect(JSON.parse(init.body as string)).toEqual({
      channel: TEST_SLACK_ID,
      text: MESSAGE.text,
      unfurl_links: false,
      unfurl_media: false,
    });
  });

  it("resolves when Slack answers ok: true", async () => {
    const { sender } = senderReturning(jsonResponse({ ok: true }));
    await expect(sender.send(MESSAGE)).resolves.toBeUndefined();
  });

  // The case a status-only check gets wrong: Slack reports most failures as HTTP 200.
  it.each(["user_not_found", "channel_not_found", "invalid_auth", "not_authed"])(
    "rejects on HTTP 200 with ok: false (%s)",
    async (slackError) => {
      const { sender } = senderReturning(jsonResponse({ ok: false, error: slackError }));
      const error = await failureOf(sender.send(MESSAGE));
      expect(error.message).toContain(slackError);
    },
  );

  it("rejects on HTTP 200 with ok missing", async () => {
    const { sender } = senderReturning(jsonResponse({ channel: "D123" }));
    const error = await failureOf(sender.send(MESSAGE));
    expect(error.message).toContain("unknown_error");
  });

  it.each([429, 500, 503])("rejects on HTTP %i", async (status) => {
    const { sender } = senderReturning(jsonResponse({ ok: false, error: "ratelimited" }, status));
    const error = await failureOf(sender.send(MESSAGE));
    expect(error.message).toContain(String(status));
  });

  it("rejects when the body is not JSON", async () => {
    const { sender } = senderReturning(new Response("<html>bad gateway</html>", { status: 200 }));
    await failureOf(sender.send(MESSAGE));
  });

  it("rejects on a network error, without passing its details through", async () => {
    const networkError = new TypeError(`fetch failed: Bearer ${TOKEN} ${TEST_PASSWORD}`);
    const { sender } = senderReturning(Promise.reject(networkError));
    const error = await failureOf(sender.send(MESSAGE));
    expect(error.cause).toBeUndefined();
  });

  it("refuses to be constructed without a token", () => {
    expect(() => new SlackMessageSender("")).toThrow(SlackSendError);
  });
});
