#!/usr/bin/env python3
"""PreToolUse hook (Write|Edit|MultiEdit): keeps a repo's split documentation in shape.

Acts only in a repo with `.claude/docs-policy.json`, and only on Markdown files it names:
  {"index": "SPEC.md", "topics": "docs/spec", "history": "docs/spec/history.md",
   "indexCap": 10240, "topicCap": 16384, "historySoftCap": 65536}   (caps optional, UTF-8 bytes)
- Denies a write that leaves the index or a topic file over its cap and larger than before.
- Advises (never denies) on a new topic file the index doesn't link, past-state phrasing the write
  adds outside the history file, and a history file past its soft cap.
- Otherwise prints nothing, so passing writes cost no tokens.
"""
import json
import os
import re
import sys
from collections import Counter

CONFIG = os.path.join(".claude", "docs-policy.json")
DEFAULT_CAPS = {"indexCap": 10 * 1024, "topicCap": 16 * 1024, "historySoftCap": 64 * 1024}
PAST_STATE = re.compile(
    r"\bUntil then\b|\bUntil 20\d\d-|\*Before:\*|\bReplayed on\b"
    r"|\bwas (?:removed|replaced|dropped) on 20\d\d-|\b[Ss]uperseded (?:by|on)\b"
)


def respond(**fields):
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", **fields}}))
    sys.exit(0)


def find_root(path):
    directory = os.path.dirname(path)
    while True:
        if os.path.isfile(os.path.join(directory, CONFIG)):
            return directory
        parent = os.path.dirname(directory)
        if parent == directory or os.path.exists(os.path.join(directory, ".git")):
            return None
        directory = parent


def read(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        return None


def replace(text, old, new, replace_all):
    if text is None:
        return new if old == "" else None
    count = text.count(old) if old else 0
    if count == 0 or (count > 1 and not replace_all):
        return None
    return text.replace(old, new) if replace_all else text.replace(old, new, 1)


def resulting(tool, tool_input, before):
    if tool == "Write":
        return tool_input.get("content", "")
    edits = tool_input.get("edits", []) if tool == "MultiEdit" else [tool_input]
    text = before
    for edit in edits:
        text = replace(text, edit.get("old_string", ""), edit.get("new_string", ""), edit.get("replace_all", False))
        if text is None:
            return None
    return text


def kib(size):
    return f"{size / 1024:.1f} KiB ({size:,} B)"


payload = json.load(sys.stdin)
tool = payload.get("tool_name", "")
tool_input = payload.get("tool_input", {})
file_path = tool_input.get("file_path", "")
if tool not in ("Write", "Edit", "MultiEdit") or not file_path.endswith(".md"):
    sys.exit(0)

path = os.path.realpath(os.path.join(payload.get("cwd", ""), file_path))
root = find_root(path)
if root is None:
    sys.exit(0)
try:
    with open(os.path.join(root, CONFIG), encoding="utf-8") as f:
        config = {**DEFAULT_CAPS, **json.load(f)}
    index = os.path.realpath(os.path.join(root, config["index"]))
    topics = os.path.realpath(os.path.join(root, config["topics"]))
    history = os.path.realpath(os.path.join(root, config["history"]))
except (OSError, ValueError, KeyError, TypeError):
    sys.exit(0)

is_topic = os.path.dirname(path) == topics and path not in (index, history)
if path not in (index, history) and not is_topic:
    sys.exit(0)

before = read(path)
after = resulting(tool, tool_input, before)
if after is None:
    sys.exit(0)
size = len(after.encode("utf-8"))
grew = before is None or size > len(before.encode("utf-8"))
rel = lambda p: os.path.relpath(p, root)

if path == index and size > config["indexCap"] and grew:
    respond(
        permissionDecision="deny",
        permissionDecisionReason=(
            f"Write blocked: {rel(index)} would be {kib(size)}, over its cap of {kib(config['indexCap'])}. "
            f"The index only routes: purpose, the rules every task needs, and a table pointing each topic "
            f"to one file in {rel(topics)}/. Put the new detail in the topic file that owns it (or a new one, "
            f"plus a table row), and move any past-state text to {rel(history)}. "
            f"Edits that shrink the index always pass."
        ),
    )
if is_topic and size > config["topicCap"] and grew:
    respond(
        permissionDecision="deny",
        permissionDecisionReason=(
            f"Write blocked: {rel(path)} would be {kib(size)}, over the topic cap of {kib(config['topicCap'])}. "
            f"Topic files never just grow. Instead: (1) split {rel(path)} by topic into new files in "
            f"{rel(topics)}/, each under the cap; (2) add a row for each new file to the table in {rel(index)} "
            f"(file link plus when to read it); (3) move superseded designs, 'until then' states, replays, "
            f"backfills and old reviews to {rel(history)}. Edits that shrink the file always pass."
        ),
    )

notes = []
if is_topic and before is None:
    index_text = read(index) or ""
    link = os.path.relpath(path, os.path.dirname(index)).replace(os.sep, "/")
    if link not in index_text:
        notes.append(f"{rel(path)} is a new topic file: add a row linking `{link}` to the table in {rel(index)}.")
if path != history:
    phrases = sorted(Counter(PAST_STATE.findall(after)) - Counter(PAST_STATE.findall(before or "")))
    if phrases:
        notes.append(
            f"The text added to {rel(path)} reads as past state ({', '.join(repr(p) for p in phrases)}). "
            f"If it is not a current rule, move it to {rel(history)} and keep only the rule and its short reason here."
        )
elif size > config["historySoftCap"]:
    notes.append(f"{rel(history)} is {kib(size)}, past {kib(config['historySoftCap'])}: consider splitting it by period or topic.")

if notes:
    respond(additionalContext="Docs policy: " + " ".join(notes))
