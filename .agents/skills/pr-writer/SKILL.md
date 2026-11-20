______________________________________________________________________

## name: pr-writer description: Open a pull request, or refresh an existing one after material changes.

# PR writer

The PR title and body become the squash-merge commit message permanently. Write them for someone
reading `git log` in two years, not as review chatter. Keep one PR per feature or fix, never
bundled.

## Precedence

This is the generic skill. If the repo has its own `pr-writer` skill (`.claude/skills/` or
equivalent) or documents release rules in `CLAUDE.md` or `.claude/docs/`, that layer wins. Check
for both before picking a base, title format, or labels.

## Process

### Step 1: Read the branch

```bash
BASE=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)
git fetch origin "$BASE"
git status
git log "origin/$BASE"..HEAD
git diff "origin/$BASE"...HEAD
```

Commit, push, and rebase all work on the base branch first. Read every change before writing: the
dominant change drives the title, and reviewer-relevant surprises drive the body.

### Step 2: Check for an existing PR

```bash
gh pr view --json number,title,body,url,baseRefName,headRefName
```

With no argument, this reads the current branch's PR. A non-zero exit means no PR exists, so
continue to Step 3.

Treat the existing title and body as inputs, not truth. Compare them against the current diff. Keep
the title only if it still matches the dominant change. Rewrite the body fresh, never as an
append-only changelog. Refresh proactively after material follow-up changes (scope changes, new
approaches from review, outdated context), and skip trivial edits like typos.

### Step 3: Write the title

Follow the repo's convention when one exists. Otherwise use `[Ticket] Imperative subject` when a
ticket exists, or `<type>: <Subject>` (`feat`, `fix`, `ref`, `perf`, `docs`, `test`, `build`, `ci`,
`chore`, `style`, `revert`) with an optional one-word lowercase scope in parentheses.

- Describe the dominant change, not the latest commit or branch name. Aim for 70 characters or fewer.
- Use the repo's ticket syntax (`Fixes KEY-NNNNN`, `Refs KEY-NNNNN`, `Fixes #NNNN`) only when a
  ticket exists. Never invent a number.
- Omit agent brackets (`[codex]`, `[claude]`, `[ai]`, `[bot]`).
- Keep `[wip]` if the author added it, and never add or remove it unprompted. `[<topic> N/M]` is
  fine for a split series.
- Avoid vague titles (`update`, `cleanup`, `address feedback`) and trailing periods.
- Check whether repo CI parses titles for build variables or tag suppression, because a stray
  `key=value` can change or skip pipeline stages.

Test on updates: reading only the title, does a reviewer form the right expectation of the current
diff?

### Step 4: Write the description

Lead with 1 to 3 sentences on what changed and why it matters. Follow with 0 to 3 `**Bold block**`
sections of 1 to 2 sentences, one per distinct reviewer-relevant point.

**Voice and clarity.** Follow `AGENTS.md` prose rules (`asd-ste100` and `unslop`). State facts
before implications, with no delayed reveals, nested parentheticals, or rhetorical asides. Headings
state the takeaway in plain words (`**Fix: blank email row for empty-string values**`), never a
dramatic setup.

**Content rules.**

- Lead with changed behavior, and add implementation detail only where it helps review.
- Describe what the code does, not a metric that prompted the change (line count, file count,
  complexity score). Include metrics only when the number is the change, such as a perf PR.
- Cover the final aggregate diff against the base branch. Never narrate intermediate commits or
  earlier refactor states.
- Backtick every code identifier (functions, variables, classes, filenames, constants) in every
  paragraph. Re-read the lead paragraph last to catch bare identifiers.
- Name the evidence that makes the change safe (query count, production data, mutation test) and
  anything you deliberately left unchanged, with the reason.
- For benchmarked changes, include a before/after table from the same machine and workload (base
  branch vs PR).

**Visual views.** Use at most one view per PR unless two readers need different pictures. Place it
beside the text it supports, and trim every call, file, prop, or state that does not answer the
reviewer's question.

| Change | View |
|---|---|
| Logic or algorithm | Pseudocode in a `text` block, no language syntax |
| Runtime control flow | Call tree ordered by call, not by file |
| UI structure | Component tree with relevant state and module boundaries |
| File responsibility or broad refactor | Shallow file tree, one comment per file |
| Component interaction, architecture, or state machine | Mermaid diagram (for example, `sequenceDiagram`) |
| Existing shape modified | Trimmed `diff` sketch of changed lines (show full block if mostly new or copyable) |
| Changed contract (output, config, payload, permissions) | Separate before/after fenced blocks |

