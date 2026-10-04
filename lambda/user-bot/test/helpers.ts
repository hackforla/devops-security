import type { CreateLoginProfileEvent, CloudTrailDetail } from "../src/handler";
import type { LogFields, Logger } from "../src/logger";

export interface CapturedLog {
  level: "info" | "warn" | "error";
  message: string;
  fields?: LogFields;
}

// A logger that records every call, so tests can assert on what was logged and,
// more importantly, on what was not.
export function captureLogger(): Logger & { lines: CapturedLog[]; text(): string } {
  const lines: CapturedLog[] = [];
  return {
    lines,
    info: (message, fields) => void lines.push({ level: "info", message, fields }),
    warn: (message, fields) => void lines.push({ level: "warn", message, fields }),
    error: (message, fields) => void lines.push({ level: "error", message, fields }),
    text: () => JSON.stringify(lines),
  };
}

// Shaped like what EventBridge delivers for a CloudTrail-recorded CreateLoginProfile.
export function createLoginProfileEvent(detail: Partial<CloudTrailDetail> = {}): CreateLoginProfileEvent {
  return {
    version: "0",
    id: "11111111-2222-3333-4444-555555555555",
    "detail-type": "AWS API Call via CloudTrail",
    source: "aws.iam",
    account: "035866691871",
    time: "2026-10-04T00:00:00Z",
    region: "us-east-1",
    resources: [],
    detail: {
      eventSource: "iam.amazonaws.com",
      eventName: "CreateLoginProfile",
      requestParameters: { userName: "new.member" },
      ...detail,
    },
  };
}

export const TEST_PASSWORD = "Pw7!Pw7!Pw7!Pw7!Pw7!";
export const TEST_SLACK_ID = "U0123456789";
