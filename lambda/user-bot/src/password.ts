import { randomInt } from "node:crypto";

// The account has no custom IAM password policy, so AWS's default applies: at least
// 8 characters and at least three of uppercase, lowercase, digits and symbols. This
// always includes all four, so it still passes if a stricter policy is added later.
export const PASSWORD_LENGTH = 20;

// Characters that are easy to misread (I, l, O, 0, 1) are left out, since the
// password may be typed by hand. So are &, < and >: Slack requires those three to be
// escaped in message text, and an escaped password would arrive wrong.
export const UPPERCASE = "ABCDEFGHJKLMNPQRSTUVWXYZ";
export const LOWERCASE = "abcdefghijkmnopqrstuvwxyz";
export const DIGITS = "23456789";
export const SYMBOLS = "!@#$%^*-_=+";

const CLASSES = [UPPERCASE, LOWERCASE, DIGITS, SYMBOLS];
const ALL = CLASSES.join("");

function pick(chars: string): string {
  return chars.charAt(randomInt(chars.length));
}

export function generatePassword(length: number = PASSWORD_LENGTH): string {
  if (length < CLASSES.length) {
    throw new RangeError(`password length must be at least ${CLASSES.length}`);
  }

  const chars = CLASSES.map(pick);
  while (chars.length < length) {
    chars.push(pick(ALL));
  }

  // Fisher-Yates, so the guaranteed characters are not always the first four.
  for (let i = chars.length - 1; i > 0; i--) {
    const j = randomInt(i + 1);
    [chars[i], chars[j]] = [chars[j]!, chars[i]!];
  }

  return chars.join("");
}
