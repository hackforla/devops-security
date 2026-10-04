// Exercises src/index.ts -- the wiring that is actually deployed -- with SSM, IAM and
// Slack's HTTP API all mocked. Each test imports a fresh copy of the module, because
// the token cache lives in module scope.
import { IAMClient, ListUserTagsCommand, UpdateLoginProfileCommand } from "@aws-sdk/client-iam";
import { GetParameterCommand, SSMClient } from "@aws-sdk/client-ssm";
import { mockClient } from "aws-sdk-client-mock";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { SLACK_POST_MESSAGE_URL } from "../src/senders/slack";
import { createLoginProfileEvent, TEST_SLACK_ID } from "./helpers";

const iamMock = mockClient(IAMClient);
const ssmMock = mockClient(SSMClient);
const TOKEN = "xoxb-real-token-do-not-log";

async function freshHandler() {
  vi.resetModules();
  const { handler } = await import("../src/index");
  return handler;
}

let fetchMock: ReturnType<typeof vi.fn>;
let logged: string[];

beforeEach(() => {
  iamMock.reset();
  ssmMock.reset();
  iamMock.on(ListUserTagsCommand).resolves({
    Tags: [
      { Key: "managed-by", Value: "terraform-devops-security" },
      { Key: "slack_id", Value: TEST_SLACK_ID },
    ],
  });
  iamMock.on(UpdateLoginProfileCommand).resolves({});
  vi.stubEnv("SLACK_TOKEN_PARAMETER", "/user-bot/slack-bot-token");
  fetchMock = vi.fn(async () => new Response(JSON.stringify({ ok: true }), { status: 200 }));
  vi.stubGlobal("fetch", fetchMock);
  logged = [];
  vi.spyOn(console, "log").mockImplementation((line: unknown) => void logged.push(String(line)));
});

afterEach(() => {
  vi.unstubAllEnvs();
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

describe("deployed handler", () => {
  it("reads the token, resets the password, and DMs the user through Slack", async () => {
    ssmMock.on(GetParameterCommand).resolves({ Parameter: { Value: TOKEN } });
    const handler = await freshHandler();

    const result = await handler(createLoginProfileEvent());

    expect(result).toEqual({ outcome: "sent", userName: "new.member" });
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(1);
    expect(fetchMock).toHaveBeenCalledTimes(1);
    const [url, init] = fetchMock.mock.calls[0]! as [string, RequestInit];
    expect(url).toBe(SLACK_POST_MESSAGE_URL);
    expect((init.headers as Record<string, string>).Authorization).toBe(`Bearer ${TOKEN}`);
    expect(JSON.parse(init.body as string).channel).toBe(TEST_SLACK_ID);

    const password = iamMock.commandCalls(UpdateLoginProfileCommand)[0]!.args[0].input.Password!;
    expect(logged.join("\n")).not.toContain(password);
    expect(logged.join("\n")).not.toContain(TOKEN);
  });

  it("refuses while the parameter still holds Terraform's placeholder: password untouched", async () => {
    ssmMock.on(GetParameterCommand).resolves({ Parameter: { Value: "placeholder-set-by-hand" } });
    const handler = await freshHandler();

    await expect(handler(createLoginProfileEvent())).rejects.toThrow("SlackTokenError");
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(0);
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it("refuses when SLACK_TOKEN_PARAMETER is unset: password untouched", async () => {
    vi.stubEnv("SLACK_TOKEN_PARAMETER", "");
    const handler = await freshHandler();

    await expect(handler(createLoginProfileEvent())).rejects.toThrow("SlackTokenError");
    expect(ssmMock.calls()).toHaveLength(0);
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(0);
  });
});
