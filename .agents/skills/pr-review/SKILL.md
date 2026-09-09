---
name: pr-review
description: >
  Review a GitHub PR: check out the PR in a worktree, read the full diff, verify against
  existing patterns, find missed consumers, optionally run lint/typecheck/tests, and post
  line-level review comments on the specific file locations. Use when user says "review this
  PR", "review #NNNNN", "code review", or invokes /pr-review. Auto-triggers when reviewing
  pull requests.
---

# PR Review

Review a GitHub PR by checking it out in a **worktree** alongside the base branch. This gives
full Read/Grep/Glob/LSP access to both the PR code and the pre-PR state. `gh` is then used only
to **post** review comments. CI runs lint/typecheck/tests — don't duplicate that work.

Requires `gh` (authenticated), `git`, and the bare-clone + worktree layout from AGENTS.md. This
repo is `ForceTherapeutics/force-web`. CI already runs `tsgo`, `oxlint`, and vitest — do not
re-run them during review.

## Process

### Step 1: Understand the PR

```bash
rtk gh pr view PR_NUMBER --json title,body,headRefName,baseRefName,headRefOid,additions,deletions
```

Note the head branch (`headRefName`), base branch (`baseRefName`), and head commit SHA
(`headRefOid`) — the SHA is needed to post review comments later.

### Step 2: Read existing PR comments and reviews for author-provided context

PRs often carry context that changes what you should even be looking for: prior review rounds,
an author reply explaining a design pivot, or unresolved threads nobody circled back on. Read
all of it before touching the diff:

```bash
rtk gh pr view PR_NUMBER --json comments,reviews
rtk gh api repos/ForceTherapeutics/force-web/pulls/PR_NUMBER/comments --paginate
```

The first call gets top-level issue comments and review summaries (author replies, bot posts).
The second gets the actual line-level review comments (`path`/`line`/`body`) — easy to miss,
since a review's top-level `body` in the first call is often empty and the real content is only
in the per-line comments attached to it.

What to look for:
- **Author replies to prior feedback** — "went with X instead because Y" explains a scope
  decision you'd otherwise flag as arbitrary or missing.
- **Prior review rounds on an earlier commit.** Line comments carry their own `commit_id`,
  which may predate `headRefOid` — the PR may have been reworked since. If so, re-check each
  old comment against the *current* code; don't assume a rework silently fixed everything it
  was reacting to. Some feedback is about a structural/data-shape issue that survives a refactor
  of the surrounding plumbing even when the specific file or prop being commented on is gone.
- **Bot/CI comments** (SonarQube, Cypress, coverage) — informational; skim for anything CI
  flagged that's worth folding into your own findings rather than duplicating.
- **Resolved vs. still-open threads** — if a past suggestion was implemented, say so explicitly
  in your findings so the human reviewer knows it's handled. If not, carry it forward in your
  own review — treat it with the same weight as a finding you found yourself.

### Step 3: Check out the PR in a worktree

Run from the **repo root** (where `.git/` lives), not inside a worktree. See AGENTS.md for the
worktree layout.

**Preferred — `gwt pr`** (if `gwt` is on `$PATH` at `~/.local/bin/gwt`):

```bash
gwt pr PR_NUMBER
```

`gwt pr` fetches `pull/<N>/head`, creates local branch `pr/<N>`, creates a worktree at `pr-<N>/`
relative to the repo root, and auto-cd's into it via a shell hook. Work from that directory.

**If `gwt` is not available**, fall back to a manual worktree:

```bash
git worktree add -b review-PRNNNNN ../review-PRNNNNN PR_HEAD_BRANCH
```

Then work from that worktree directory. The **base branch worktree** (e.g. `master`) stays
checked out separately — that is the pre-PR state you grep against for missed consumers.

