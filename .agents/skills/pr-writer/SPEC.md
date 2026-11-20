# PR writer specification

## Intent

The `pr-writer` skill creates and updates pull requests with concise, review-oriented titles and
descriptions. It generalizes Sentry's `pr-writer` skill so repo layers own branch models, ticketing,
labels, and CI title parsing. Squash merges turn the PR title and body into the permanent commit
message.

Its job is turning branch diffs into reviewer-facing prose that explains what changed, why it
changed, and the surprises reviewers need before reading the diff.

## Scope

In scope:

- Creating pull requests from committed feature branches.
- Updating existing PRs by re-evaluating title and body against the current diff.
- Writing compact PR bodies with optional bold blocks and views.
- Detecting and deferring to repo-level convention layers (repo skill, `CLAUDE.md`, `.claude/docs/`).

Out of scope:

- Writing commits or deciding commit history policy.
- Running CI or fixing failing checks.
- Writing release notes, changelogs, or customer announcements.
- Encoding repo-specific release cadence.

## Triggers

- Primary users: engineers and coding agents preparing pull requests in any repo.
- Use for: opening a PR, updating a PR, or refreshing a PR after scope changes or review feedback.
- Skip for: code reviews, commit-only tasks, CI-fix loops, or generic documentation.

## Runtime contract

- **Inputs.** Check the branch, committed state, base branch, repo convention layer, and diff before
  writing. On updates, read the existing title and body first.
- **Outputs.** Produce a title matching the repo format (conventional commits by default) and a
  concise body passed via `--body-file`. On updates, decide explicitly whether to keep or rewrite
  the title.
- **Proactive refresh.** When follow-up commits materially shift reviewer expectations on an open
  PR, refresh it without waiting for an explicit request.
- **Hard constraints.** Include no customer data, secrets, or PII. Omit bracketed agent prefixes
  (`[codex]`), repository PR templates, test-plan checklists, and test outcomes. Follow repo
  conventions for drafts and WIP markers.
- **Runtime files.** Load only `SKILL.md`.

## Sources

- Sentry code-review and commit-message practices (origin of the craft and title rules).
- Repo-level agent instructions (`CLAUDE.md`, `.claude/docs/`, repo skills), which override defaults.
- `getsentry/warden#265` as the formatting exemplar for before/after contract blocks.

Never store secrets, customer data, private org or user identifiers, or raw support ticket contents.

## Evaluation

Test representative feature, schema-change, refactor, and update prompts. Include holdout cases for:

- A simple PR needing no bold blocks.
- A PR with no ticket.
- A contract change needing before/after blocks.
- An update whose old title no longer fits.
- A follow-up commit requiring a proactive refresh.

Acceptance gates:

- Title matches repo format (or conventional commits), has no agent brackets, and reflects the
  dominant change.
- Update flows re-evaluate the title, and material follow-up commits trigger a refresh.
- Body opens with 1 to 3 sentences leading with changed behavior before implementation detail.
- Body has at most a few bold blocks, before/after blocks only for contract changes, and no generic
  headings, test plans, test outcomes, or customer data.
- Unknown ticket references stay omitted, and drafts or WIP markers follow repo rules.

## Known limitations

- Ticket accuracy depends on the branch, commits, or user providing the reference.
- Deciding when to add bold blocks or rewrite an existing title relies on agent judgment.
- Very large PRs may need more context than the default short body allows.
