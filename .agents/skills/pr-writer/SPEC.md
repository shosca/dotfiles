# PR Writer Specification

## Intent

The `pr-writer` skill creates and updates pull requests with concise, review-oriented titles and descriptions that match the originating repo's conventions.

It is a fork of Sentry's pr-writer skill, generalized: repo conventions (branch model, ticketing, labels, CI title parsing) defer to the repo layer, the squash merge makes the PR title and body the commit message, and the writing craft (voice, bold blocks, no test outcomes) is generic.

Its main job is to turn branch changes into reviewer-facing prose that explains what changed, why it changed, and the few details reviewers need before reading the diff. It should avoid long essays, mechanical diff summaries, agent/tool attribution markers, and vague titles that no longer match the branch scope.

## Scope

In scope:

- Creating pull requests from committed feature branches.
- Updating existing PRs by re-evaluating both title and body against the current diff.
- Producing compact PR bodies with optional bold emphasis sections.
- Producing titles that accurately describe the dominant change in the PR.
- Rejecting bracketed agent, bot, or tool prefixes in PR titles.
- Detecting and deferring to repo-level convention layers (repo skill, `CLAUDE.md`, `.claude/docs/`).
- Including issue references and review context when useful.

Out of scope:

- Writing commits or deciding commit history policy.
- Running full CI or iterating on failing checks.
- Producing release notes, changelogs, or customer-facing announcements.
- Including test-plan checklists in PR bodies.
- Encoding one repo's release cadence; that belongs in repo docs or the repo-level skill.

## Users And Trigger Context

- Primary users: engineers and coding agents preparing pull requests in any repo; originally written for Sentry pull requests.
- Common user requests: open a PR, update a PR, refresh a PR after scope changes, address review feedback after follow-up commits, prepare changes for review.
- Should not trigger for: code review requests, commit-only requests, CI-fix loops, or generic documentation writing.

## Runtime Contract

- Required first actions: verify the current branch, committed state, base branch, and diff scope before writing or updating a PR; when updating, inspect the current PR title and body before deciding what to keep.
- Required outputs: a conventional PR title and a concise PR body suitable for `gh pr create` or GitHub API update commands; on updates, include an explicit keep-or-rewrite decision for the title.
- Required update behavior: if an open PR exists and follow-up commits materially change reviewer expectations, refresh the PR even when the user did not explicitly ask for a PR edit.
- Required scope detection: before creating the PR, check the repo's default base and for a repo-level convention layer; use the repo's title format, base, labels, and WIP/draft convention when they exist.
- Non-negotiable constraints: never include customer data or PII, never use bracketed agent/tool labels such as `[codex]` in PR titles, ignore repository PR templates, omit test-plan sections and test outcomes, and defer draft-PR decisions to the repo's convention rather than defaulting to drafts.
- Expected bundled files loaded at runtime: only `SKILL.md`.

## Source And Evidence Model

Authoritative sources:

- Sentry engineering practices for code review (origin of this skill's craft rules).
- Sentry commit message conventions (origin of the conventional-commits title format).
- Repository-level agent instructions — repo skills, `CLAUDE.md`, `.claude/docs/` — take precedence over the defaults here.
- Observed user preference for short PR bodies with optional bold emphasis sections.
- `getsentry/warden#265` as a formatting exemplar for before/after examples on schema and output-shape changes.

Useful improvement sources:

- positive examples: PR descriptions that reviewers can scan quickly.
- positive examples: PR titles that stay specific after follow-up commits.
- negative examples: PR bodies that read like essays, repeat the diff, or overuse headings.
- negative examples: PR titles that are vague, process-oriented, or stale after scope changes.
- negative examples: PR titles that use bracketed agent/tool labels instead of conventional commit types, such as `[codex] Paginate replay segment downloads`.
- negative examples: branches with material follow-up commits where the agent pushed changes but left the PR title/body stale.
- commit logs/changelogs: only as source context, not as body text to paste.
- issue or PR feedback: reviewer comments about missing context or excessive detail.
- eval results: prompt-based checks for title accuracy, concise summaries, optional sections, and privacy boundaries.

Data that must not be stored:

- secrets
- customer data
- private customer, organization, or user identifiers
- support ticket contents not needed for a public PR

## Reference Architecture

- `SKILL.md` contains runtime workflow, command patterns, PR body template, examples, and safety constraints.
- `references/` contains no files currently; add focused style or evidence examples only if the runtime file becomes too long or repeated regressions show the examples need more room.
- `references/evidence/` contains no files currently; use it for durable positive and negative PR body examples if iteration data accumulates.
- `scripts/` contains no files currently.
- `assets/` contains no files currently.

## Evaluation

- Lightweight validation: compare generated titles and PR bodies against representative feature, schema-change, and refactor prompts for brevity, clarity, optional-section use, issue references, update-path title handling, and privacy handling.
- Deeper evaluation: maintain a small prompt set with expected body shapes if regressions recur.
- Holdout examples: include at least one simple PR that should have no bold section, one PR with no known issue reference, and one API or input-format change that should use separate before/after fenced blocks.
- Holdout examples: include at least one PR update where the old title no longer matches the final diff and must be rewritten.
- Holdout examples: include at least one review-feedback or follow-up-commit scenario where the skill should refresh an open PR without an explicit PR-update request.
- Acceptance gates: output title uses the repo's title format (or a conventional-commits style when the repo has none), contains no bracketed agent/tool prefix, matches the dominant change, update flows explicitly re-evaluate whether the existing title still fits, material follow-up commits to an open PR trigger a refresh even without an explicit PR-update request, output begins with a 1-3 sentence summary, summary prose leads with the changed behavior before implementation detail, uses no required generic headings, includes at most a few bold emphasis blocks, uses before/after examples only when direct comparison is the clearest explanation, omits unknown issue references instead of inventing placeholders, avoids test-plan sections and test outcomes, follows the repo's draft/WIP convention instead of defaulting to drafts, and does not include customer data.

## Known Limitations

- The skill cannot guarantee that issue references are correct unless the branch, commits, or user provide them, and should omit references rather than invent placeholders.
- It relies on the agent's judgment to decide whether a bold emphasis block is useful.
- It relies on the agent's judgment to decide when a title is still accurate enough to keep versus rewrite.
- Very large PRs may still need more context than the default body shape encourages.

## Maintenance Notes

- Update `SKILL.md` when PR creation workflow, title rules, body template, examples, or safety constraints change.
- Update `SPEC.md` when intent, scope, evaluation gates, or evidence policy changes.
- Add focused reference files only when examples or guidance would make `SKILL.md` noisy.
- Keep public inventories pointed at the canonical `skills/pr-writer` skill, not mirrors.
