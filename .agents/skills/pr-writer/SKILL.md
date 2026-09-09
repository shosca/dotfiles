---
name: pr-writer
description: Create and update pull requests. Use when opening a PR or refreshing an existing PR after material changes.
---

# PR Writer

**The PR title and body become the commit message.** On GitHub squash merges, the title becomes the
subject (with ` (#NNNNN)` appended) and the body becomes the body, permanently. Write them for
someone reading `git log` in two years, not as review chatter.

For commits inside the branch, see the [`commit`](../commit/SKILL.md) skill. Requires `gh`, authenticated.

## Precedence

This is the generic skill. If the current repo carries its own `pr-writer` skill (`.claude/skills/`
or equivalent) or documents release conventions in `CLAUDE.md` / `.claude/docs/`, that layer wins.
Before writing a title or picking a base, check for both; the steps below assume nothing about the
repo's branch model, ticketing, or labels beyond squash-merge GitHub.

## Process

### Step 1: Read the branch

```bash
git status
git log origin/<base>..HEAD
git diff origin/<base>...HEAD
```

Everything committed, branch pushed, rebased on its base. Understand every change before writing
anything: the dominant change drives the title, the reviewer-relevant surprises drive the body.

### Step 2: Check for an existing PR

```bash
gh pr view PR_NUMBER --json number,title,body,url,baseRefName,headRefName
```

Treat the current title and body as inputs, not source of truth, and compare them against the
**current** diff rather than the diff from when the PR was opened. Keep the title only if it still
matches the dominant change. Rewrite the body as a fresh description, never an append-only changelog.
Refresh proactively after material follow-up changes — a scope change, a new approach from review
feedback, context the body no longer explains — but skip trivial edits like typos.

### Step 3: Write the title

Follow the repo's own convention when one exists (ticket prefixes, conventional-commit scopes). Where
none is established, use the conventional-commits track: `[Ticket] Imperative subject` when a ticket
exists, `<type>: <Subject>` otherwise (`feat`, `fix`, `ref`, `perf`, `docs`, `test`, `build`, `ci`,
`chore`, `style`, `revert`). Scope in parentheses is one lowercase word.

Rules that hold everywhere:

- Describe the dominant change, not the latest commit. Aim ≤70 characters.
- **Never derive the title from the branch name.** `Dgockel/case filters to smart form` tells a
  reviewer nothing and lands on `master` forever.
- Never invent a ticket number; no ticket means no ticket prefix.
- No attribution brackets — no `[codex]`, `[claude]`, `[ai]`, `[bot]`.
- `[wip]` is fine if the author put it there; do not add or strip it unprompted. Never pass `--draft`
  to repos that do not use drafts.
- `[<topic> N/M]` is fine for a genuinely split series.
- No vague process titles (`update`, `cleanup`, `address feedback`). No trailing period.
- Check whether CI in this repo parses the title (build variables, tag suppression). A stray
  `key=value` in a title can silently change or skip a pipeline stage.

Test on updates: reading only the title, would a reviewer form the right expectation of the current
diff?

### Step 4: Write the description

Reviewer-facing prose, not a narrated diff. Lead with 1–3 sentences on what changed and why it
matters, then 0–3 `**Bold Block**` sections of 1–2 sentences, one per distinct reviewer-relevant
point.

**Voice.** Plain, skimmable, human. The failure mode is the literary essay: long clauses, dramatic
headings, punchlines that land only at the end. Guard against it:

- One idea per sentence, ≤25 words. Active voice, present tense.
- Fact first, implication second. A reader who stops after the first sentence of each section should
  have the full picture — no delayed reveals.
- Headings state the takeaway in plain words. "The Email row went blank for exactly the patient it
  exists to describe" is a dramatic setup; "**Fix: blank email row for empty-string values**" is the
  same fact, readable at a glance.
- No nested parentheticals, no rhetorical asides, no sentences whose point depends on the one before.
- Skim test before posting: read only the title, the headings, and the first sentence of each block.
  If that does not tell the whole story, rewrite.

- Lead with changed behavior; implementation detail only where it helps review.
- Before/after fenced blocks only for changed contracts — output shapes, config, payloads,
  permissions.
- Mermaid codeblock diagrams are welcome where they explain structure or flow better than prose —
  internal call graphs, architecture, state machines, sample usage flows.
- For changes with benchmarks, show a before/after table: baseline from the target branch, candidate
  from the PR. Same machine, same workload, both numbers.
- Name the evidence that made the change safe (a measured query count, a production figure, a
  mutation test) and the thing you deliberately did *not* change, with the reason.
- The description covers the final aggregate diff — what a reviewer sees against the base branch, and
  what the squash-merge commit will say. Never narrate intermediate states: not the earlier commit
  layout, not "went from +6k to +1k lines," not how a refactor moved between commits. That history is
  invisible after squash and is commentary, not description.
