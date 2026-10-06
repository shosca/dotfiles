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

Requires `gh` (authenticated), `git`, and the bare-clone + worktree layout from AGENTS.md. Resolve
the repository once and use it wherever the commands below say `OWNER/REPO`:

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

Check what the project's CI runs (lint, typecheck, tests), and do not re-run those checks during
review.

## Process

### Step 1: Understand the PR

```bash
gh pr view PR_NUMBER --json title,body,headRefName,baseRefName,headRefOid,additions,deletions
```

Note the head branch (`headRefName`), base branch (`baseRefName`), and head commit SHA
(`headRefOid`) — the SHA is needed to post review comments later.

### Step 2: Read existing PR comments and reviews for author-provided context

PRs often carry context that changes what you should even be looking for: prior review rounds,
an author reply explaining a design pivot, or unresolved threads nobody circled back on. Read
all of it before touching the diff:

```bash
gh pr view PR_NUMBER --json comments,reviews
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments --paginate
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
- **Bot/CI comments** (static analysis, e2e runs, coverage) — informational; skim for anything CI
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

**Validate before reading, not after.** Confirm the fixed points resolve and the diff is
non-empty before any read-heavy work:

```bash
git rev-parse origin/BASE_BRANCH HEAD
git diff origin/BASE_BRANCH...HEAD --stat | head -5
```

A bad ref or an empty diff should fail here, not mid-review after you have already built
findings on nothing.

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

`gh pr diff` (and `gh pr diff`) **truncate** large diffs. Get the raw full patch from the
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
- Does the new code follow the same structure as its precedent (factories, wrappers, layering)?
- Are types narrowed as tightly as the precedent narrows them?
- Do URLs / endpoint paths match old behavior?
- Are constants used where existing code uses constants?

#### Check the project's documented rules

A precedent file shows how the code looks. It does not show the rules the team has written down,
and a PR that copies a precedent can still break them. Precedents on the base branch break those
rules too, and new code copies them.

1. Find the rule documents. Start at the project's `CLAUDE.md` / `AGENTS.md`, and follow every
   document it links to. Also check the project's docs directory and any project skills that cover
   the kind of code the PR changes.
2. Pick every document whose scope matches a file the PR touches. Decide by the kind of file the
   PR changes (tests, API endpoints, migrations, styles), not by the PR title. A PR can touch
   several kinds of file, and each kind can have its own document.
3. Read each document in full. Then check every rule in it, one at a time, against every new or
   changed line that it covers. A general read of the diff is not this check. Many rules fail on a
   single line, and a reader who is not looking for that rule passes the line.
4. Report each violation with the document and the sentence it breaks, quoted. A prohibition
   ("never", "must") binds the behaviour it targets, not only the literal form its example shows.
   "Never access `request.data` directly with `.get()`" also covers indexing it, iterating it, or
   passing it to a helper before validation.
5. Record which documents and rules you checked. A re-review of a later revision can carry a
   "clean" result forward only for rules that an earlier pass actually checked. If a push changes
   only the lines behind one finding, that does not cover rules no pass ran.

#### Smell baseline

On top of whatever the project documents, apply a fixed baseline of Fowler code smells
(_Refactoring_, ch. 3). Two rules bind it:

- **The repo overrides.** A documented rule or precedent always wins — where the codebase
  endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"),
  never a hard violation. Report smells as nits, not blocking findings. Skip anything tooling
  (linter, type checker) already enforces.

Each smell reads _what it is → how to fix_; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or
  holds → rename it; if no honest name comes, the design is murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change
  → extract the shared shape, call it from both sites.
- **Feature Envy**: a method reaches into another object's data more than its own → move the
  method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type waiting to be
  born) → bundle them into one type and pass that.
- **Primitive Obsession**: a primitive or string stands in for a domain concept that deserves its
  own type → give the concept its own small type.
- **Repeated Switches**: the same switch/if-cascade on the same type recurs across the change →
  replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files → gather what
  changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons → split so
  each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the PR doesn't
  have → delete or inline them until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on → hide the
  walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward → cut it, call the real
  target directly.
- **Refused Bequest**: a subclass or implementer ignores or overrides most of what it inherits →
  drop the inheritance, use composition.

### Step 6: Find missed consumers (the critical step)

When a PR **deletes** exports (functions, classes, constants, selectors), every
consumer must be either updated or deleted. Grep the **base branch worktree** (pre-PR state)
for all imports of the deleted symbols:

```bash
rg -w "deletedSymbolName|anotherDeletedExport"   # run in the base branch worktree
```

Then cross-reference every hit against the PR's changed files (from the diff hunk list). If
any consumer is **not** in the PR diff and **not** a deleted file, that's a missed migration —
a blocking finding.

Do this exhaustively. This is the most valuable part of the review.

### Step 7: Verify against the requirement

Confirm the PR implements what was asked, and nothing smuggled itself in. Work from the
requirement source, not the diff — enumerate what was asked first, then check the diff against
each item.

**Gather the requirement, in this order:**

1. Issue references in the PR body or in commit messages (`#123`, `Closes #45`), fetched via
   `gh issue view`.
