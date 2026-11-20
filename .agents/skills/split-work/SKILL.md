______________________________________________________________________

## name: split-work description: Hand a plan worked out in this session to a fresh peer session in its own worktree and Herdr space or WezTerm window. Use when planning finishes and implementation should run separately. Triggers on "/split-work", "split this off", or "hand this to a new session". allowed-tools: Bash(wt:*), Bash(git:*), Bash(wezterm:*), Bash(herdr-app:*), Bash(hc:*), Bash(uuidgen:*), Bash(opencode:\*), Write, Read

# split-work

Turn a plan into a running peer session with its own worktree, handoff doc, muxer location (Herdr
space or WezTerm window), and name.

The new session runs as a peer with its own terminal, permissions, hooks, and transcript. Never
spawn it through subagent tools. Pass only the handoff doc, never this session's transcript or
`--fork-session`.

## Prerequisites

Run every check below before taking action. If any gate fails, stop and report it before creating
anything.

```bash
command -v wt                      # gate: worktree helper
git rev-parse --show-toplevel      # gate: must be a repo
command -v claude                  # gate: resolve agent from these two
command -v opencode
herdr-app status >/dev/null 2>&1   # probe: running Herdr window
wezterm cli list >/dev/null 2>&1   # probe: WezTerm mux
```

Pick the muxer in order: Herdr (running window), then WezTerm. If both probes fail, stop and tell
the user.

## Step 1: Settle the inputs

Decide three values in order before creating anything:

- **Agent (`$AGENT`).** Pick the one of `claude` or `opencode` on `PATH`. If both or neither exist,
  ask the user once.
- **Slug (`$SLUG`).** Name the work in 3 to 5 words of lowercase kebab-case
  (`drop-npx-from-agent-docs`). Use the user's slug if given, or propose one and ask for approval
  first. On Herdr, `$SLUG` also names the tab and must match `[a-z][a-z0-9_-]{0,31}` (at most 32
  characters, dropping words if long).
- **Branch (`$BRANCH`).** Follow the branch convention in the repo's `CLAUDE.md`, `AGENTS.md`, or
  `CONTRIBUTING.md`. If none exists, ask the user. Never invent a ticket key.

**Done:** `$AGENT`, `$SLUG`, and `$BRANCH` hold approved values.

## Step 2: Create the worktree

```bash
command wt switch "$BRANCH" --no-cd -y
WT=$(git worktree list --porcelain |
     grep -B2 -x "branch refs/heads/$BRANCH" | sed -n 's/^worktree //p')
```

- Always call `command wt` (not bare `wt`) so the shell wrapper does not `cd` this session.
  `--no-cd` prevents the binary from requesting a move, and `-y` skips hook approval prompts.
- Read `$WT` from `git worktree list`, not `wt` output. If `$WT` is empty, stop immediately.
- Expect `wt switch` to run `[pre-start]` and `[post-start]` hooks, such as dependency installs.

**Done:** `$WT` holds the worktree path, and this session stays in its original directory.

## Step 3: Write the handoff doc

Save a concise brief (about one screen, prose rather than transcript) to the OS temp directory
(`$TMPDIR`, else `/tmp`), outside the workspace. Store its absolute path in `$DOC`.

```markdown
# <slug>

## Goal
One or two sentences. What is different when this is done.

## Decisions
Each choice that is already settled, with the reason. Include rejected approaches and why.

## Scope
Files and symbols in play, by path. Name them without describing them.

## Out of scope
What to leave alone, and why. Be specific so the PR stays small.

## Done when
Verifiable criteria: a passing command, a changed behavior, an open PR.

## Gotchas
Hard-won findings: hooks that rewrite files, flags that drop TZ, fixtures that overwrite fields.

## After the PR is open
Run the `babysit-pr` skill on the PR. It owns the watch, the merge, and recovery from a failed
check. It runs one pass per prompt; ghpoll sends the next prompt when the PR changes, so do not
write a loop into this session. When a comment needs the user's judgment, or a reviewer asks for
changes you do not agree with, ask the user with your question tool and wait for the answer. Do
not end the turn to signal that you need the user. On a merge or a close, stop and run `teardown`.
```

