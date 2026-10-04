import { describe, expect, it } from "vitest";

import { StubMessageSender } from "../src/senders/stub";
import { captureLogger, TEST_PASSWORD, TEST_SLACK_ID } from "./helpers";

describe("StubMessageSender", () => {
  it("logs who would have been messaged, never the message", async () => {
    const logger = captureLogger();

    await new StubMessageSender(logger).send({
      slackId: TEST_SLACK_ID,
      userName: "new.member",
      text: `password: ${TEST_PASSWORD}`,
    });

    expect(logger.lines).toHaveLength(1);
    expect(logger.lines[0]!.fields).toEqual({ userName: "new.member", slackId: TEST_SLACK_ID });
    expect(logger.text()).not.toContain(TEST_PASSWORD);
  });
});
