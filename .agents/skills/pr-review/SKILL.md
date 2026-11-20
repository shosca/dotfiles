______________________________________________________________________

## name: pr-review description: > Review a GitHub PR or an uncommitted diff before its first commit. Read the full diff, check patterns and documented rules, find missed consumers, and post line comments when asked. Use when the user says "review this PR", "review #NNNNN", "code review", or invokes /pr-review.

# PR Review

Review a GitHub PR in a local worktree beside the base branch for full Read, Grep, Glob, and LSP
access. Use `gh` only to read metadata and post comments. For an uncommitted diff with no PR, jump
to [Reviewing before a PR exists](#reviewing-before-a-pr-exists).

This skill requires authenticated `gh`, `git`, and the bare-clone worktree layout from `AGENTS.md`
or `CLAUDE.md`. Resolve `OWNER/REPO` once:

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
```

- On a PR, CI owns lint, typecheck, and tests. Check what CI runs and trust its result (throwaway
  probes in Step 8 are exceptions).
- Write all scratch files (patches, path lists, comment bodies) under your session scratch
  directory (`$SCRATCH`), never fixed `/tmp` paths.

## Process

### Step 1: Understand the PR

```bash
gh pr view PR_NUMBER --json title,body,headRefName,baseRefName,headRefOid,additions,deletions
```

Record `headRefName`, `baseRefName`, and `headRefOid` (used later when posting comments).

### Step 2: Read existing comments and reviews

Read all prior discussion before touching the diff:

```bash
gh pr view PR_NUMBER --json comments,reviews
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments --paginate
```

The second call returns line-level review comments (`path`, `line`, `body`), which top-level review
summaries often omit. Check four things:

- **Author replies**: scope or design explanations that change what to flag.
- **Older review rounds**: line comments carry a `commit_id`. Re-check older feedback against the
  current code, since structural issues can survive refactors.
- **Bot and CI comments**: fold useful signals into your findings instead of duplicating them.
- **Open vs resolved threads**: note implemented suggestions explicitly, and carry unaddressed ones
  forward with full weight.

### Step 3: Check out the PR in a worktree

Run from the repo root (where `.git/` lives), not inside a worktree. Skip checkout if the PR lives
on a local branch you already have. In read-only plan mode, ask the user to run these commands and
give you `$WT`.

```bash
BRANCH=$(gh pr view N --json headRefName -q .headRefName)
wt switch pr:N --no-cd -y
WT=$(git worktree list --porcelain |
     awk -v b="refs/heads/$BRANCH" '/^worktree /{p=$2} $0=="branch "b{print p}')
```

Work inside `$WT` and keep the base branch worktree separate for missed-consumer searches. Before
reading code, update `origin/BASE_BRANCH` and check that the diff is non-empty:

```bash
git fetch origin BASE_BRANCH
git rev-parse origin/BASE_BRANCH HEAD
git diff origin/BASE_BRANCH...HEAD --stat | head -5
```

Always compare against `origin/BASE_BRANCH` rather than a potentially stale local base branch,
including ancestry checks (`git merge-base --is-ancestor <commit> origin/BASE_BRANCH`). If a diff or
ancestry check looks surprising, run `git fetch` again before reporting it.

### Step 4: Get the full diff

`gh pr diff` truncates large PRs. Generate the patch from the worktree and list hunk headers:

```bash
git diff origin/BASE_BRANCH...HEAD > "$SCRATCH/prNNNNN-raw.patch"
grep -n "^diff --git\|^@@" "$SCRATCH/prNNNNN-raw.patch"
```

### Re-review after a push

Before re-reviewing a new head, check whether the push changed any PR-owned file or only rebased.
Here `$BASE` is `baseRefName`, `$N` is the PR number, and `<reviewed-sha>` is the last reviewed
head:

```bash
git status --porcelain                    # stop and report if non-empty
git rev-parse --abbrev-ref HEAD           # must be pr/$N
git fetch origin "$BASE"
git fetch origin "pull/$N/head" && git checkout -B "pr/$N" FETCH_HEAD
base="$(git merge-base "origin/$BASE" HEAD)"
git diff --name-only "$base" HEAD > "$SCRATCH/pr-$N-paths"
git diff --name-only <reviewed-sha> HEAD -- $(cat "$SCRATCH/pr-$N-paths")
```

Run `checkout -B` on `pr/$N` only. On a user-owned branch, pull metadata, report the new head, and
stop. Compare file contents on PR paths rather than net patches (rebases shift hunk headers).

- **Empty output**: carry forward only the checks the earlier pass actually ran, and note the
  rebase.
- **Non-empty output**: review the new head. (Files edited by both base and PR trigger a safe
  re-read.)

### Step 5: Check patterns, documented rules, and smells

For each new file, locate its closest precedent with `rg` and read it. Check structural parity
(factories, wrappers, layering), type narrowing, URL and endpoint parity, and constant usage.

#### Documented project rules

1. Collect every rule doc at the PR head (not base): `CLAUDE.md`, `AGENTS.md`, linked docs, project
   docs, matching project skills, and the `codestyle` skill.
1. Select every doc whose scope matches any changed file kind (tests, endpoints, migrations,
   styles), not just the PR title.
1. Read each doc in full and check every rule line by line against covered changes.
1. Quote the doc and broken sentence for each violation. Prohibitions (`never`, `must`, `fails because`) bind the target behavior, not just the literal example form. Examples forbid nothing on
   their own. Judge `codestyle` under the smell baseline bindings below.
1. Record which docs and rules you checked so later re-reviews know what they can carry forward.

#### Smell baseline

Apply Fowler's smells (_Refactoring_, ch. 3) under two bindings:

- **Repo rules win**: suppress any smell that project docs or precedents endorse.
- **Judgement calls only**: report smells as nits (for example, `possible Feature Envy`), never
  blockers. Skip anything linters or type checkers already enforce.

| Smell | Signal | Fix |
| --- | --- | --- |
| Mysterious Name | Name hides purpose or contents | Rename (or clarify murky design) |
| Duplicated Code | Same logic shape in multiple hunks or files | Extract shared helper |
| Feature Envy | Method reads another object's data more than its own | Move method to envied data |
| Data Clumps | Same fields or params travel together repeatedly | Bundle into one type |
| Primitive Obsession | Primitive or string stands in for a domain concept | Wrap in small domain type |
| Repeated Switches | Same switch or if-cascade on one type recurs | Use polymorphism or shared map |
| Shotgun Surgery | One logical change scatters edits across many files | Gather cohesive code in one module |
| Divergent Change | One module edits for unrelated reasons | Split by reason to change |
| Speculative Generality | Unused hooks, params, or abstractions | Delete or inline until needed |
| Message Chains | Long `a.b().c().d()` caller navigation | Hide walk behind one method |
| Middle Man | Class or function mostly delegates onward | Call real target directly |
| Refused Bequest | Subclass ignores or overrides most inherited parts | Replace inheritance with composition |

Also check **Design Lie** under the same judgement-call binding (nit unless behavior already
breaks). A structure lies when a change breaks its name or shape, like a dual-purpose function, boolean mode
flag, or bolted-on branch. State the lie in one sentence, cite the second
caller or source, and give one instruction (`file the redesign separately`, or `redesign here` only
if behavior fails). This matches `codestyle`.

### Step 6: Find missed consumers (critical)

For every deleted export (function, class, constant, selector), search the **base branch worktree**:

```bash
rg -w "deletedSymbolName|anotherDeletedExport"
```

Cross-reference every hit against the PR diff. Any remaining consumer outside the diff and outside
deleted files is a **blocking** missed migration.

For deleted endpoints, queued tasks, or cross-process values, grep cannot see external callers
(mobile apps, other services, queued messages). Ask for production evidence such as access logs by
user agent.

### Step 7: Check requirements

Enumerate requirements first, then check the diff against each item. Gather requirements in order:

1. Linked issues in the PR body or commits (`#123`, `Closes #45`) via `gh issue view` or the repo's
   tracker.
1. The PR body description and acceptance criteria.
1. A spec or brief passed with the review request.
1. Otherwise ask the user (a subagent skips straight to noting `no requirement source available` in
   the verdict and continues the review).

Label every requirement with exactly one status:

- **Missing**: required, absent from diff.
- **Partial**: incomplete (one path missing, modeled but not surfaced).
- **Implemented**: checked directly in the diff.
- **Implemented wrong**: present, conflicts with requirement.
- **Extra**: unrequested behavior (scope creep).

Quote the requirement line next to every non-Implemented item. Trace surrounding code in `$WT`
before marking anything missing. Core `Missing` or `Implemented wrong` items block. `Extra` is
usually a nit or question.

### Step 8: Analyze behavior changes

Read full diff hunks and surrounding code in `$WT` for non-mechanical risks:

- **Sync to async**: callers ignoring a new promise or future can compile with unhandled rejections.
- **Optimistic to pessimistic**: awaiting a previously fire-and-forget call changes error handling
  and user feedback.
- **Deleted side effects**: check that any replacement runs on every path the old code ran on.
- **Deleted names in stored data**: deleted enum members leave DB rows behind. Check sibling
  migrations for parity. Keep unscheduled tasks registered with an empty body for one release while
  queued messages drain.
- **Discarded return values**: side-effect-only calls (such as cache priming) need an explanatory
  comment.
- **Input read before validation**: check whether the diff reads, indexes, iterates, passes, or
  queries raw request input earlier than on base. Any raw-input query must enforce the same tenant
  and permission scope as the validator to prevent error-shape leaks.
- **Request or response shape change**: regenerate the API schema at head and check affected
  operations so generated clients stay aligned.
- **Comments arguing a risk away**: treat claims like `safe because` or `cannot happen` as
  hypotheses. Check both premise and inference by tracing code or running a throwaway test (run
  per-worktree setup from `CLAUDE.md` first), record the result, and delete the test.
- **Threshold or formula changes**: write a throwaway script sweeping valid inputs and exact
  boundary values (watching floating-point drift), record findings, and delete the script.

### Step 9: Categorize findings

- **Blocking**: missed consumer, broken behavior, type error, wrong URL, input used before
  validation, unscoped tenant or permission query, schema mismatch.
- **Nit (non-blocking)**: style, naming, hardcoded constant, missing comment, dead code in a stacked
  series, preserved pre-existing typo.

Report only actionable items. Do not restate what the code does. Call out notably strong work too.

### Step 10: Present findings to the user

Load `asd-ste100` then `unslop` and apply both to every write-up (conversation summary and posted
comments). Re-run `unslop` on the exact literal string right before every `gh api` or `gh pr` call.

Show verdict, blocking findings, and nits in conversation first. **Wait for explicit permission
before posting anything to GitHub.**

Shape every write-up for action (default order is severity, with three overrides):

- **Answer questions first**: reply to the requester's specific questions in order before listing
  your own discoveries.
- **One finding, one place**: state each finding once in full, never repeated across lead, verdict,
  and closing sections.
- **One instruction per finding**: say `fix it here` or `file it separately`, never a hedged double
  verdict. If someone else owns the choice, state that and give the evidence without a competing
  preference.

### Step 11: Post line-level review comments (only when asked)

Load [`pr-comment`](../pr-comment/SKILL.md) before every post for the attribution prefix, secret
scan, and returned-URL check. Follow [`commit`](../commit/SKILL.md) body discipline: state what and
why with concrete evidence (base comparison, grep, test), never include customer data or PII.

Always attach findings to exact file lines read from `$WT` rather than general PR comments. Post all
comments in one review for one notification:

```bash
SHA=$(gh pr view PR_NUMBER --json headRefOid --jq '.headRefOid')

jq -n --arg sha "$SHA" --rawfile body /path/to/review.md \
  --slurpfile comments /path/to/comments.json \
  '{commit_id: $sha, event: "COMMENT", body: $body, comments: $comments[0]}' |
  gh api repos/OWNER/REPO/pulls/PR_NUMBER/reviews --input -
```

- Write `comments.json` with the Write tool as an array of
  `{"path": "src/x.ts", "line": 42, "side": "RIGHT", "body": "..."}` objects so markdown stays
  unescaped.
- Set `event` to `REQUEST_CHANGES` when any finding blocks, and `COMMENT` otherwise.
- Edit a posted line comment with `PATCH repos/OWNER/REPO/pulls/comments/COMMENT_ID -F body=@/path`
  (id is the `r<digits>` tail of `html_url`), or `issues/comments/COMMENT_ID` for issue comments.
- Blocking comments omit `Nit (non-blocking):` and state problem, impact, and fix. Frame feedback as
  constructive suggestions.

### Step 12: Post a summary comment (only when asked)

Post a summary comment only for cross-cutting findings that attach to no single line (such as a
missed consumer in an untouched file):

```bash
gh pr comment PR_NUMBER --body-file /path/to/summary.md
```

- Clean reviews post nothing (no `LGTM`). Attach praise inline to the line that earned it.
- Never duplicate inline comments, narrate your review process, or point at your own inline notes.
  Every sentence must state a claim about the PR.

### Step 13: Clean up the worktree

After the review finishes, delete the review worktree and branch from the repo root. Skip this if
the user wants to inspect it or owns the local branch:

```bash
BRANCH=$(gh pr view PR_NUMBER --json headRefName -q .headRefName)
wt remove "$BRANCH" -y -D
```

`wt remove` runs `[pre-remove]` hooks before deleting the worktree and branch (`-D` handles squashed
branches).

## Replies and searches

- **Author replies belong to the user**: quote any reply without a push and let the user decide.
  Never answer on their behalf.
- **Read what `rg` finds**: once `rg` locates a file, read it directly instead of re-searching.

## Parallel review passes (optional, for heavy PRs)

Skip this on normal PRs. For diffs over ~1,000 added lines or ~20 files, delegate bounded reading
to two subagents. Keep interactive work (Steps 3–4, 6, 8) in this session:

- **Standards subagent**: pass the diff command, hunk/commit list, rule doc paths (Step 5), and the
  full smell baseline pasted inline. Instruct it to load `codestyle` and report rule violations
  (`doc: <quoted sentence>`) and baseline smells or `codestyle` hits (`judgement: <evidence>`),
  skipping tooling-enforced checks.
- **Requirements subagent**: pass the diff command, commit list, and pasted requirement source.
  Instruct it to classify each item (`missing`, `partial`, `implemented`, `implemented wrong`,
  `extra`). Tell it to quote the requirement line for non-implemented items, in under 400 words.

Name the PR kind in each brief. On re-reviews, include `<reviewed-sha>`, blockers to re-check, and
nits not to repeat. Aggregate under separate `## Standards` and `## Requirements` headings with each
axis's count and worst finding. Never merge the two axes into one score.

## Reviewing before a PR exists

When reviewing an uncommitted diff before the first commit, skip Steps 1–4, Re-review after a push,
and Steps 11–13. Apply the rest with these changes:

- **Diff the working tree plus untracked files**:

  ```bash
  git fetch origin BASE_BRANCH
  git diff "$(git merge-base origin/BASE_BRANCH HEAD)" > "$SCRATCH/review-raw.patch"
  git ls-files --others --exclude-standard   # read each untracked file in full
  ```

  Stop and report if both are empty.

- **Run local CI checks**: run per-worktree setup from `CLAUDE.md`, then lint and tests for changed
  files. Report failures as blocking.

- **Requirements**: use only the requester's brief (Step 7 source 3).

- **Return text only**: never post to GitHub. Apply Step 10 shape rules strictly (questions first,
  one place per finding, one instruction each).

- **Respect scope**: report incidental findings in one sentence without reframing the requester's
  task.

## Finding categories checklist

Items 1, 2, 5, and 10–19 apply to every PR. Add items 3, 4, and 6–9 for migration or refactor PRs. A
review finishes only when every applicable item has a result:

1. **Missed consumers**: every deleted export's importers updated or deleted.
1. **Pattern consistency**: new code matches existing conventions.
1. **DTO and type narrowing**: generic types match the API contract tightly.
1. **URL and path parity**: new endpoints match old service URLs.
1. **Behavior changes**: sync to async, optimistic to pessimistic, automatic loading replacing
   manual loading.
1. **Unhandled rejections**: async functions passed as `() => void` to event handlers.
1. **Cache-priming clarity**: discarded-return calls carry explanatory comments.
1. **Snapshot churn**: test snapshots change only where mount order shifted.
1. **Dead code**: additive-only files in stacked series noted, not blocked.
1. **Pre-existing issues preserved**: report with evidence and pick one destination (`this PR` for
   small refactor fold-ins, or `separate PR` when tests, data decisions, or behavior changes are
   needed).
1. **Prior review feedback**: each Step 2 thread checked as resolved, still open, or reintroduced.
1. **Tautological tests**: flag tests that cannot fail (restating implementation, bare
   `toBeDefined()`, broad `expect.any()`, missing `await`) and propose a behavioral assertion.
1. **Documented project rules**: every applicable doc checked line by line (Step 5), listing
   checked docs.
1. **Smell baseline**: all 12 smells checked (Step 5), reported as nits unless repo rules endorse
   them.
1. **Requirement classification**: every requirement carries one Step 7 label (or `no requirement source available`).
1. **Input path and schema**: no pre-validation reads, tenant/permission-scoped raw queries, and
   generated schema matches endpoint shapes (Step 8).
1. **Risk claims probed**: every risk-dismissing comment traced or tested with recorded result
   (Step 8).
1. **Design lie**: diff checked for structure claims vs reality (Step 5), reported with one
   instruction.
1. **Codestyle**: every `codestyle` rule checked (Step 5), listing each rule and result.
