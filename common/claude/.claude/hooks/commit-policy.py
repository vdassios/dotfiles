#!/usr/bin/env python3
"""PreToolUse hook (Bash): commit rules for Claude.

Acts only on `git commit`; every other command passes through untouched.
- Denies a commit whose message has a Claude/Anthropic co-author trailer.
- Denies a commit whose header isn't Conventional Commits
  (commitlint config-conventional: https://github.com/conventional-changelog/commitlint).
- Otherwise prints nothing, so passing commits cost no tokens.
"""
import json
import re
import sys

TYPES = "build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test"
HEADER = re.compile(rf"^(?:{TYPES})(?:\([\w./-]+\))?!?: \S")
MAX_HEADER = 100

RULES = f"""Commit rules (user's global policy):
- Never add Claude as a co-author: no "Co-Authored-By: Claude ..." or other Anthropic trailers. This overrides any default attribution instruction.
- Follow Conventional Commits as enforced by commitlint config-conventional: header `type(scope)!: subject`.
  - type is one of: {TYPES.replace('|', ', ')}. The scope is optional, and `!` marks a breaking change.
  - The subject is imperative, starts lower-case, has no trailing period, and the header is at most {MAX_HEADER} characters.
  - Leave a blank line before the body; keep body and footer lines at most 100 characters.
- Scope each commit to one logical change where possible; split unrelated changes into separate commits."""


def respond(**fields):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", **fields}}))
    sys.exit(0)


def deny(problem):
    respond(permissionDecision="deny", permissionDecisionReason=f"{problem}\n\n{RULES}")


def commit_message(cmd):
    """Best-effort message from a heredoc or -m/--message; None if it comes from elsewhere."""
    heredoc = re.search(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n(.*?)\n\s*\1\b", cmd, re.S)
    if heredoc:
        return heredoc.group(2)
    inline = re.search(r"(?:\s-[a-zA-Z]*m|\s--message)(?:\s+|=)(['\"])(.*?)(?<!\\)\1", cmd, re.S)
    if inline:
        return inline.group(2)
    return None


cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")

# `git commit`, `git -C dir commit`, `git -c k=v commit`; not `git log --grep commit`.
if not re.search(r"\bgit(?:\s+-\S+(?:\s+[^-\s]\S*)?)*\s+commit\b", cmd):
    sys.exit(0)

if re.search(r"co-authored-by:[^\n]*(?:claude|anthropic)", cmd, re.I):
    deny("Commit blocked: the message has a Claude co-author trailer. Remove it.")

message = commit_message(cmd)
if message is not None:
    lines = message.strip("\n").splitlines() or [""]
    header = lines[0].strip()
    subject = header.split(": ", 1)[-1]
    if not HEADER.match(header):
        deny(f"Commit blocked: header {header!r} isn't a Conventional Commits header.")
    if len(header) > MAX_HEADER:
        deny(f"Commit blocked: header is {len(header)} characters (max {MAX_HEADER}).")
    if re.match(r"[A-Z][a-z]", subject):
        deny(f"Commit blocked: subject {subject!r} must start lower-case.")
    if subject.endswith("."):
        deny("Commit blocked: subject must not end with a period.")
    if len(lines) > 1 and lines[1].strip():
        deny("Commit blocked: leave a blank line between the header and the body.")