Always keep **After the PR is open** verbatim. An open question puts Herdr into `blocked` state so
the user notices it, whereas ending a turn looks idle. Do not send separate notifications. Use
`AskUserQuestion` in Claude and `question` in OpenCode.

**Done:** `$DOC` holds an absolute path, and the file exists.

## Step 4: Start the session

Follow only the branch for the muxer chosen in Prerequisites.

### Herdr path

Run the `herdr-dispatch` skill with four values, substituting `$DOC` for `<doc path>`:

```text
path=$WT
name=$SLUG
task=Read <doc path> and implement it.
agent=$AGENT
```

Keep `task` to one line (a newline submits early) and interpolate only the doc path. Do not run
`space.new` or `tab.new` directly: `herdr-dispatch` owns space creation, resume checks, and the
first-message check.

**Done:** `herdr-dispatch` reports a space, a tab, and a terminal with state (or reports the space
if the agent failed to start).

### WezTerm path

Build `$LAUNCH` for `$AGENT`. Keep identifiers out of the prompt because the shell expands
backticks and `$(...)`. Interpolate only `$DOC` and `$SLUG`.

**Claude** (stable UUID5 from `$BRANCH`, resumes existing transcript):

```bash
SID=$(uuidgen --sha1 -n @url -N "$BRANCH")
PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
if [ -f "$PROJDIR/$SID.jsonl" ]; then
  LAUNCH="claude --resume $SID"
else
  LAUNCH="claude --name $SLUG --session-id $SID \"Read $DOC and implement it.\""
fi
```

`--name` sets the prompt box, `/resume` picker, and window title without calling
`wezterm cli set-window-title`.

**OpenCode** (no pre-assigned session id or server rename endpoint, so the first prompt sets it):

```bash
LAUNCH="opencode --prompt 'Read $DOC and implement it. First, rename this session to $SLUG. You have the session_rename tool. Use it before anything else.'"
```

**Spawn the window**, stripping inherited `CLAUDE*` and `OPENCODE*` variables first. Inherited
`CLAUDE_CODE_CHILD_SESSION` disables `.jsonl` saving, `CLAUDE_CODE_SESSION_ID` and messaging vars
block peer registration in `ListAgents` and `SendMessage`, and `OPENCODE*` vars leak parent flags.

```bash
wezterm cli spawn --new-window --cwd "$WT" \
  -- sh -c 'unset $(env | sed -n "s/^\(CLAUDE[A-Z_]*\|OPENCODE[A-Z_]*\)=.*/\1/p"); exec '"$LAUNCH"
```

**Done:** The new WezTerm window opens with `$SLUG` as its title.

## Step 5: Report back

Tell the user:

- Worktree path (`$WT`) and branch (`$BRANCH`).
- Session name (`$SLUG`) to search for (Claude `/resume`, or OpenCode `opencode session list` inside
  `$WT` or the TUI picker).
- For Claude, note that the peer appears in `ListAgents` once booted and accepts `SendMessage`.

On Herdr, also report:

- Space, tab (`$SLUG`), and terminal address (or the space if no terminal appeared after 90 seconds).
- Prompt command (`hc send <terminal> "..."`) and attach command (`hc attach <terminal>`).

On WezTerm, also report the resume command:

- Claude: `cd <worktree> && claude --resume <SID>`
- OpenCode: `cd <worktree> && opencode -s $(opencode session list | grep "<slug>" | cut -f1 | head -1)`

## Notes

- Sessions group under `<repo> · <branch>` in pickers and run their own `SessionStart` hooks.
- OpenCode Stop hooks can overwrite the seeded title after turn one. Keep the link through the
  slug, doc filename, and branch name, or re-pin the Herdr tab with `herdr-app do tab.rename`.
- Herdr clears agent status when an agent exits. Check `hc get` before scripting against it.
- Close only spaces you created with `herdr-app do space.close --id <id> --confirmed true`, never
  `git worktree remove` (which deletes the checkout).
