# Global instructions

## This file
- Lives in `~/dotfiles/claude/.claude/` (symlinked to `~/.claude/`). `~/dotfiles` is a public GitHub repo: keep work material (Pricefox, client data, internal hosts, credentials) out of it.
- When a correction applies beyond the current project, record it here rather than in a project memory.

## Scope
- Size the work to the real risk: the smallest change that fully solves the goal, built from helpers the repo already has. When a spec or plan demands machinery the code doesn't need, say so and recommend the simpler scope before building it.
- Measure before building: count the shapes that actually occur in the live data or fixtures, and build for those. Unseen shapes fall into an existing error path.
- Go deeper, not bigger: find the root cause and check it against independent evidence. When a task points at a larger goal (keep the app crash-free, not fix this one crash), name it in your report as an offer.

## Done
- Work is done when an outside check passes: a test, typecheck, build exit code, or a screenshot against the target. Report the command you ran and its result.

## Git
- Keep each commit to one logical change where possible, and split unrelated changes into separate commits. Message format and the no-co-author rule are enforced by `~/.claude/hooks/commit-policy.py`.