2. The PR body's own description / acceptance criteria.
3. A spec or task description a user or requester session passed along with the review request.
4. If nothing is found, ask the user. If they say there isn't one, note "no requirement source
   available" in the verdict and skip this step — a diff can still get the full review.

**Classify against the diff.** For each requirement, mark exactly one of:

- **Missing** — the requirement asks for it; the diff doesn't contain it.
- **Partial** — present but incomplete (one path handled, another not; data modeled but not
  surfaced).
- **Implemented** — and verified in the diff, not just plausible.
- **Implemented wrong** — present, but the behavior conflicts with the requirement.
- **Extra** — behaviour in the diff nothing asked for (scope creep).

Quote the requirement line next to every non-"Implemented" finding. A listing of all
requirements with their classification is the deliverable of this step; it feeds Step 9 (a
"Missing" or "Implemented wrong" on a core requirement is blocking; "Extra" is usually a nit
or a question for the author).

**Verify before reporting.** Trace each suspected gap through the PR worktree — requirements
are often satisfied by code outside the hunks that mention them (a helper, a call site, a
default). Read the surrounding code before claiming a requirement is missing.

### Step 8: Analyze behavior changes

Read the full diff hunks (and the surrounding code in the PR worktree) for non-mechanical
changes. Look for:

- **Sync → async**: a function that returned nothing now returns a promise or future. Callers
  that ignore the return value can still compile, but nothing catches a rejection. Flag the
  unhandled rejection risk.
- **Optimistic → pessimistic**: a fire-and-forget call becomes an awaited call before the user
  sees feedback. The failure path changes: an error message can now be skipped, or an exception
  can now reach the caller.
- **Removed side effects**: deleted code that loaded or wrote data at startup or on load. If
  something else now does it, verify that the replacement runs on every path the old code ran on,
  not only on the default path.
- **Discarded return values**: calls kept only for their side effect, such as priming a cache.
  Fine if deliberate, but add a comment or it reads as dead code.
- **Input read before validation**: code that reads request input before the validator runs, by
  indexing it, iterating it, passing it to a helper, or keying a query on it. Compare the order
  against the base branch, since a change that moves an existing read ahead of validation is new
  risk. A query keyed on raw input must apply the same tenant or permission scope as the validator.
  An unscoped query can leak through the response shape, such as the number of errors in a 400.
- **Request or response shape change**: an endpoint that now takes or returns a different shape,
  such as an array body or a list for one case. Generate the API schema at the head with the
  project's schema command and compare the affected operations. A schema that still documents the
  old shape breaks every generated client.
- **A comment that argues a risk away**: a docstring or comment that says "discloses nothing",
  "safe because" or "cannot happen". Treat it as a claim and probe it. Trace the code, or write a
  throwaway test that would show the failure, run it, record the result, and delete the test. Run
  the project's per-worktree setup from its `CLAUDE.md` before the first test run. A connection
  error on that first run means the setup has not run.

Use Read/Grep/LSP on the PR worktree to trace callers, check types, and confirm behavior.

### Step 9: Categorize findings

- **Blocking**: missed consumer, broken behavior, type error, wrong URL, input used before
  validation, a query that crosses a tenant or permission scope, a schema that no longer matches
  the endpoint.
- **Nit (non-blocking)**: style, naming, hardcoded vs constant, missing comment, dead code
  in a stacked series, pre-existing typos preserved through a rewrite.

Only post what's actionable. Don't restate what the code does — the author can read the diff.

When the PR does something notably well (a clean pattern match, careful migration, good
defensive coding), call that out too — reviews shouldn't be problem-only.

### Step 10: Present findings to the user

Before writing up findings, invoke the `unslop` skill on the draft — verdict, findings, and
summary alike — to strip AI tells and keep it terse and direct. Do this for every findings
write-up in this skill: the in-conversation summary here, and the line/summary comment bodies
in Steps 11-12.

**Re-run unslop on the exact string right before it gets posted, not only on an earlier draft.**
Invoking `unslop` once in the conversation does not retroactively clean up comment/review bodies
you compose later in the same turn — a body drafted after the skill call still needs its own
pass. Read the literal text going into the `gh api`/`gh pr` call one more time immediately before
that tool call.

Show the findings to the user in the conversation — verdict, blocking findings, nits. **Do
not post anything to GitHub yet.** Wait for the user to explicitly ask you to comment on the PR.

