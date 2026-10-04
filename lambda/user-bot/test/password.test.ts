import { describe, expect, it } from "vitest";

import { DIGITS, generatePassword, LOWERCASE, PASSWORD_LENGTH, SYMBOLS, UPPERCASE } from "../src/password";

const has = (password: string, chars: string) => [...password].some((c) => chars.includes(c));

describe("generatePassword", () => {
  // 500 runs, because a missing character class would only show up some of the time.
  const passwords = Array.from({ length: 500 }, () => generatePassword());

  it("is 20 characters by default", () => {
    expect(PASSWORD_LENGTH).toBe(20);
    for (const p of passwords) expect(p).toHaveLength(20);
  });

  it("always meets AWS's default password policy, and contains all four character classes", () => {
    for (const p of passwords) {
      expect(p.length).toBeGreaterThanOrEqual(8);
      expect(has(p, UPPERCASE)).toBe(true);
      expect(has(p, LOWERCASE)).toBe(true);
      expect(has(p, DIGITS)).toBe(true);
      expect(has(p, SYMBOLS)).toBe(true);
    }
  });

  it("uses only allowed characters, so nothing Slack would need to escape", () => {
    const allowed = UPPERCASE + LOWERCASE + DIGITS + SYMBOLS;
    for (const p of passwords) {
      for (const c of p) expect(allowed).toContain(c);
      expect(p).not.toMatch(/[&<>`]/);
    }
  });

  it("does not repeat", () => {
    expect(new Set(passwords).size).toBe(passwords.length);
  });

  it("honours a custom length and rejects one too short to hold every class", () => {
    expect(generatePassword(32)).toHaveLength(32);
    expect(generatePassword(4)).toHaveLength(4);
    expect(() => generatePassword(3)).toThrow(RangeError);
  });
});