- Backtick every code identifier — function/variable/class, filenames, constants — in every
  paragraph, not just the `**Bold Block**` sections. The lead paragraph is the easiest one to typo
  plain, since it is usually drafted first and fastest; re-read it last, specifically for bare
  identifiers, before posting.

A `**Manual testing**` block is allowed, and only for steps a human has to perform by hand — a flow
to click through, a state to set up in an admin, a migration to run against a restored dump. Nothing
CI already does: never list running lint, tests, or type checks. If CI covers the change, omit the
block entirely.

**Never state a test's *outcome*, anywhere in the body, block or no block.** No pass count ("254
passed, 215 subtests"), no suite-status claim ("`reports` is green"), no flaky-test prediction about
what CI will show, no "this proves it's safe" tied to a local run. This is narrower than "never
mention testing" — describing a *new test file* that's part of the diff (what it pins, what invariant
it closes, why the gap existed) is normal, wanted diff description and stays. The line is whether the
sentence reports what happened when something ran, or describes what the test code does: the first
never survives, no rewrite makes it acceptable; the second is ordinary description. Do not carve out
an exception for an outcome that "feels" reviewer-relevant — that carve-out is exactly how a stale
claim gets back in (a flaky-test callout read as a fact right up until the branch already contained
the fix it cited, making the whole sentence wrong). If a flaky or known-broken test genuinely needs
to reach a human, it goes in a PR **comment**, never in the body.

A genuinely impressive, difficult, or high-risk/wide-scoped change may be written like a technical
blog post instead: context and storytelling, code samples, before/after diagrams, the works. Earn it
— most PRs are not this. Even there, the voice rules above hold: short sentences, facts before
implications.

Do not include: generic headings (`## Summary`, `## Changes`, `## Type of Change`); a `## Test plan`
heading or checkbox test steps; a test's outcome in any form; file-by-file narration or redundant
diff summaries; AI-disclosure boilerplate — no generated-with footer, no "This PR is AI-generated"
line. Attribution lives on the commits (`Co-Authored-By` trailers), which GitHub lifts onto the
squash commit; the PR body does not carry it. And never include customer data — org names, user
emails, support ticket contents, PII. Describe the technical symptom, cite the ticket instead.

> This diverges from much of GitHub history, where bodies carry `## Summary` and `## Test plan`
> headings inherited from PR templates. That is intentional; they add nothing to a squashed commit
> message. Genuine manual steps survive as a `**Manual testing**` block.

### Step 5: Create or update

Quote heredocs (`<<'EOF'`) when passing bodies inline — unquoted ones eat backticks. Write a body
file instead for anything with backticks or real length:

```bash
gh pr create --title "Subject" --body-file /tmp/pr-body.md
```

Check the repo's default base before creating; an urgent second PR against a release branch is
leaving it to the repo's convention — not this skill's.

Update an existing PR with `gh pr edit PR_NUMBER --title '...' --body "$(cat <<'EOF' … EOF)"`,
having re-evaluated both. **If that fails with a Projects (classic) deprecation error**, the local
`gh` predates 2.82.1, which fixed it (cli/cli#11987) — check `gh --version` and upgrade, since distro
packages lag badly. Until then `gh api -X PATCH repos/{owner}/{repo}/pulls/PR_NUMBER -f title='...'
-f body="..."` bypasses the GraphQL path.

## Labels

Labels carry process state, so the title and body stay pure description. Labels are repo-specific —
run `gh label list` before assuming any exist, and leave owned labels (`QA`, `priority`, release
gates) to the humans who own them. Never invent one.

Apply the repo's agent-attribution label if one exists (`ai-generated` is the common name) — it is
how a bot PR is told apart from its author's own work. Attribution stays out of the title and body;
the `Co-Authored-By` trailer rides on the commits.

**Never open a draft PR** where the team does not use them. Use the repo's WIP convention (`WIP`
label or `[wip]` prefix) instead; do not add either unprompted, and do not remove one the author set.

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

`/api/details/current/` comes out byte-identical — verified by diffing generated field sets against
the default branch — because the mobile apps depend on it and ship on their own cadence.

**Serializer hierarchy**

`BaseDetailSerializer` is now abstract and never instantiated. It holds the shared field
declarations plus five named groups on its `Meta`, and the three concrete serializers compose
`fields` additively from those groups instead of subtracting from a shared list.
```

## Ticket references

Use the repo's own ticket syntax when it has one (`Fixes KEY-NNNNN`, `Refs KEY-NNNNN`, `Fixes #NNNN`),
and only when the ticket exists — never invent a number. Tickets belong in the PR title when the
repo's squash merge makes that the permanent subject.

## Reviewers

CODEOWNERS or a review policy assigns reviewers automatically — expect them and do not fight the
assignment. Do not pass `--reviewer` to preempt it.

One PR per feature or fix, never bundled. Smaller PRs get faster, better reviews, and the
description carries the why that the code cannot.