**Shape the write-up so the reader can act on it.** Severity ordering is the default, but three
rules override it:

- **Answer what was asked, first.** When the request carries specific questions, they lead the
  reply in the order they were asked. A finding you turned up on your own comes after them,
  however interesting it is. Leading with your own discovery buries the thing the requester is
  waiting on and makes them reconstruct which parts were answers.
- **One finding, one place.** Say it once, in full, and stop. Do not restate it in a lead
  paragraph, then again in a "verdict" section, then again in a closing aside — a reader who meets
  the same finding three times in three framings has to work out which framing is operative.
- **One instruction per finding.** "Fix it here" or "file it separately" — never "my call: fix it
  here, but it stops being a pure refactor, so it's the author's call whether that matters more."
  A hedge attached to a verdict reads as a second, conflicting verdict. If the decision genuinely
  belongs to someone else, say only that and give the evidence they need; do not also state a
  preference.

A reviewer's stated call is treated as a directive, and more so by another agent than by a person.
Ambiguity is not neutral — it gets resolved, and often not the way you meant.

### Step 11: Post line-level review comments (only when asked)

**Only when the user explicitly asks you to comment on the PR**, post findings as line-level
review comments.

**Always post on the specific file + line, never as a general PR comment.** Line comments
attach to the diff hunk and are far more useful — the author sees exactly where to look.

Get accurate line numbers by reading the file in the PR worktree with the Read tool (or `grep
-n` inside the worktree). This replaces the old `gh api contents + base64 -d` dance — the
worktree is right there.

Post each comment via the PR comments API:

```bash
SHA=$(gh pr view PR_NUMBER --json headRefOid --jq '.headRefOid')

gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments \
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
repos/OWNER/REPO/pulls/comments/COMMENT_ID` with the same `-F body=@FILE` (the
comment id is the `r<digits>` tail of the `html_url` the POST returns); an issue comment uses
`issues/comments/COMMENT_ID`.

For a blocking finding, omit the "Nit (non-blocking)" prefix and describe the problem + impact
+ fix directly. Consider opening as a review with `EVENT=request_changes` if blocking.

Frame feedback as suggestions, not criticism — describe the concern and a proposed
alternative, not a verdict on the author. Run each comment body through `unslop` before posting.

### Step 12: Post a summary comment (only when asked)

If the review has a non-obvious overall verdict or a cross-cutting finding that doesn't attach
to a single line (e.g. "all consumers verified migrated"), post one summary comment:

```bash
gh pr comment PR_NUMBER --body-file /path/to/summary.md
```

Do **not** duplicate line-comment content in the summary — reference it, don't repeat it.

State findings directly. Cut anything that narrates the review process instead of the PR — "reviewed
in a worktree against the full diff, migrations, models, services, ..." says nothing about the code
and wastes the reader's time. Same for referencing your own other comments ("one non-blocking nit
left inline") — the reviewer sees the inline comment already; pointing at it adds nothing. Every
sentence in the summary should be a claim about the PR, not a claim about what you did or where you
left something.

### Step 13: Clean up the worktree

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
- **Google developer documentation style, approximating ASD-STE100 Simplified Technical English.**
  Present tense, active voice, one idea per short sentence (~20 words). No idioms or metaphor. No
  nominalizations ("perform an installation" → "install"). Never "simply", "just" or "easily". No
  future tense for behavior — "returns X", never "will return X".
- Cite the evidence that makes a finding real — the specific behavior confirmed against the base
  branch, a grep result, a reproducing test — not a vague "this could be an issue."
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
- **Reading files via `gh api contents` when a worktree is checked out.** The worktree is right
  there — use Read/Grep on it instead.
- **Verifying author's test claims.** CI runs lint/typecheck/tests. Don't re-run them or
  claim "tests pass" based on the author's word — just trust CI. A throwaway probe for a claim no
  test covers (Step 8) is not a re-run. Write it, run it, and delete it.
- **Trusting a local base-branch ref without fetching first.** A stale `master` worktree gives
  a stale merge-base, which gives a wrong diff and wrong ancestry checks. Fetch
  `origin/BASE_BRANCH` and diff/check against that before concluding a branch is behind, based
  on an unmerged commit, or missing content that's actually already upstream.
- **Narrating process in a posted comment or review body.** "Reviewed in a worktree against the
  full diff, migrations, models, ..." or "one non-blocking nit left inline" tell the reader
  nothing about the PR. State findings, not what you did or where you left something.
- **Leading with your own discovery when questions were asked.** The requester's questions come
  first, in their order. Your incidental finding is not more important than the thing they are
  blocked on.
- **Restating one finding in several sections.** Once, in full. Three framings of the same thing
  is not thoroughness, it is a puzzle.
