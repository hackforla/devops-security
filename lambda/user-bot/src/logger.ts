// Structured JSON lines, so CloudWatch Logs Insights can filter on fields.
//
// Nothing that logs through this may pass a password or a Slack token in `fields`.
// The tests capture every call and assert the password never appears.

export type LogFields = Record<string, unknown>;

export interface Logger {
  info(message: string, fields?: LogFields): void;
  warn(message: string, fields?: LogFields): void;
  error(message: string, fields?: LogFields): void;
}

function write(level: string, message: string, fields?: LogFields): void {
  console.log(JSON.stringify({ level, message, ...fields }));
}

export const consoleLogger: Logger = {
  info: (message, fields) => write("info", message, fields),
  warn: (message, fields) => write("warn", message, fields),
  error: (message, fields) => write("error", message, fields),
};
