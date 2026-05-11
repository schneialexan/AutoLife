---
name: smart-commit
description: Organize git changes into safe, reviewable commits and write clear commit messages. Use when the user asks to commit, create a git commit, split changes into commits, organize staged changes, write commit messages, or prepare work for pushing.
---

# Smart Commit

Use this skill to turn a messy working tree into one or more intentional commits with accurate messages.

## Safety Rules

- Never commit secrets, credentials, `.env` files, private keys, tokens, database dumps, or generated local state.
- Never run destructive git commands such as `git reset --hard`, `git checkout --`, force push, or rebase unless the user explicitly asks.
- Never push unless the user explicitly asks.
- Preserve user changes. If unrelated changes exist, leave them alone or ask before including them.
- Do not use `--no-verify`, `--no-gpg-sign`, or hook-skipping flags unless the user explicitly asks.
- Never add commit trailers or message lines that attribute co-authorship to the assistant (for example `--trailer "Co-authored-by: Cursor <cursoragent@cursor.com>"` or `Co-authored-by: Cursor <cursoragent@cursor.com>`).
- If a hook rejects a commit, fix the issue and create a new commit. Do not amend a failed commit.

## Workflow

1. Inspect state:
   - Run `git status --short --untracked-files=all`.
   - Run `git diff` and `git diff --staged`.
   - Run `git log --oneline -5`; if there are no commits, note that this is the initial commit.

2. Classify changes:
   - Group by purpose, not by file type.
   - Separate unrelated work into separate commits.
   - Keep generated files with the source change that requires them, unless the repo normally excludes them.
   - Exclude local/editor/cache/build artifacts unless the repo intentionally tracks them.

3. Decide commit shape:
   - Use one commit when all changes serve one purpose.
   - Use multiple commits when there are independent features, fixes, docs, refactors, or generated updates.
   - Ask the user before splitting if the grouping is ambiguous or if interactive staging would be needed.

4. Stage intentionally:
   - Prefer `git add <paths>` for known groups.
   - Use `git add -A` only when every change is intended for the same commit.
   - Re-run `git status --short` and `git diff --cached --stat` after staging.
   - Run `git diff --cached --check`; treat secret findings as blockers and whitespace findings as fix-or-report items.

5. Write the message:
   - Use the repository's existing style when visible.
   - Prefer concise imperative subject lines, 50-72 characters when practical.
   - Use a body when it explains motivation, risk, or validation better than the subject.
   - Message should explain the reason and outcome, not repeat every filename.

6. Commit:
   - Pass the message via heredoc or equivalent multi-line-safe shell syntax and dont add `Co-authored-by: Cursor <cursoragent@cursor.com>`
   - After commit, run `git status --short --branch`.
   - Report commit hash, subject, included change groups, and any files left uncommitted.

## Commit Message Defaults

```text
feat(auth): add password reset flow
fix(calendar): preserve timezone when saving events
docs: document local Supabase setup
test(core): cover event delivery serialization
```

## Grouping Heuristics

- `feat`: new user-facing capability or new module.
- `fix`: bug fix or broken behavior correction.
- `refactor`: internal restructure without behavior change.
- `test`: test-only changes or coverage additions.
- `docs`: documentation-only changes.
- `chore`: tooling, configuration, dependency, or repository maintenance.

When a change includes code and tests for the same behavior, keep them in the same commit. When a dependency update only supports a feature in the same patch, keep it with that feature.

## Output Format

After committing, respond with:

- Commit: `<short-sha>` `<subject>`
- Included: short summary of the committed change groups
- Validation: checks run and outcomes
- Remaining: uncommitted changes, skipped files, or follow-up needed
