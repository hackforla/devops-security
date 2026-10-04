import { GetParameterCommand, type SSMClient } from "@aws-sdk/client-ssm";

// Slack bot tokens start with this. Terraform creates the parameter holding a
// placeholder, so this is also how a token that was never set is caught.
export const SLACK_BOT_TOKEN_PREFIX = "xoxb-";

// Messages name the parameter and the failure, never the value.
export class SlackTokenError extends Error {
  override name = "SlackTokenError";
}

function errorName(error: unknown): string {
  return error instanceof Error ? error.name : "UnknownError";
}

// Returns a function that reads the token from SSM Parameter Store once per execution
// environment and reuses it. A failed read is not cached, so the next invocation tries
// again rather than failing forever on a rejected promise; that matters right after the
// token is first set or rotated.
export function createSlackTokenLoader(
  ssm: SSMClient,
  parameterName: string | undefined,
): () => Promise<string> {
  let cached: Promise<string> | undefined;

  async function load(): Promise<string> {
    if (!parameterName) {
      throw new SlackTokenError("SLACK_TOKEN_PARAMETER is not set");
    }

    let value: string | undefined;
    try {
      const output = await ssm.send(new GetParameterCommand({ Name: parameterName, WithDecryption: true }));
      value = output.Parameter?.Value;
    } catch (error) {
      throw new SlackTokenError(`could not read ${parameterName}: ${errorName(error)}`);
    }

    if (!value?.startsWith(SLACK_BOT_TOKEN_PREFIX)) {
      throw new SlackTokenError(
        `${parameterName} does not hold a Slack bot token; it may still be the placeholder Terraform created`,
      );
    }
    return value;
  }

  return () => {
    cached ??= load().catch((error: unknown) => {
      cached = undefined;
      throw error;
    });
    return cached;
  };
}
