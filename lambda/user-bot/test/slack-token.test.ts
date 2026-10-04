import { GetParameterCommand, ParameterNotFound, SSMClient } from "@aws-sdk/client-ssm";
import { mockClient } from "aws-sdk-client-mock";
import { beforeEach, describe, expect, it } from "vitest";

import { createSlackTokenLoader, SlackTokenError } from "../src/slack-token";

const ssmMock = mockClient(SSMClient);
const PARAMETER = "/user-bot/slack-bot-token";
const TOKEN = "xoxb-real-token-do-not-log";

beforeEach(() => {
  ssmMock.reset();
});

// Not a default parameter: loader(undefined) would then silently use PARAMETER.
function loader(...args: [name?: string | undefined]) {
  return createSlackTokenLoader(new SSMClient({ region: "us-east-1" }), args.length ? args[0] : PARAMETER);
}

async function failureOf(promise: Promise<unknown>): Promise<SlackTokenError> {
  const error = await promise.then(
    () => undefined,
    (e: unknown) => e,
  );
  expect(error).toBeInstanceOf(SlackTokenError);
  expect((error as Error).message).not.toContain(TOKEN);
  return error as SlackTokenError;
}

describe("createSlackTokenLoader", () => {
  it("reads the parameter with decryption and returns the token", async () => {
    ssmMock.on(GetParameterCommand).resolves({ Parameter: { Value: TOKEN } });

    await expect(loader()()).resolves.toBe(TOKEN);
    expect(ssmMock.commandCalls(GetParameterCommand)[0]!.args[0].input).toEqual({
      Name: PARAMETER,
      WithDecryption: true,
    });
  });

  it("reads SSM once and reuses the token across invocations", async () => {
    ssmMock.on(GetParameterCommand).resolves({ Parameter: { Value: TOKEN } });
    const load = loader();

    await load();
    await load();

    expect(ssmMock.commandCalls(GetParameterCommand)).toHaveLength(1);
  });

  it("does not cache a failure, so the next invocation reads again", async () => {
    ssmMock
      .on(GetParameterCommand)
      .resolvesOnce({ Parameter: { Value: "placeholder-set-by-hand" } })
      .resolvesOnce({ Parameter: { Value: TOKEN } });
    const load = loader();

    await failureOf(load());
    await expect(load()).resolves.toBe(TOKEN);
    expect(ssmMock.commandCalls(GetParameterCommand)).toHaveLength(2);
  });

  it("fails when SLACK_TOKEN_PARAMETER is not set, without calling SSM", async () => {
    const error = await failureOf(loader(undefined)());
    expect(error.message).toContain("SLACK_TOKEN_PARAMETER");
    expect(ssmMock.calls()).toHaveLength(0);
  });

  it("fails when the parameter does not exist", async () => {
    ssmMock.on(GetParameterCommand).rejects(new ParameterNotFound({ message: "not found", $metadata: {} }));
    const error = await failureOf(loader()());
    expect(error.message).toContain("ParameterNotFound");
  });

  it("fails when access is denied", async () => {
    const denied = new Error("not authorized");
    denied.name = "AccessDeniedException";
    ssmMock.on(GetParameterCommand).rejects(denied);
    const error = await failureOf(loader()());
    expect(error.message).toContain("AccessDeniedException");
  });

  it.each([
    ["still the Terraform placeholder", "placeholder-set-by-hand"],
    ["a user token rather than a bot token", "xoxp-user-token"],
    ["empty", ""],
  ])("fails when the value is %s", async (_name, value) => {
    ssmMock.on(GetParameterCommand).resolves({ Parameter: { Value: value } });
    const error = await failureOf(loader()());
    expect(error.message).toContain("does not hold a Slack bot token");
    expect(error.message).not.toContain(value || "\u0000");
  });

  it("fails when SSM returns no value at all", async () => {
    ssmMock.on(GetParameterCommand).resolves({});
    await failureOf(loader()());
  });
});