**Manual testing.** Add a `**Manual testing**` block only for steps a human must run by hand (a UI
flow, admin setup, or migration against a dump). Never list lint, tests, or type checks that CI
runs. Omit the block when CI covers the change.

**Never state test outcomes.** Do not include pass counts, green-suite claims, local-run proof, or
flaky-test predictions anywhere in the body. Describing a new test file by what it pins and why the
gap existed is fine. Put flaky or known-broken test callouts in a PR comment, never the body.

**Long-form exception.** A difficult or high-risk change may read like a technical blog post with
context, code samples, and diagrams. Most PRs do not earn this. Keep short sentences and facts
before implications.

**Omit from every body.**

- Generic headings (`## Summary`, `## Changes`, `## Type of Change`) and `## Test plan` checklists.
- File-by-file narration or redundant diff summaries.
- AI-disclosure footers (`Co-Authored-By` trailers on commits carry attribution into squash merges).
- Customer data (org names, user emails, support ticket contents, PII). Describe the technical
  symptom and cite the ticket instead.

**Skim test (completion check).** Read only the title, headings, and the first sentence of each
block. If that misses the story, rewrite.

### Step 5: Create or update

Always pass the body from a file. Inline `--body` flags and heredocs lose backticks and quotes.

```bash
gh pr create --title "Subject" --body-file /tmp/pr-body.md
gh pr edit PR_NUMBER --title "Subject" --body-file /tmp/pr-body.md
```

If `gh pr edit` fails with a Projects (classic) deprecation error, local `gh` predates 2.82.1
(`cli/cli#11987`). Upgrade `gh`, or update through the REST API:

```bash
gh api -X PATCH repos/{owner}/{repo}/pulls/PR_NUMBER -F title='Subject' -F body=@/tmp/pr-body.md
```

## Labels, drafts, and reviewers

- **Labels.** Read `gh label list --json name,description` before adding labels (`--label` on create
  or `gh pr edit PR_NUMBER --add-label "<name>"`). Never invent labels, and skip human-owned labels
  (`QA`, `priority`, release gates). Apply only labels whose description matches the diff, or none
  for a small change.
- **Special labels.** Apply the repo's agent-attribution label (`ai-generated`) if one exists. Apply
  `security` if one exists when the PR fixes a check failing on every branch, such as an audit
  advisory. `ghpoll-digest` reads it to pause duplicate fixes on other PRs.
- **Drafts.** Never pass `--draft` on a repo that avoids draft PRs. Follow the repo's WIP convention
  (`WIP` label or `[wip]` prefix), without adding or removing it unprompted.
- **Reviewers.** Do not pass `--reviewer`. Let `CODEOWNERS` or review policy assign reviewers.

## Examples

### Bug fix with production evidence

```markdown
Numeric check-in ranges were only ever enforced in the browser. When a data collection type had no
custom validation message, an out-of-range answer was silently rewritten to the nearest bound and
saved with no error shown. The collect endpoint now returns a 400 instead of storing a fabricated
value.

**Confirmed in production data**

~23% of knee flexion and ~11% of knee extension measurements sit exactly on a range bound.
Temperature is clean across 157,416 readings, so the unit-conversion concern that prompted this did
not materialize.

**Scoped to the collect endpoint, not the model**

Enforcement lives in the collect serializer rather than `DataCollection.clean()`. Model-level checks
would abort the parent log write from a `post_save` receiver, and bulk-create paths bypass
`full_clean` anyway, so the model is not a real chokepoint.
```

### Refactor with a deliberate non-change

```markdown
Trims the detail endpoint from 46 to 35 top-level fields by dropping ten fields the web app only
ever reads from `/api/details/current/`, plus the nested `user` object and the 45-field
`organization` blob.

`/api/details/current/` comes out byte-identical, verified by diffing generated field sets against
the default branch, because the mobile apps depend on it and ship on their own cadence.

**Serializer hierarchy**

`BaseDetailSerializer` is now abstract and never instantiated. It holds the shared field
declarations plus five named groups on its `Meta`, and the three concrete serializers compose
`fields` additively from those groups instead of subtracting from a shared list.
```
