# Global OpenCode rules

These rules apply to every repo. A repo-level `AGENTS.md` or `CLAUDE.md` wins on repo workflow. The safety rules below never yield.

## Safety

- NEVER commit changes unless the user explicitly asks. Use the `commit` skill for any commit; it carries the staging, hook, verification, and no-amend rules.
- Ask before destructive commands: force push, `git reset --hard`, `rm -rf`, branch deletes.

## Session start

- Check for `AGENTS.md` and `CLAUDE.md` in the project root. Read them if they exist. Treat them as binding project instructions.

## Session environment

- A session's environment is captured at launch and stays frozen. The working directory does not update it.
- In a mise project, prefix commands that read project env with `mise exec -- `. It resolves the project's current env at exec time, so a stale session env cannot leak through.
- Processes spawned outside the shell (LSP servers, MCP servers) cannot be wrapped. Restart the session from the project directory for those.
- Load the `mise` skill when env problems need debugging.

## Working style

- Think before coding. State your assumptions. Ask when unsure. Never guess.
- Restate my intent before continuing.
- Simplicity first: write the minimum code that solves the problem, no abstractions nobody asked for.
- Surgical changes: do not touch code unrelated to the request. Every changed line traces back to what was asked.
- Goal-driven execution: turn vague instructions into verifiable success criteria before writing code.
- Before reporting done, run the project's tests and lint.
- Use parallel tools when applicable.

## Prose

- Load `asd-ste100` for all prose you write.
  - Chat replies: apply the structural rules (≤20 words for instructions, ≤25 for descriptions). Keep replies concise and actionable.
  - Text that leaves the chat (PR descriptions, PR reviews and comments, Jira tickets, commit messages, code comments, docs): apply STE-flavored mode, then load `unslop`. Write in the Google developer documentation style guide's voice.
  - If the skill fails to load, fall back to: present tense, active voice, second person, one idea per short sentence (~20 words), no idioms or metaphor, no nominalizations, no "simply/just/easily", no future tense for behavior.

## Skills

- Load the `pr-review` skill before reviewing a pull request.
- Load the matching file-type skill (`docx`, `xlsx`, `pptx`, `pdf`) before creating or editing those files.

## Code comments

- Put a function's reasoning in its docstring: why it exists, design choices, ordering constraints, what it mirrors. Keep inline comments rare: one short line tied to one surprising line. Tests follow the same rule. When you edit a function with scattered comment blocks, fold them into its docstring.

## Worktrees and branches

- I work in feature branches and git worktrees, never directly on main/master. If a change seems unrelated to current work, suggest creating a new worktree first.
- Use my `gwt` tool if you see a bare checkout repo setup; see `gwt help`.
- **Layout:** bare clone + worktrees. Run worktree commands from repo root (where `.git/` lives), not inside a worktree.
- **Worktree dirs:** the git branch name and worktree names may contain slashes.
- **Worktree → session cwd:** whenever you create a git worktree, immediately make it the current session's working directory (cd into it, or use your runtime's session-move mechanism — e.g. OpenCode's `tools.opencode.session_move`, or `opencode2 api post /api/session/<id>/move --data '{"directory":"/absolute/path/to/worktree"}'`). All subsequent commands run there; don't keep working from the old directory.

## Muxer names

- A shared container (tmux session, herdr space) holds several sessions. Name it after the branch or worktree it holds.
- A single session (tmux window, herdr agent row) does one task. Name it after the task, e.g. `review-pr-123`. Rename when the task changes.
- **herdr:** agent naming is automatic; do not rename the agent. **tmux:** rename the session only (`tmux rename-session <session>`), never windows.
