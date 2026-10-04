import {
  IAMClient,
  ListUserTagsCommand,
  NoSuchEntityException,
  UpdateLoginProfileCommand,
} from "@aws-sdk/client-iam";
import { mockClient } from "aws-sdk-client-mock";
import { beforeEach, describe, expect, it, vi } from "vitest";

import { createHandler, type Dependencies } from "../src/handler";
import { SIGN_IN_URL } from "../src/message";
import { generatePassword } from "../src/password";
import type { DirectMessage, MessageSender } from "../src/senders/types";
import { captureLogger, createLoginProfileEvent, TEST_PASSWORD, TEST_SLACK_ID } from "./helpers";

const iamMock = mockClient(IAMClient);

const MANAGED = { Key: "managed-by", Value: "terraform-devops-security" };
const SLACK = { Key: "slack_id", Value: TEST_SLACK_ID };

function setup(tags: { Key: string; Value: string }[] = [MANAGED, SLACK]) {
  iamMock.on(ListUserTagsCommand).resolves({ Tags: tags, IsTruncated: false });
  iamMock.on(UpdateLoginProfileCommand).resolves({});

  const sent: DirectMessage[] = [];
  const sender: MessageSender = { send: vi.fn(async (message) => void sent.push(message)) };
  const logger = captureLogger();
  const deps: Dependencies = {
    iam: new IAMClient({ region: "us-east-1" }),
    sender,
    logger,
    generatePassword: () => TEST_PASSWORD,
  };
  return { handler: createHandler(deps), sender, sent, logger };
}

beforeEach(() => {
  iamMock.reset();
});

describe("happy path", () => {
  it("resets the password with a forced change and sends it to the slack_id", async () => {
    const { handler, sent, logger } = setup();

    const result = await handler(createLoginProfileEvent());

    expect(result).toEqual({ outcome: "sent", userName: "new.member" });
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(1);
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)[0]!.args[0].input).toEqual({
      UserName: "new.member",
      Password: TEST_PASSWORD,
      PasswordResetRequired: true,
    });
    expect(sent).toHaveLength(1);
    expect(sent[0]!.slackId).toBe(TEST_SLACK_ID);
    expect(sent[0]!.userName).toBe("new.member");
    expect(sent[0]!.text).toContain(TEST_PASSWORD);
    expect(sent[0]!.text).toContain("new.member");
    expect(sent[0]!.text).toContain(SIGN_IN_URL);
    expect(logger.text()).not.toContain(TEST_PASSWORD);
  });

  it("reads tags across pages", async () => {
    const { handler, sent } = setup();
    iamMock
      .on(ListUserTagsCommand)
      .resolvesOnce({ Tags: [MANAGED], IsTruncated: true, Marker: "page-2" })
      .resolvesOnce({ Tags: [SLACK], IsTruncated: false });

    const result = await handler(createLoginProfileEvent());

    expect(result.outcome).toBe("sent");
    expect(iamMock.commandCalls(ListUserTagsCommand)[1]!.args[0].input.Marker).toBe("page-2");
    expect(sent).toHaveLength(1);
  });
});

