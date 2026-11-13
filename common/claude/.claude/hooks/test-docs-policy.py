#!/usr/bin/env python3
"""Tests for docs-policy.py: feeds it hook payloads in throwaway repos. Run: python3 test-docs-policy.py"""
import json
import os
import subprocess
import sys
import tempfile
import unittest

HOOK = os.path.join(os.path.dirname(os.path.abspath(__file__)), "docs-policy.py")
CONFIG = {"index": "SPEC.md", "topics": "docs/spec", "history": "docs/spec/history.md",
          "indexCap": 1000, "topicCap": 2000, "historySoftCap": 4000}
INDEX = "# Spec\n\n| File | Read it when |\n|---|---|\n| [a.md](./docs/spec/a.md) | a |\n"


class DocsPolicy(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = os.path.realpath(self.tmp.name)
        os.makedirs(os.path.join(self.root, ".git"))
        os.makedirs(os.path.join(self.root, "docs", "spec"))
        self.put(".claude/docs-policy.json", json.dumps(CONFIG))
        self.put("SPEC.md", INDEX)
        self.put("docs/spec/a.md", "# A\n\n" + "x" * 1500 + "\n")
        self.put("docs/spec/history.md", "# History\n")

    def tearDown(self):
        self.tmp.cleanup()

    def put(self, rel, text):
        path = os.path.join(self.root, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)

    def run_hook(self, tool, rel, root=None, **tool_input):
        payload = {"tool_name": tool, "cwd": root or self.root,
                   "tool_input": {"file_path": os.path.join(root or self.root, rel), **tool_input}}
        out = subprocess.run([sys.executable, HOOK], input=json.dumps(payload),
                             capture_output=True, text=True, check=True).stdout
        return json.loads(out)["hookSpecificOutput"] if out else None

    def assertDenied(self, result, *phrases):
        self.assertIsNotNone(result)
        self.assertEqual(result.get("permissionDecision"), "deny")
        for phrase in phrases:
            self.assertIn(phrase, result["permissionDecisionReason"])

    def assertAdvised(self, result, *phrases):
        self.assertIsNotNone(result)
        self.assertNotIn("permissionDecision", result)
        for phrase in phrases:
            self.assertIn(phrase, result["additionalContext"])

    # Topic cap
    def test_write_topic_under_cap_is_silent(self):
        self.assertIsNone(self.run_hook("Write", "docs/spec/a.md", content="y" * 1999))

    def test_write_topic_over_cap_is_denied_with_fix(self):
        result = self.run_hook("Write", "docs/spec/a.md", content="y" * 2001)
        self.assertDenied(result, "docs/spec/a.md", "split", "docs/spec/", "SPEC.md", "docs/spec/history.md")

    def test_edit_topic_over_cap_is_denied(self):
        self.assertDenied(self.run_hook("Edit", "docs/spec/a.md", old_string="# A", new_string="# A\n" + "z" * 600))

    def test_edit_topic_under_cap_is_silent(self):
        self.assertIsNone(self.run_hook("Edit", "docs/spec/a.md", old_string="# A", new_string="# A\n" + "z" * 400))

    def test_replace_all_counts_every_replacement(self):
        self.put("docs/spec/a.md", "ab\n" * 600 + "end\n")
        self.assertIsNone(self.run_hook("Edit", "docs/spec/a.md", old_string="end", new_string="end!"))
        self.assertIsNone(self.run_hook("Edit", "docs/spec/a.md", old_string="ab", new_string="abc"))
        self.assertDenied(self.run_hook("Edit", "docs/spec/a.md", old_string="ab", new_string="abc", replace_all=True),
                          "2,404 B")

    def test_multiedit_applies_edits_in_order(self):
        edits = [{"old_string": "# A", "new_string": "# A\nQQQ"},
                 {"old_string": "QQQ", "new_string": "q" * 600}]
        self.assertDenied(self.run_hook("MultiEdit", "docs/spec/a.md", edits=edits))
        self.assertIsNone(self.run_hook("MultiEdit", "docs/spec/a.md", edits=edits[:1]))

    def test_shrinking_an_oversized_topic_passes(self):
        self.put("docs/spec/a.md", "# A\n" + "x" * 3000 + "\nOld part.\n")
        self.assertIsNone(self.run_hook("Edit", "docs/spec/a.md", old_string="\nOld part.", new_string=""))
        self.assertDenied(self.run_hook("Edit", "docs/spec/a.md", old_string="# A", new_string="# A2"))

    def test_multibyte_text_is_measured_in_utf8_bytes(self):
        greek = "α" * 1000
        self.assertIsNone(self.run_hook("Write", "docs/spec/a.md", content=greek))
        self.assertDenied(self.run_hook("Write", "docs/spec/a.md", content=greek + "a"), "2,001 B")

    def test_multibyte_edit_crosses_cap_by_one_byte(self):
        self.put("docs/spec/a.md", "#" + "α" * 999)
        self.assertIsNone(self.run_hook("Edit", "docs/spec/a.md", old_string="#", new_string="β"))
        self.assertDenied(self.run_hook("Edit", "docs/spec/a.md", old_string="#", new_string="#β"), "2,001 B")

    # Index cap
    def test_index_under_cap_is_silent(self):
        self.assertIsNone(self.run_hook("Edit", "SPEC.md", old_string="# Spec", new_string="# Spec\n" + "i" * 100))

    def test_index_over_cap_is_denied(self):
        result = self.run_hook("Write", "SPEC.md", content=INDEX + "i" * 1000)
        self.assertDenied(result, "SPEC.md", "routes", "docs/spec/")

    # History
    def test_history_is_exempt_from_caps(self):
        self.assertIsNone(self.run_hook("Write", "docs/spec/history.md", content="Until then h.\n" + "h" * 3000))

    def test_history_past_soft_cap_is_advised(self):
        self.assertAdvised(self.run_hook("Write", "docs/spec/history.md", content="h" * 5000), "splitting it")

    def test_past_state_phrase_is_advised(self):
        result = self.run_hook("Edit", "docs/spec/a.md", old_string="# A", new_string="# A\nUntil 2026-10-21 it did b.")
        self.assertAdvised(result, "'Until 2026-'", "docs/spec/history.md")

    def test_past_state_phrase_already_present_is_silent(self):
        self.put("docs/spec/a.md", "# A\nUntil then it was b.\n")
        self.assertIsNone(self.run_hook("Write", "docs/spec/a.md", content="# A\nUntil then it was b.\nNew rule.\n"))

    def test_editing_a_paragraph_with_an_old_phrase_is_silent(self):
        self.put("docs/spec/a.md", "# A\nUntil then it was b. It fails every run.\n")
        self.assertIsNone(self.run_hook("Edit", "docs/spec/a.md", old_string="fails every run", new_string="fails once"))
        result = self.run_hook("Edit", "docs/spec/a.md", old_string="fails every run", new_string="fails once. Until then c")
        self.assertAdvised(result, "'Until then'")

    def test_ordinary_past_tense_is_silent(self):
        text = ("# A\nOMDb was removed on evidence. A film no longer ships without a poster.\n"
                "Update a file when a decision in it is superseded.\n")
        self.assertIsNone(self.run_hook("Write", "docs/spec/a.md", content=text))

    # New topic file
    def test_new_unlisted_topic_file_is_allowed_with_note(self):
        result = self.run_hook("Write", "docs/spec/b.md", content="# B\n")
        self.assertAdvised(result, "`docs/spec/b.md`", "SPEC.md")

    def test_new_listed_topic_file_is_silent(self):
        os.remove(os.path.join(self.root, "docs/spec/a.md"))
        self.assertIsNone(self.run_hook("Write", "docs/spec/a.md", content="# A\n"))

    def test_new_topic_file_over_cap_is_denied(self):
        self.assertDenied(self.run_hook("Write", "docs/spec/b.md", content="b" * 2001))

    # Out of scope
    def test_non_markdown_file_is_silent(self):
        self.assertIsNone(self.run_hook("Write", "docs/spec/big.txt", content="x" * 99999))

    def test_markdown_outside_the_scheme_is_silent(self):
        self.assertIsNone(self.run_hook("Write", "README.md", content="Until then.\n" + "x" * 99999))
        self.assertIsNone(self.run_hook("Write", "docs/spec/sub/c.md", content="x" * 99999))

    def test_repo_without_config_is_silent(self):
        with tempfile.TemporaryDirectory() as other:
            other = os.path.realpath(other)
            os.makedirs(os.path.join(other, ".git"))
            self.assertIsNone(self.run_hook("Write", "docs/spec/a.md", root=other, content="x" * 99999))

    def test_failing_edit_is_left_to_the_tool(self):
        self.assertIsNone(self.run_hook("Edit", "docs/spec/a.md", old_string="absent", new_string="x" * 9999))

    def test_relative_path_resolves_against_cwd(self):
        payload = {"tool_name": "Write", "cwd": self.root,
                   "tool_input": {"file_path": "docs/spec/a.md", "content": "y" * 2001}}
        out = subprocess.run([sys.executable, HOOK], input=json.dumps(payload),
                             capture_output=True, text=True, check=True).stdout
        self.assertEqual(json.loads(out)["hookSpecificOutput"]["permissionDecision"], "deny")


if __name__ == "__main__":
    unittest.main(verbosity=2)
