______________________________________________________________________

## name: commit description: Use this skill for every commit. Trigger on any commit or commit-message request. Covers staging, hooks, message format, and attribution.

# Commit

Rules for local feature-branch commits. On squash-merge repos, GitHub builds the permanent
default-branch message from the PR title and body (`pr-writer` owns that, including ticket
references). Feature-branch commits are what reviewers read step by step, not throwaway notes.

## Precedence

This is the generic skill. If the repo has its own `commit` skill (`.claude/skills/` or equivalent)
or documents commit rules in `CLAUDE.md` or repo docs, that layer wins. Check for both before
committing.

## Pre-flight

```bash
git branch --show-current
git status --porcelain
git diff --cached --stat
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

- Anything already in `git diff --cached` that you did not stage belongs to another session. Commit
  it only when the user asks, and never mix it into your commit.
- CRITICAL: Never commit directly to the default branch or a deploy branch unless the user
  explicitly asked. Check `CLAUDE.md` and repo docs for release or deploy branches. Stop if you are
  on one without permission.

## Guardrails and hooks

- CRITICAL: Commit only when the user explicitly asks.
- CRITICAL: Never amend (`git commit --amend`) and never skip hooks (`--no-verify`).
- CRITICAL: Stage changes first, then run the repo's pre-commit runner before `git commit`. Check
  `.pre-commit-config.yaml` (`prek` or `pre-commit`), `.husky/`, or `lint-staged` in `package.json`
  and run that runner directly.
- CRITICAL: Check `git log -1 --oneline` before committing and again after any non-zero exit. Never
  infer success from hook output.
- Formatters (`ruff`, `prettier`, `oxfmt`, `oxlint --fix`, `stylelint --fix`) rewrite files in
  place and leave fixes unstaged after a failed run. Inspect and `git add` again before retrying.
- Whole-project or networked checks (`pyrefly`, `uv-audit`) run regardless of staged files. Slow is
  not hung.
- Failures on stale generated files (migrations, generated indexes) point to an upstream cause. Fix
  the cause instead of bypassing hooks.
- Not all repos install `commit-msg` hooks, so enforce the message format below yourself.

## Format

```text
<type>(<scope>): <Subject>

<body>
```

- Always write a header. Add a body for any non-obvious change.
- Subject: imperative present tense (`Add feature`, not `Added feature`), capitalized after the
  colon, no trailing period, 70 characters or fewer.
- Types: `feat`, `fix`, `ref` (refactor, no behavior change), `perf`, `docs`, `test`, `build`,
  `ci`, `chore`, `style` (formatting only), `meta`, `license`, `revert`. Match the repo's history
  when it prefers a variant such as `ref` over `refactor`.
- Scope: optional, one lowercase word matching areas used in repo history.

## Body

- Explain what changed and why, not how. Contrast with prior behavior when that clarifies the change.
- Write plain prose paragraphs in imperative present tense. Omit markdown headings and bullet
  lists, which belong in the PR body.
- Follow `AGENTS.md` prose rules (`asd-ste100` and `unslop`).
- Cite safety evidence when available (measured query count, production figure, mutation test).
- Never include customer data (org names, user emails, support ticket contents, PII). Describe the
  technical symptom instead.

## Agent attribution

When an agent wrote the change, end the body with a blank line and a `Co-Authored-By` trailer
naming the actual agent:

```text
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
Co-Authored-By: <Agent Name> <agent@example.com>
```

Substitute the real agent name and address on the second line. Trailers survive squash merges and
drive AI reporting, while the PR body omits them (see [`pr-writer`](../pr-writer/SKILL.md)). Never
emit a Claude trailer for a non-Claude agent, and never add a trailer to an unassisted human commit.

## Ticket references

Follow the repo's ticket placement rule. On squash-merge repos, tickets belong in the PR title.

- Omit `Fixes Ticket` footers and `[Ticket]` prefixes on feature commits (one exception: a
  single-commit PR when the repo allows it).
- Never invent a ticket number. If no ticket exists, state that in the body.

## Commit hygiene

- Keep one stable, independently reviewable change per commit, with the repo working after each.
- Land safety-net tests in their own commit ahead of the change, using measured ceilings rather
  than guesses.
- Split mechanical churn (renames, formatting, generated files) from behavior changes.
- Always write the message to a file and run `git commit -F "$msg"`. Never use `-m "..."`, because
  double-quoted shells execute backticks and `$(...)` (for example, backticked `import` invokes
  ImageMagick and hangs), expand `$VAR` and `!`, and mishandle literal `\n` escapes.

```bash
msg=$(mktemp)   # write subject, blank line, body, and trailer to "$msg" first
git commit -F "$msg"
```

The same shell hazard applies to `gh pr create --body` and `gh pr edit --body`. Use `--body-file`
as shown in `pr-writer` Step 5.

## Examples

### A test that lands ahead of the change it protects

```text
test: Budget queries on the list and detail endpoints

The list and detail endpoints both dereference owner.user while serializing,
and neither had a query budget. The default manager passes
select_related("user"), hiding the cost at the call site so nothing records
what the endpoints actually spend.

The ceilings are measured, not guessed, so the following commit can prove the
explicit select_related calls cover what the manager default used to.
```

### The refactor it protects

```text
ref: Stop joining user by default on the managers

The managers passed select_related("user"), so every caller got the join
whether or not it read the relation, and no call site had to declare the cost.
That default hid an N+1 on the list endpoint. The query budget there sat
at 9 with the join and 14 without it, one extra query per row.

The other manager keeps its default. It affects different callers and has
no query budgets to prove a removal is safe.
```

### Fix

```text
fix: Export first_login and last_login from their own columns

The User Management Report read both login dates through the user relation,
but first_login exists only on Provider and has never been a User field.
getpath catches the resulting AttributeError and returns its default, so
the First Login column has always exported blank.
```

### Revert

```text
revert(api): Add new endpoint

This reverts commit abc123def456.

Reason: Caused a performance regression in production.
```
