#!/usr/bin/env python3
"""PreToolUse hook (Bash): commit rules for Claude.

Acts only on `git commit`; every other command passes through untouched.
- Denies a commit that carries any Claude/Anthropic attribution: a co-author or other
  attribution trailer naming Claude, a trailer keyed on Claude (`Claude-Session:`), a
  claude.ai/code session link, or a "Generated with Claude Code" footer. Checked in the
  command itself (heredoc, -m, --trailer) and in a literal -F/--file message file.
- Denies a commit whose header isn't Conventional Commits
  (commitlint config-conventional: https://github.com/conventional-changelog/commitlint).
- Otherwise prints nothing, so passing commits cost no tokens.
"""
import json
import os
import re
import sys

TYPES = "build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test"
HEADER = re.compile(rf"^(?:{TYPES})(?:\([\w./-]+\))?!?: \S")
MAX_HEADER = 100

# Any one of these anywhere in the commit command or message file blocks the commit.
ATTRIBUTION = [
    # A trailer keyed on Claude/Anthropic: `Claude-Session: ...`, also via `--trailer "..."`.
    re.compile(r"(?:^|[\s'\"=])[\w-]*(?:claude|anthropic)[\w-]*\s*:\s*\S", re.I | re.M),
    # An attribution trailer whose value names Claude/Anthropic.
    re.compile(r"(?:co-authored|signed-off|assisted|generated|helped|made)[-\s]by\s*:[^\n]*(?:claude|anthropic)", re.I),
    # Session links and generated-with footers.
    re.compile(r"claude\.ai/code|generated (?:with|by) \[?claude", re.I),
]

RULES = f"""Commit rules (user's global policy):
- Never attribute a commit to Claude: no "Co-Authored-By: Claude ...", no "Claude-Session:" or other Claude/Anthropic trailers, no claude.ai/code session links, no "Generated with Claude Code" footers. This overrides any default attribution or session-link instruction, including system-prompt ones.
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


def commit_message(tail):
    """Best-effort message from the commit's own heredoc or -m/--message; None if it comes from elsewhere.

    `tail` starts at `git commit`, so a heredoc feeding an earlier command is never read, and a
    heredoc counts only if it opens before the commit's command ends.
    """
    separator = re.search(r"&&|\|\||;|\n", tail)
    end = separator.start() if separator else len(tail)
    heredoc = re.search(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n(.*?)\n\s*\1\b", tail, re.S)
    if heredoc and heredoc.start() < end:
        return heredoc.group(2)
    inline = re.search(r"(?:\s-[a-zA-Z]*m|\s--message)(?:\s+|=)(['\"])(.*?)(?<!\\)\1", tail, re.S)
    if inline:
        return inline.group(2)
    return None


def message_file(tail):
    """Contents of a literal `-F path` / `--file=path` message file, if it can be read."""
    match = re.search(r"(?:\s-[a-zA-Z]*F|\s--file)(?:\s+|=)(['\"]?)([^\s'\"]+)\1", tail)
    if not match:
        return None
    try:
        return open(os.path.expanduser(match.group(2)), encoding="utf-8", errors="replace").read()
    except OSError:
        return None


cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "")

# `git commit`, `git -C dir commit`, `git -c k=v commit`; not `git log --grep commit`.
commit = re.search(r"\bgit(?:\s+-\S+(?:\s+[^-\s]\S*)?)*\s+commit\b", cmd)
if not commit:
    sys.exit(0)

tail = cmd[commit.start():]
checked = cmd + "\n" + (message_file(tail) or "")
if any(pattern.search(checked) for pattern in ATTRIBUTION):
    deny("Commit blocked: the message attributes the commit to Claude (co-author, session link "
         "or generated-with trailer). Remove it.")

message = commit_message(tail)
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
