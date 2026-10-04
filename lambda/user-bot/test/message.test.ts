import { describe, expect, it } from "vitest";

import { buildWelcomeMessage, MFA_SETUP_URL, SIGN_IN_URL } from "../src/message";
import { TEST_PASSWORD } from "./helpers";

describe("buildWelcomeMessage", () => {
  const text = buildWelcomeMessage("new.member", TEST_PASSWORD);

  it("includes the incubator sign-in page, the user name and the password", () => {
    expect(SIGN_IN_URL).toBe("https://hfla-incubator.signin.aws.amazon.com/console");
    expect(text).toContain(`*Sign-in page:* ${SIGN_IN_URL}`);
    expect(text).toContain("*IAM user name:* `new.member`");
    expect(text).toContain(`*Temporary password:* \`${TEST_PASSWORD}\``);
  });

  it("links straight to the signed-in user's Assign MFA device wizard", () => {
    expect(MFA_SETUP_URL).toBe("https://console.aws.amazon.com/iam/home#/security_credentials/mfa");
    expect(text).toContain(`*Set up MFA (once signed in):* ${MFA_SETUP_URL}`);
  });

  it("gives the MFA link after the sign-in details, since it only works once signed in", () => {
    expect(text.indexOf(MFA_SETUP_URL)).toBeGreaterThan(text.indexOf(TEST_PASSWORD));
  });
});
