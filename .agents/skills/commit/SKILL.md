---
name: commit
description: ALWAYS use this skill when committing code changes — never commit directly without it. Creates commits in the Force feature-branch format. Trigger on any commit, git commit, save changes, or commit message task.
---

# Commit

Rules for **local feature-branch commits**. On squash-merge repos, commits reach the default branch
through a GitHub **squash merge**, which builds the permanent message from the PR title and body —
that is [`pr-writer`](../pr-writer/SKILL.md)'s job, including any ticket reference.
Feature-branch commits are what reviewers step through one at a time. They are not throwaway.

## Precedence

This is the generic skill. If the current repo carries its own `commit` skill (`.claude/skills/`,
etc.) or documents commit or branch conventions in `CLAUDE.md` / repo docs, that layer wins. Before
committing, check for both; the steps below assume only conventional-commits style and GitHub.

## Pre-flight

```bash
git branch --show-current
git status --porcelain
```

Identify the repo's default branch and any deploy branches (settings, CLAUDE.md, or repo docs make
this explicit — never assume by name). CRITICAL: **do not commit directly to a long-lived or deploy
branch** (`master`/`main`, `release`, `production`, or whatever the repo names them) unless the user
explicitly asked to commit there — many of those branches deploy on push. If the user did not ask to
commit to one, stop.

On squash-merge repos, CRITICAL: **never commit directly to the default branch** unless the user
explicitly asked — a direct commit bypasses the review path.

For repo-specific branches (release trains, hotfix conventions), follow the repo docs; this skill
does not assume the topology.

## Guardrails

- CRITICAL: NEVER commit unless the user explicitly asks you to. Only commit when asked.
- CRITICAL: Always stage changes, then run the repo's pre-commit hooks and check for failure, before
  `git commit`. prek, pre-commit, husky, lint-staged — whatever the repo installs.
- CRITICAL: A hook rejection means **no commit was created**. NEVER amend — that would rewrite the
  previous, unrelated commit. Stop and ask for help.
- CRITICAL: `git commit` returns non-zero on failure. Check `git log -1 --oneline` before committing to
  see what HEAD points at, and again after to confirm your commit exists and clobbered nothing. Never
  infer success from hook output.

## Pre-commit hook gotchas

Whether hooks validate the message depends on the repo: some install `commit-msg`/commitlint, others
only run linters, so **treat the message format below as yours to enforce**.

- Formatters rewrite files in place (`ruff`, `ruff-format`, `prettier`, `oxfmt`, `oxlint --fix`,
  `stylelint --fix`). After a failed run the fix is usually already applied but unstaged: re-inspect
  and `git add` again before retrying.
- Whole-project or networked checks (`pyrefly`, `uv-audit`) run regardless of what files are staged.
  Slow is not hung.
- Failures on generated state (e.g. missing migration, missing migration docstring) mean fix the
  cause; never `--no-verify`.

## Format

```
<type>(<scope>): <Subject>

<body>
```

Header required; body optional but expected for anything non-obvious. Subject is imperative present
tense ("Add feature", not "Added feature"), capitalized after the type, no trailing period, aim
≤70 characters.

Types: `feat` (new feature), `fix` (bug fix), `ref` (refactoring, no behavior change), `perf`,
`docs`, `test`, `build` (build system or dependencies), `ci`, `chore`, `style` (formatting only),
`meta` (repository metadata), `license`, `revert`. Where the repo's history always uses a
conventional variant (`ref` over `refactor`), follow the repo, not the common spelling.

Scope is optional, one lowercase word naming the area. Use the areas the repo history actually uses.

## Body

- **What** and **why**, not how — the diff shows how. Give the motivation, and contrast with the
  previous behavior when that clarifies the change.
- Plain prose paragraphs, imperative present tense. **No markdown headings and no bullet lists** —
  those belong in the PR body.
- Real newlines. Never emit literal `\n` sequences.
- Cite the evidence that made the change safe when there is any: a measured query count, a
  production figure, a mutation test that proved a budget binds.
- Never include customer data — org names, user emails, support ticket contents, PII. Describe the
  technical symptom, not who hit it.

## Agent attribution

When an agent wrote the change, end the body with a `Co-Authored-By` trailer — blank line before it,
last line of the message, naming the actual agent that did the work:

```
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

Trailers survive squash merges (GitHub lifts them onto the squash commit) and are the signal most AI
reporting counts; the PR body never carries them — see [`pr-writer`](../pr-writer/SKILL.md).

Name the agent honestly. Do not emit a Claude trailer for a non-Claude agent, and do not add one to a
commit a human wrote unassisted; both corrupt any attribution reporting.

## Ticket references

Ticket policy is repo-specific: check the repo skill or docs for where the ticket ID goes (PR title
vs commit subject) and use it. Where the repo squash merges, a ticket reference belongs in the **PR
title**, since that is what lands on the default branch.

- No `Fixes Ticket` footer on a feature commit — once squashed it is redundant with the title.
- No `[Ticket]` prefix on a feature commit. One exception: a single-commit PR where commit and title
  are 1:1, when the repo allows it.
- Never invent a ticket number. Without one, use the ticketless track and say so.

## Commit hygiene

- One stable change per commit, each independently reviewable, the repository working after every
  one.
- **Land the safety net first.** When a change needs a test to prove it is safe, that test goes in
  its own commit ahead of it with the ceiling measured rather than guessed — a query-budget test
  committed before the manager change it protects lets a reviewer see the number both before and
  after.
- Split mechanical churn (renames, formatting, generated files) away from behavior changes.
- **Write the message to a file and commit with `-F`. Do not use `-m "…"`.** A double-quoted shell
  string runs backticks as command substitution, and commit prose about code is full of them.
  ``\`import produce from "immer"\`` in a message makes the shell run `import` — ImageMagick's
  screen-capture tool, which blocks forever waiting for a mouse click and looks exactly like a hung
  agent. `$(…)`, `$VAR` and `!` are the same hazard. Escaping backticks works but only while you
  remember to; `-F` removes the whole class.
- Never embed escaped `\n` in a message; it lands as literal backslashes. A file has real newlines,
  which is another reason to prefer `-F`.

```bash
# write the full message — subject, blank line, body, trailer — to a file first
git commit -F /tmp/commit-msg.txt
```

The same hazard applies to `gh pr create --body`: use a **quoted** heredoc (`<<'EOF'`), which does
not interpolate. An unquoted `<<EOF` does, and will eat backticks in the body the same way.

## Examples

### A test that lands ahead of the change it protects

```
test: Budget queries on the list and detail endpoints

The list and detail endpoints both dereference owner.user while serializing,
and neither had a query budget. The default manager passes
select_related("user"), hiding the cost at the call site so nothing records
what the endpoints actually spend.

The ceilings are measured, not guessed, so the following commit can prove the
explicit select_related calls cover what the manager default used to.
```

### The refactor it protects

```
ref: Stop joining user by default on the managers

The managers passed select_related("user"), so every caller got the join
whether or not it read the relation, and no call site had to declare the cost.
That default was subsidising an N+1 on the list endpoint: the query budget
there sat at 9 with the join and 14 without it, one extra query per row.

The other manager keeps its default. It has a separate blast radius and no
query budgets to prove a removal is safe.
```

### Fix

```
fix: Export first_login and last_login from their own columns

The User Management Report read both login dates through the user relation,
but first_login exists only on Provider and has never been a User field.
getpath swallows the resulting AttributeError and falls back to its default,
so the First Login column has always exported blank.
```

### Revert

```
revert: feat(api): Add new endpoint

This reverts commit abc123def456.

Reason: Caused a performance regression in production.
```
