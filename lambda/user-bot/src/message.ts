// The incubator account's sign-in page, via its alias hfla-incubator.
export const SIGN_IN_URL = "https://hfla-incubator.signin.aws.amazon.com/console";

// Opens the "Assign MFA device" wizard for whoever is signed in, so one link works for
// every user. It only works once signed in: the route is in the #fragment, which the
// browser never sends to AWS, so a signed-out visit loses it on the way through sign-in
// and lands on the console home page. Hence the "once signed in" in the message.
// Tested by hand 2026-10-04; AWS does not document console routes and may change them.
export const MFA_SETUP_URL = "https://console.aws.amazon.com/iam/home#/security_credentials/mfa";

// Slack mrkdwn. The user name and password are in inline code so that characters
// such as * and _ are shown literally rather than read as formatting.
export function buildWelcomeMessage(userName: string, password: string): string {
  return [
    "Your Hack for LA AWS account is ready.",
    "",
    `*Sign-in page:* ${SIGN_IN_URL}`,
    `*IAM user name:* \`${userName}\``,
    `*Temporary password:* \`${password}\``,
    "",
    "The first time you sign in you will be asked to replace this password with one of your own. " +
      "Then, in the same browser, set up multi-factor authentication (MFA): most of your access " +
      "only works once MFA is set up.",
    "",
    `*Set up MFA (once signed in):* ${MFA_SETUP_URL}`,
    "",
    "If the password does not work, ask the DevOps team on Slack for a new one.",
  ].join("\n");
}
