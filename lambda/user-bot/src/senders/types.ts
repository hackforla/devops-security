export interface DirectMessage {
  // Slack member ID, e.g. U0123456789. Not a handle.
  slackId: string;
  // The IAM user the message is about. For logging; it is not sent separately.
  userName: string;
  // Contains the temporary password, so it must never be logged.
  text: string;
}

export interface MessageSender {
  send(message: DirectMessage): Promise<void>;
}
