# Global agent rules

These rules apply to every repo. A repo-level `AGENTS.md` or `CLAUDE.md` wins on repo workflow. The safety rules below never yield.

## Session start

- Read `AGENTS.md` and `CLAUDE.md` in the project root, plus any in directories you touch. Nearest file wins. Treat them as binding project instructions.

## Safety (never yields to repo rules)

- Do not run destructive or irreversible commands without explicit confirmation: force push, `reset --hard`, `rm -rf`, drop or truncate on a database, forced tool unload.
- Do not commit secrets, credentials, or `.env` contents. Check staged files before `git add -A`.
- Do not overwrite uncommitted work you did not create. Investigate first.

## Working style

- Think before coding. State your assumptions and restate my intent. Turn vague instructions into verifiable success criteria, and ask when unsure rather than guessing.
- Simplicity first: write the minimum code that solves the problem, no abstractions nobody asked for.
- Surgical changes: do not touch code unrelated to the request. Every changed line traces back to what was asked.
- Before reporting done, run the project's tests and lint, and stop any background servers or temp files you started.
- Use parallel tools when applicable.
- Do not extract single-use helpers preemptively. Inline the logic at the call site unless the helper is reused, hides a genuinely complex boundary, or has a clear independent name that improves the caller.
- Before adding complexity for a speculative or vanishingly unlikely race or security edge case, explain the concrete failure mode, likelihood, and complexity cost to the user and get their buy-in. Do not silently expand scope for theoretical robustness.
- Rely on type inference when possible; avoid explicit type annotations or interfaces unless necessary for exports or clarity.
- Avoid `any`/`Any`. Use `unknown` or a generic instead. When you must use it, state why in one line.

## Prose

- Chat replies: present tense, active voice, one idea per sentence, 25 words or fewer. No idioms or metaphor, no nominalizations, no "simply/just/easily", no future tense for behavior.
- Text that leaves the chat (PR descriptions, reviews and comments, Jira tickets, commit messages, code comments, docs): load `asd-ste100` and use STE-flavored mode, then load `unslop`. Write in the Google developer documentation style guide's voice.

## Skills

- Before the first `git commit`, a fresh subagent loads the `pr-review` skill and reviews your uncommitted diff — no PR, no comments posted, findings back as text. Fix from its findings; never review your own diff in-session.
- Load the `commit` skill before you run `git commit`.
- Load the `pr-writer` skill before you create or edit a pull request title or body.
- Load the matching file-type skill (`docx`, `xlsx`, `pptx`, `pdf`, and any newer one) before creating or editing that file type.

## Code comments

- Put a function's reasoning in its docstring: why it exists, design choices, ordering constraints, what it mirrors. Keep inline comments rare: one short line tied to one surprising line. Tests follow the same rule. When you edit a function with scattered comment blocks, fold them into its docstring.

## Worktrees and branches

- Never work on main/master. The layout is a bare clone plus worktrees: run worktree commands from the repo root (where `.git/` lives), never inside a worktree. Use `gwt` (`gwt help`). Worktree and branch names may contain slashes. Suggest a new worktree when a change is unrelated to current work.
- Worktree to session cwd: when you create a worktree, make it the current session's working directory immediately (cd into it, or use your runtime's session-move mechanism, e.g. OpenCode's `tools.opencode.session_move`). Run all later commands there.

## Muxer names

- Name a shared container (herdr space) after the branch or worktree it holds.
- A single session (herdr agent row) does one task. Name it after the task, e.g. `review-pr-123`, and rename it when the task changes. herdr names agents automatically, so do not rename them.

## Command output

- Output here is condensed to save tokens. It keeps every signal and drops noise. Treat it as the complete result, and re-run only when it is unusable.
- Batch related commands into one call to save turns.
- Re-run as `rtk proxy <cmd>` only when the result is empty but output was expected, contradicts its exit code, or is garbled.
