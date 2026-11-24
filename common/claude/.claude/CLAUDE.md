# Global instructions

## This file
- Lives in `~/dotfiles/common/claude/.claude/` (symlinked to `~/.claude/`). `~/dotfiles` is a public GitHub repo: keep work material (Pricefox, client data, internal hosts, credentials) out of it.
- When a correction applies beyond the current project, record it here rather than in a project memory.

## Scope
- Size the work to the real risk: the smallest change that fully solves the goal, built from helpers the repo already has. When a spec or plan demands machinery the code doesn't need, say so and recommend the simpler scope before building it.
- Measure before building: count the shapes that actually occur in the live data or fixtures, and build for those. Unseen shapes fall into an existing error path.
- Go deeper, not bigger: find the root cause and check it against independent evidence. When a task points at a larger goal (keep the app crash-free, not fix this one crash), name it in your report as an offer.

## Done
- Work is done when an outside check passes: a test, typecheck, build exit code, or a screenshot against the target. Report the command you ran and its result.

## Docs
Rules for docs that people read (READMEs, `docs/`), modelled on the Google and Django writing guides:
- Headings in sentence case.
- Write to the reader as "you", in the active voice, with short plain sentences.
- Use numbered steps for anything done in order. Give each command a one-line intro ending in a colon, then its own code block.
- Put the condition before the instruction ("On a Mac, run…").
- Use code formatting for paths, commands, and keys.
- No filler such as "simply", "just", "please note", or "blazing-fast".
- Spell terms out: "go to definition", not "goto def". Write "and" or "or", not "/". Use the serial comma.
- In tables, every column and note must earn its place: no column that is always the same value or mostly empty, and notes only for limits and caveats. Explanations of how something works go in the prose docs.

## Git
- Keep each commit to one logical change where possible, and split unrelated changes into separate commits. Message format and the no-co-author rule are enforced by `~/.claude/hooks/commit-policy.py`.
- Push only commits the user has asked to push. Approving a plan or saying "go for it" doesn't cover pushing new commits, so commit locally and ask.
- Stash work on the branch it belongs to, not the current one. If a related stash already exists, combine them into one entry (apply both on that branch, re-stash, verify, then drop the old ones).
