// The incubator account's sign-in page, via its alias hfla-incubator.
export const SIGN_IN_URL = "https://hfla-incubator.signin.aws.amazon.com/console";

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
      "Then set up multi-factor authentication (MFA) from *Security credentials* in the account " +
      "menu: most of your access only works once MFA is set up.",
    "",
    "If the password does not work, ask the DevOps team on Slack for a new one.",
  ].join("\n");
}
