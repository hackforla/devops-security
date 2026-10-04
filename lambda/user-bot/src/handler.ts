import {
  type IAMClient,
  ListUserTagsCommand,
  type Tag,
  UpdateLoginProfileCommand,
} from "@aws-sdk/client-iam";
import type { EventBridgeEvent } from "aws-lambda";

import type { Logger } from "./logger";
import { buildWelcomeMessage } from "./message";
import { generatePassword as defaultGeneratePassword } from "./password";
import type { MessageSender } from "./senders/types";

// Only users this repo's Terraform created are acted on. The execution role's IAM
// policy enforces the same tag on UpdateLoginProfile, so this check and that policy
// must change together.
export const MANAGED_BY_TAG = "managed-by";
export const MANAGED_BY_VALUE = "terraform-devops-security";
export const SLACK_ID_TAG = "slack_id";

// Same pattern as the slack_id validation in terraform/modules/aws-users/variables.tf.
// Checked here too because a tag can be set by hand, and a password must not be reset
// when it cannot be delivered.
export const SLACK_ID_PATTERN = /^[UW][A-Z0-9]{8,}$/;

// The fields of a CloudTrail record that this handler reads. EventBridge delivers the
// whole record as the event's detail.
export interface CloudTrailDetail {
  eventSource?: string;
  eventName?: string;
  errorCode?: string;
  requestParameters?: { userName?: string } | null;
}

export type CreateLoginProfileEvent = EventBridgeEvent<"AWS API Call via CloudTrail", CloudTrailDetail>;

export type SkipReason =
  | "not-create-login-profile"
  | "api-call-failed"
  | "no-user-name"
  | "user-not-found"
  | "not-managed-by-devops-security"
  | "no-slack-id"
  | "invalid-slack-id";

export type Result =
  | { outcome: "sent"; userName: string }
  | { outcome: "skipped"; reason: SkipReason; userName?: string };

export interface Dependencies {
  iam: IAMClient;
  sender: MessageSender;
  logger: Logger;
  generatePassword?: () => string;
}

async function listAllUserTags(iam: IAMClient, userName: string): Promise<Map<string, string>> {
  const tags = new Map<string, string>();
  let marker: string | undefined;
  do {
    const page = await iam.send(new ListUserTagsCommand({ UserName: userName, Marker: marker }));
    for (const tag of page.Tags ?? ([] as Tag[])) {
      if (tag.Key !== undefined && tag.Value !== undefined) {
        tags.set(tag.Key, tag.Value);
      }
    }
    marker = page.IsTruncated ? page.Marker : undefined;
  } while (marker);
  return tags;
}

function errorName(error: unknown): string {
  return error instanceof Error ? error.name : "UnknownError";
}

export function createHandler(deps: Dependencies) {
  const { iam, sender, logger } = deps;
  const generatePassword = deps.generatePassword ?? defaultGeneratePassword;

  function skip(reason: SkipReason, userName?: string): Result {
    logger.info("Skipping: no password set and no message sent", { reason, userName });
    return { outcome: "skipped", reason, userName };
  }

  return async function handler(event: CreateLoginProfileEvent): Promise<Result> {
    const detail = event.detail ?? {};

    // The EventBridge rule already filters on both of these. Checked again so that a
    // misconfigured rule or a hand-crafted invocation cannot get past them.
    if (detail.eventSource !== "iam.amazonaws.com" || detail.eventName !== "CreateLoginProfile") {
      return skip("not-create-login-profile");
    }
    if (detail.errorCode) {
      return skip("api-call-failed", detail.requestParameters?.userName);
    }

    const userName = detail.requestParameters?.userName;
    if (!userName) {
      return skip("no-user-name");
    }

    let tags: Map<string, string>;
    try {
      tags = await listAllUserTags(iam, userName);
    } catch (error) {
      // Deleted again before this ran: nothing to do, and not worth a retry.
      if (errorName(error) === "NoSuchEntityException") {
        return skip("user-not-found", userName);
      }
      logger.error("ListUserTags failed", { userName, error: errorName(error) });
      throw error;
    }

    if (tags.get(MANAGED_BY_TAG) !== MANAGED_BY_VALUE) {
      return skip("not-managed-by-devops-security", userName);
    }

    const slackId = tags.get(SLACK_ID_TAG);
    if (!slackId) {
      return skip("no-slack-id", userName);
    }
    if (!SLACK_ID_PATTERN.test(slackId)) {
      return skip("invalid-slack-id", userName);
    }

    const password = generatePassword();

    try {
      await iam.send(
        new UpdateLoginProfileCommand({
          UserName: userName,
          Password: password,
          PasswordResetRequired: true,
        }),
      );
    } catch (error) {
      // Nothing is sent: the user's password is unchanged, so there is nothing to deliver.
      logger.error("UpdateLoginProfile failed; no message sent", { userName, error: errorName(error) });
      throw new Error(`UpdateLoginProfile failed for ${userName}: ${errorName(error)}`);
    }

    try {
      await sender.send({ slackId, userName, text: buildWelcomeMessage(userName, password) });
    } catch (error) {
      // The password has been changed but not delivered. Throwing lets Lambda's async
      // retry run the whole handler again, which sets a fresh password and resends.
      logger.error("Password was reset but the message was not sent", {
        userName,
        slackId,
        error: errorName(error),
      });
      throw new Error(`Sending the message for ${userName} failed: ${errorName(error)}`);
    }

    // "handed to the sender" rather than "sent": with the stub sender nothing leaves.
    logger.info("Temporary password set and message handed to the sender", { userName, slackId });
    return { outcome: "sent", userName };
  };
}