describe("skips without touching the password or sending anything", () => {
  const cases: [string, { Key: string; Value: string }[], string][] = [
    ["managed-by is missing", [SLACK], "not-managed-by-devops-security"],
    ["managed-by is exempt", [{ Key: "managed-by", Value: "exempt" }, SLACK], "not-managed-by-devops-security"],
    [
      "managed-by is another Terraform state",
      [{ Key: "managed-by", Value: "terraform-incubator" }, SLACK],
      "not-managed-by-devops-security",
    ],
    ["slack_id is missing", [MANAGED], "no-slack-id"],
    ["slack_id is empty", [MANAGED, { Key: "slack_id", Value: "" }], "no-slack-id"],
    ["slack_id is a handle", [MANAGED, { Key: "slack_id", Value: "@new.member" }], "invalid-slack-id"],
    ["no tags at all", [], "not-managed-by-devops-security"],
  ];

  it.each(cases)("when %s", async (_name, tags, reason) => {
    const { handler, sender, logger } = setup(tags);

    const result = await handler(createLoginProfileEvent());

    expect(result).toEqual({ outcome: "skipped", reason, userName: "new.member" });
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(0);
    expect(sender.send).not.toHaveBeenCalled();
    expect(logger.lines).toContainEqual(
      expect.objectContaining({ fields: expect.objectContaining({ reason, userName: "new.member" }) }),
    );
  });

  it("when the event is not CreateLoginProfile", async () => {
    const { handler, sender } = setup();

    const result = await handler(createLoginProfileEvent({ eventName: "CreateUser" }));

    expect(result).toEqual({ outcome: "skipped", reason: "not-create-login-profile", userName: undefined });
    expect(iamMock.calls()).toHaveLength(0);
    expect(sender.send).not.toHaveBeenCalled();
  });

  it("when the CreateLoginProfile call itself failed", async () => {
    const { handler, sender } = setup();

    const result = await handler(createLoginProfileEvent({ errorCode: "EntityAlreadyExistsException" }));

    expect(result.outcome).toBe("skipped");
    expect(result).toMatchObject({ reason: "api-call-failed" });
    expect(iamMock.calls()).toHaveLength(0);
    expect(sender.send).not.toHaveBeenCalled();
  });

  it("when the event has no user name", async () => {
    const { handler, sender } = setup();

    const result = await handler(createLoginProfileEvent({ requestParameters: null }));

    expect(result).toMatchObject({ outcome: "skipped", reason: "no-user-name" });
    expect(iamMock.calls()).toHaveLength(0);
    expect(sender.send).not.toHaveBeenCalled();
  });

  it("when the user no longer exists", async () => {
    const { handler, sender } = setup();
    iamMock
      .on(ListUserTagsCommand)
      .rejects(new NoSuchEntityException({ message: "user not found", $metadata: {} }));

    const result = await handler(createLoginProfileEvent());

    expect(result).toMatchObject({ outcome: "skipped", reason: "user-not-found" });
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(0);
    expect(sender.send).not.toHaveBeenCalled();
  });
});

describe("failures", () => {
  it("rethrows when ListUserTags fails for another reason, and changes nothing", async () => {
    const { handler, sender } = setup();
    iamMock.on(ListUserTagsCommand).rejects(new Error("throttled"));

    await expect(handler(createLoginProfileEvent())).rejects.toThrow();
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(0);
    expect(sender.send).not.toHaveBeenCalled();
  });

  it("sends nothing when UpdateLoginProfile fails", async () => {
    const { handler, sender, logger } = setup();
    const failure = new Error("denied");
    failure.name = "AccessDeniedException";
    iamMock.on(UpdateLoginProfileCommand).rejects(failure);

    const error = await handler(createLoginProfileEvent()).catch((e: unknown) => e);

    expect(error).toBeInstanceOf(Error);
    expect((error as Error).message).toContain("AccessDeniedException");
    expect((error as Error).message).not.toContain(TEST_PASSWORD);
    expect(sender.send).not.toHaveBeenCalled();
    expect(logger.text()).not.toContain(TEST_PASSWORD);
  });

  it("throws when the send fails, without the password in the error or the logs", async () => {
    const { handler, sender, logger } = setup();
    vi.mocked(sender.send).mockRejectedValueOnce(new Error(`boom ${TEST_PASSWORD}`));

    const error = await handler(createLoginProfileEvent()).catch((e: unknown) => e);

    expect(error).toBeInstanceOf(Error);
    expect((error as Error).message).not.toContain(TEST_PASSWORD);
    expect(iamMock.commandCalls(UpdateLoginProfileCommand)).toHaveLength(1);
    expect(logger.text()).not.toContain(TEST_PASSWORD);
    expect(logger.lines).toContainEqual(expect.objectContaining({ level: "error" }));
  });
});

describe("the password never reaches a log", () => {
  it("on any path, with the real password generator", async () => {
    const { logger } = setup();
    const generated: string[] = [];
    const handler = createHandler({
      iam: new IAMClient({ region: "us-east-1" }),
      sender: { send: async () => {} },
      logger,
      generatePassword: () => {
        const password = generatePassword();
        generated.push(password);
        return password;
      },
    });

    await handler(createLoginProfileEvent());

    expect(generated).toHaveLength(1);
    expect(logger.text()).not.toContain(generated[0]!);
  });
});
