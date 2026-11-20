# Global agent rules

These rules apply to every repo. Read `AGENTS.md` and `CLAUDE.md` in the project root and any directory you touch: nearest file wins on repo workflow. Safety rules below never yield.

## Safety (never yields to repo rules)

- Ask for confirmation before destructive or irreversible commands: force push, `reset --hard`, `rm -rf`, database drop or truncate, forced tool unload.
- Never commit secrets, credentials, or `.env` contents. Check staged files before `git add -A`.
- Never overwrite uncommitted work you did not create. Investigate first.

## Skills

- Load `coding` before writing or editing code.
- Before the first `git commit`, spawn a fresh subagent with `pr-review` to review the uncommitted diff (no PR, no comments posted, findings as text). Fix from its findings. Never review your own diff in-session.
- Load `commit` before `git commit`.
- Load `pr-writer` before creating or editing a PR title or body.
- Load the matching file-type skill (`docx`, `xlsx`, `pptx`, `pdf`, or newer) before creating or editing that file type.

## Prose

- Chat replies: present tense, active voice, one idea per sentence, 25 words max. Avoid idioms, metaphors, nominalizations, "simply/just/easily", and future tense for behavior.
- External text (PR descriptions, reviews, comments, Jira tickets, commit messages, code comments, docs): load `asd-ste100` (STE-flavored mode), then load `unslop`. Match the Google developer documentation style guide voice.

## Worktrees and branches

- Never work on `main` or `master`. Repos use a bare clone plus worktrees: run worktree commands via `wt` (`wt --help`) from the repo root (where `.git/` lives), never inside a worktree. Names may contain slashes. Suggest a new worktree when a change does not belong to current work.
- After creating a worktree, move the session cwd there immediately (`cd` or runtime session move, such as `tools.opencode.session_move`). Run all later commands there.

## Muxer names

- Name each Herdr space after its branch or worktree.
- Keep one task per Herdr tab. Name it after the task (for example `review-pr-123`) and rename it with `herdr-app do tab.rename` when the task changes.

## Command output

- Tool output arrives condensed to save tokens and keeps every signal. Treat it as complete, and batch related commands into one call.
- Re-run as `rtk proxy <cmd>` only when output arrives empty despite expecting data, contradicts the exit code, or looks unreadable.