**If in plan mode (read-only):** you cannot run `gwt pr` or `git worktree add` yourself. Ask the
user to run `gwt pr PR_NUMBER` and tell you the worktree path (typically `pr-<N>` relative to the
repo root, i.e. `../pr-<N>` from inside the main worktree). Then use Read/Grep/Glob/LSP on that
worktree directory for the rest of the review.

If the PR is already on a local branch (e.g. you authored it), skip the checkout — just work
from its existing worktree.

**Before comparing against the base branch, make sure the base ref is actually current.** A
local `master` (or other base) worktree branch can sit behind `origin/master` for reasons
unrelated to this PR — nobody pulled recently, or the checkout predates a same-day merge. Diffing
or checking ancestry against a stale local ref produces confidently wrong conclusions (e.g. "this
branch depends on an unmerged commit" when that commit landed on master hours ago). Always:

```bash
git fetch origin BASE_BRANCH
git merge-base --is-ancestor <any-suspect-commit> origin/BASE_BRANCH   # not the local branch ref
```

Prefer `origin/BASE_BRANCH` over the local branch ref for every ancestry check and for the
triple-dot diff (`git diff origin/BASE_BRANCH...HEAD`) unless you've just fast-forwarded the
local ref from that same fetch. If a diff or ancestry check produces a surprising result (huge
file count, "commit not found in base," "branch is behind"), fetch and recheck before reporting
it as a finding — don't build a narrative on a ref you haven't confirmed is current.

### Step 4: Get the full diff

`gh pr diff` (and `rtk gh pr diff`) **truncate** large diffs. Get the raw full patch from the
worktree:

```bash
git diff BASE...HEAD > /tmp/prNNNNN-raw.patch
```

Capture the diff hunk headers to understand scope:

```bash
grep -n "^diff --git\|^@@" /tmp/prNNNNN-raw.patch
```

### Step 5: Read the reference patterns

For each new file, find the **existing pattern it mirrors** and read it. The PR's correctness
depends on matching conventions already in the codebase. Use `semble search` or grep to find
the precedent file, then read it with the Read tool.

Verify:
- Does the new code follow the same structure (factory, manual `createApi`, wrapper hook)?
- Are types/DTOs narrowed correctly (e.g. `Props & { id: number }` for `ObjectWithID`)?
- Do URLs / endpoint paths match old behavior?
- Are constants used where existing code uses constants?

### Step 6: Find missed consumers (the critical step)

When a PR **deletes** exports (duck selectors, service functions, action creators), every
consumer must be either updated or deleted. Grep the **base branch worktree** (pre-PR state)
for all imports of the deleted symbols:

```bash
rg "deletedSymbolName|anotherDeletedExport" --type ts --type tsx   # run in the master worktree
```

Then cross-reference every hit against the PR's changed files (from the diff hunk list). If
any consumer is **not** in the PR diff and **not** a deleted file, that's a missed migration —
a blocking finding.

Do this exhaustively. This is the most valuable part of the review.

### Step 7: Analyze behavior changes

Read the full diff hunks (and the surrounding code in the PR worktree) for non-mechanical
changes. Look for:

- **Sync → async**: a function that returned `void` now returns `Promise<void>`. Callers
  typed `() => void` still compile (TS quirk), but React `onClick` won't catch rejections.
  Flag unhandled rejection risk.
- **Optimistic → pessimistic**: fire-and-forget dispatch → `await mutation.unwrap()` before
  UI feedback. Failure path changes — banner/error may now be skipped or thrown.
- **Removed effects**: deleted `useEffect` that dispatched fetch-on-mount. RTK Query
  auto-fetches, but verify the hook is actually mounted (not conditionally skipped with
  `skipToken` / conditional args).
- **Cache-priming**: `useHook()` calls with discarded return value. Fine if deliberate, but
  add a comment or it reads as dead code.

Use Read/Grep/LSP on the PR worktree to trace callers, check types, and confirm behavior.

### Step 8: Categorize findings

- **Blocking**: missed consumer, broken behavior, type error, wrong URL.
- **Nit (non-blocking)**: style, naming, hardcoded vs constant, missing comment, dead code
  in a stacked series, pre-existing typos preserved through a rewrite.

Only post what's actionable. Don't restate what the code does — the author can read the diff.

When the PR does something notably well (a clean pattern match, careful migration, good
defensive coding), call that out too — reviews shouldn't be problem-only.

### Step 9: Present findings to the user

Before writing up findings, invoke the `unslop` skill on the draft — verdict, findings, and
summary alike — to strip AI tells and keep it terse and direct. Do this for every findings
write-up in this skill: the in-conversation summary here, and the line/summary comment bodies
in Steps 10-11.

**Re-run unslop on the exact string right before it gets posted, not only on an earlier draft.**
Invoking `unslop` once in the conversation does not retroactively clean up comment/review bodies
you compose later in the same turn — a body drafted after the skill call still needs its own
pass. Read the literal text going into the `gh api`/`gh pr` call one more time immediately before
that tool call.

Show the findings to the user in the conversation — verdict, blocking findings, nits. **Do
not post anything to GitHub yet.** Wait for the user to explicitly ask you to comment on the PR.

### Step 10: Post line-level review comments (only when asked)

**Only when the user explicitly asks you to comment on the PR**, post findings as line-level
review comments.

**Always post on the specific file + line, never as a general PR comment.** Line comments
attach to the diff hunk and are far more useful — the author sees exactly where to look.

Get accurate line numbers by reading the file in the PR worktree with the Read tool (or `grep
-n` inside the worktree). This replaces the old `gh api contents + base64 -d` dance — the
worktree is right there.

Post each comment via the PR comments API:

```bash
SHA=$(rtk gh pr view PR_NUMBER --json headRefOid --jq '.headRefOid')

rtk gh api repos/ForceTherapeutics/force-web/pulls/PR_NUMBER/comments \
  -F body=@/path/to/comment.md \
  -f commit_id="$SHA" \
  -f path='path/to/file.ts' \
  -F line=42 \
  -f side=RIGHT
```

Write each body to a file in the scratchpad with the Write tool and pass it as `-F body=@FILE`.
Inline `-f body='...'` mangles any body containing backticks, quotes or newlines. Use the Write
tool rather than a shell heredoc, so the body is never subject to shell quoting at all. To edit a
body after posting, `PATCH
repos/ForceTherapeutics/force-web/pulls/comments/COMMENT_ID` with the same `-F body=@FILE` (the
comment id is the `r<digits>` tail of the `html_url` the POST returns); an issue comment uses
`issues/comments/COMMENT_ID`.

For a blocking finding, omit the "Nit (non-blocking)" prefix and describe the problem + impact
+ fix directly. Consider opening as a review with `EVENT=request_changes` if blocking.

Frame feedback as suggestions, not criticism — describe the concern and a proposed
alternative, not a verdict on the author. Run each comment body through `unslop` before posting.

### Step 11: Post a summary comment (only when asked)

If the review has a non-obvious overall verdict or a cross-cutting finding that doesn't attach
to a single line (e.g. "all consumers verified migrated"), post one summary comment:

```bash
rtk gh pr comment PR_NUMBER --body-file /path/to/summary.md
```

Do **not** duplicate line-comment content in the summary — reference it, don't repeat it.

State findings directly. Cut anything that narrates the review process instead of the PR — "reviewed
in a worktree against the full diff, migrations, models, services, ..." says nothing about the code
and wastes the reader's time. Same for referencing your own other comments ("one non-blocking nit
left inline") — the reviewer sees the inline comment already; pointing at it adds nothing. Every
sentence in the summary should be a claim about the PR, not a claim about what you did or where you
left something.

### Step 12: Clean up the worktree

When the review is done, remove the review worktree and its branch:

```bash
git worktree remove ../review-PRNNNNN
git branch -D review-PRNNNNN
```

Skip this if the user wants to inspect the PR themselves, or if the PR was already on a local
branch they own.

## Comment body content

The same content discipline [`commit`](../commit/SKILL.md) applies to commit messages applies to
every posted comment and review body here:

- **What and why, not how.** The diff already shows how; state the finding and its consequence, not
  a restatement of what the code does.
- Cite the evidence that makes a finding real — the specific behavior confirmed against master, a
  grep result, a reproducing test — not a vague "this could be an issue."
- **Never include customer data** — org names, user emails, support ticket contents, PII — in a
  posted comment. Describe the technical symptom, not who hit it. This matters even more here than
  in a commit message: PR comments are more visible and get pasted into Slack/Jira routinely.

## Anti-patterns

- **Posting comments before the user asks.** Present findings in the conversation first. Only
  post to GitHub when the user explicitly says to comment on the PR.
- **Posting a general PR comment instead of line comments.** General comments force the author
  to hunt for the location. Always use line-level review comments.
- **Posting both a general comment AND line comments with the same content.** Choose one
  (line comments). Delete the general duplicate.
- **Posting only criticism.** When the PR does something well, say so — reviews that surface
  only problems demoralize authors and miss the chance to reinforce good patterns.
- **Re-grepping for content you already found.** After `semble search` or grep locates a file,
  read it directly. Don't search for the same thing again.
- **Reaching for `rtk proxy` or bare `gh`.** Every `gh` call in this skill goes through `rtk gh`.
  `rtk proxy` skips the output filter and is for debugging RTK itself; bare `gh` loses the filter
  too. If a call is rejected or fails, fix the call, don't drop to `rtk proxy` or `gh`.
- **Reading files via `gh api contents` when a worktree is checked out.** The worktree is right
  there — use Read/Grep on it instead.
- **Verifying author's test claims.** CI runs lint/typecheck/tests. Don't re-run them or
  claim "tests pass" based on the author's word — just trust CI.
- **Trusting a local base-branch ref without fetching first.** A stale `master` worktree gives
  a stale merge-base, which gives a wrong diff and wrong ancestry checks. Fetch
  `origin/BASE_BRANCH` and diff/check against that before concluding a branch is behind, based
  on an unmerged commit, or missing content that's actually already upstream.
- **Narrating process in a posted comment or review body.** "Reviewed in a worktree against the
  full diff, migrations, models, ..." or "one non-blocking nit left inline" tell the reader
  nothing about the PR. State findings, not what you did or where you left something.

## Finding categories checklist

When reviewing a migration/refactor PR, run through these:

1. **Missed consumers** — every deleted export's importers updated or deleted?
2. **Pattern consistency** — new code matches existing conventions?
3. **DTO/type narrowing** — generic types constrained correctly for the API contract?
4. **URL/path parity** — new endpoints match old service URLs?
5. **Behavior changes** — sync→async, optimistic→pessimistic, auto-fetch replacing manual fetch?
6. **Unhandled rejections** — async fns passed as `() => void` to event handlers?
7. **Cache-priming clarity** — discarded-return hooks have explanatory comments?
8. **Snapshot churn** — test snapshots changed only where mount order actually shifted?
9. **Dead code** — additive-only files in a stacked series noted but not blocked?
10. **Pre-existing issues preserved** — typos/bugs carried through a rewrite — flag for drive-by fix?
11. **Prior review feedback** — for each comment/review found in Step 2: resolved, still open, or
    reintroduced by a later refactor that changed the file but not the underlying issue?
12. **Tautological tests** — any test that asserts something true by construction and can't
    actually fail: an assertion that just restates the implementation with no real contract
    (e.g. `expect(add(1, 2)).toBe(1 + 2)`), a post-construction `expect(instance).toBeDefined()`,
    an `expect.any()` that swallows the value being checked, or a missing `await` so an async
    expectation never runs before the test ends. Such a test passes even when the code is broken —
    flag it and suggest an assertion that exercises the actual behavior.