- **A "clean" verdict without the project's documented rules.** Precedent matching and missed
  consumers do not cover the rules the project has written down. A clean verdict that skips them
  leaves the user to find the violations after they approve.
- **A "clean" verdict without a requirements check.** Steps 5-6 and 8 can all pass while the
  answer to "does it do what was asked?" is no. Run Step 7 or state explicitly that no
  requirement source existed.
- **Reviewing a diff you never confirmed is non-empty.** A bad ref or empty diff discovered
  mid-review invalidates everything built on it. Validate first (Step 3).
- **A verdict plus its own hedge.** "Fix it here, but it's arguably out of scope, so it's your
  call" is two answers. Give one.

## Parallel review passes (optional, for heavy PRs)

For a large diff — roughly, over ~1k added lines or over ~20 files — running the Standards and
Requirements passes in separate sub-agents keeps each review out of the other's context and
keeps the expensive reading out of yours. On a normal-sized PR, skip this section: one pass in
this session is cheaper and loses nothing.

Split when you use it:

- **Standards sub-agent** gets: the diff command and hunk/commit list, the paths of every rule
  document found (Step 5), the full smell baseline (Step 5) pasted inline — a sub-agent has no
  other access to it — and this brief: "Report, per file where relevant, every violation of a
  documented rule (cite the document and the rule, quoted) and every baseline smell (name it,
  quote the hunk). Documented rules can be hard violations; smells are always judgement calls,
  and a documented rule overrides the baseline. Skip anything tooling enforces."
- **Requirements sub-agent** gets: the diff command and commit list, the requirement source
  (PR body, issue text, spec) pasted inline, and this brief: "Classify each requirement as
  missing, partial, implemented, implemented wrong, or extra (scope creep). Quote the
  requirement line for every non-'implemented' finding. Under 400 words."

Keep the interactive steps in this session: Steps 3-4 (worktree, diff), Step 6 (missed
consumers — needs live grep against the base worktree), Step 8 (behavior traces).
Sub-agents only run where the work is bounded reading: rules and requirements.

Aggregate the reports under `## Standards` and `## Requirements` headings and end with the
per-axis count and worst finding within each axis. Do not merge the two lists or pick a single
winner across them — a change can pass one axis and fail the other, and ranking across axes
re-hides exactly that.

## Reviewing for another session, before a PR exists

A peer session may hand over a worktree and a list of questions rather than a PR number. Steps 1-2
and 11-13 do not apply — there is nothing to check out and nothing to post. The rest does, and
these are load-bearing rather than stylistic:

- **Findings go back to the requester, never to GitHub.** No PR exists; posting anywhere else is
  not an option to weigh.
- **Everything in Step 10 about shape applies harder.** The reply is the whole artifact and it is
  read by something that will act on it directly. Questions first in their order, one place per
  finding, one instruction each.
- **Stay inside the scope they brought.** They are mid-task with a goal. An incidental finding is
  worth reporting; it is not worth reframing their task around. If it deserves to change what they
  are doing, say that in one sentence and let them decide — do not spread the case for it across
  the reply.

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
10. **Pre-existing issues preserved** — typos/bugs carried through a rewrite. Report them with the
    evidence that makes them real, and say plainly whether they belong in this PR or a separate
    one. Pick one; do not offer both. Weigh it by what the PR is *for*: folding a small fix into a
    refactor is fine, but a fix that needs its own tests, a data decision or a behaviour argument
    is a separate PR, and saying so is more useful than saying it is cheap.
11. **Prior review feedback** — for each comment/review found in Step 2: resolved, still open, or
    reintroduced by a later refactor that changed the file but not the underlying issue?
12. **Tautological tests** — any test that asserts something true by construction and can't
    actually fail: an assertion that just restates the implementation with no real contract
    (e.g. `expect(add(1, 2)).toBe(1 + 2)`), a post-construction `expect(instance).toBeDefined()`,
    an `expect.any()` that swallows the value being checked, or a missing `await` so an async
    expectation never runs before the test ends. Such a test passes even when the code is broken —
    flag it and suggest an assertion that exercises the actual behavior.
13. **Documented project rules** — every rule in each project document that covers the changed
    files was checked line by line (Step 5), and the record names the documents checked.
14. **Smell baseline** — the 12 smells were run against the diff (Step 5); each hit reported as a
    nit, and repo rules that endorse the pattern suppressed it.
15. **Requirement classification** — every gathered requirement carries exactly one label from
    Step 7; a "no requirement source available" note if none was found.
16. **Input path and schema** — for an endpoint change: no request input read before validation,
    every query on request input scoped like the validator, and the generated schema matches the
    shapes the endpoint takes and returns (Step 8).
17. **Risk claims probed** — every comment that argues a risk away was traced or tested, and the
    result recorded (Step 8).
