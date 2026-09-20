---
name: split-work
description: Hand a plan worked out in this session to a fresh agent session (Claude or OpenCode) in its own worktree and its own WezTerm window. Use when planning is done and the implementation should run somewhere else, separately steerable. Triggers on "/split-work", "split this off", "hand this to a new session", "open a window and work on this there".
allowed-tools: Bash(gwt:*) Bash(git:*) Bash(wezterm:*) Bash(uuidgen:*) Bash(opencode:*) Write Read
---

# split-work

Turn a plan into a running peer session: a worktree, a handoff doc, a new WezTerm window, and an
agent session named after the work.

The new session is **not** a subagent. It has its own terminal, its own permission prompts, its own
hooks, and its own transcript. You keep talking to it through its window, or over peer messaging
once it registers as a peer in `ListAgents` (Claude only).

## What travels

The handoff doc, and nothing else. The new session starts cold apart from that file.

Do not copy this session's transcript into the new project directory. A `--fork-session` resume
carries the whole conversation, including everything the new session has no use for, and buries the
plan under it. A tight brief reads better and costs less.

## Preconditions

```bash
wezterm cli list >/dev/null    # must succeed: you are inside a WezTerm mux
command -v gwt                 # worktree helper
git rev-parse --show-toplevel  # must be a repo
```

If `wezterm cli list` fails, stop and say so. Nothing else in this skill works outside a WezTerm
session.

## Step 0: Resolve the agent

```bash
command -v claude
command -v opencode
```

Exactly one on PATH → that is the agent. Both or neither → ask the user once and remember the
answer. Reserve a variable for it and reuse it below.

## Step 1: Settle the slug

The slug names the work, not the directory: `drop-npx-from-agent-docs`, `report-query-counter`.
Kebab-case, 3-5 words. One slug drives everything downstream — the branch, the worktree path, and
the session name.

Take it from the user's argument when they gave one. Otherwise propose one from the work and confirm
it before creating anything. A slug is hard to change afterwards: it is baked into the branch name,
and the branch name cannot change once a PR is open.

## Step 2: Build the branch name

The branch convention is declared by the repo, not by this skill. Read the repo's `CLAUDE.md` /
`AGENTS.md` / `CONTRIBUTING.md`; follow what it declares. If no convention is documented, ask the
user. Never invent a ticket key, and never invent a naming scheme.

## Step 3: Create the worktree

```bash
gwt co "$BRANCH"
WT=$(git worktree list --porcelain |
     awk -v b="refs/heads/$BRANCH" '/^worktree /{p=$2} $0=="branch "b{print p}')
```

Read the path back from `git worktree list` rather than parsing `gwt` output. Do not `cd` into it —
this session stays where it is.

## Step 4: Write the handoff doc

Put it at the bare clone root, beside the worktree directories:

```bash
ROOT=$(dirname "$(git rev-parse --git-common-dir)")   # works from inside any worktree
DOC="$ROOT/.handoffs/$SLUG.md"
mkdir -p "$ROOT/.handoffs"
```

The root is not a working tree, so nothing there can reach a commit and no `.gitignore` entry is
needed. It also survives `gwt rm`: the doc outlives the worktree it briefed. In a repo without this
layout, `--git-common-dir` returns the worktree's own `.git`, and the root is the checkout itself;
use a git-ignored directory there instead.

Pass the absolute path in the launch prompt, since the new session's cwd is the worktree.

The doc carries what the code cannot say for itself:

```markdown
# <slug>

## Goal
One or two sentences. What is different when this is done.

## Decisions
Each choice that is already settled, with the reason. Include the approaches that were
rejected and why — that is the part the new session cannot re-derive from the code.

## Scope
The files and symbols in play, by path. Name them; do not describe them.

## Out of scope
What to leave alone, and why. Be specific. This is the section that keeps the PR small.

## Done when
Verifiable criteria. A command that passes, a behavior that changes, a PR that exists.

## Gotchas
What we found the hard way: a hook that rewrites files, a flag that drops TZ, a fixture that
overwrites the field you set.
```

Prose, not a transcript. Aim for one screen. Leave out the exploration that produced the plan.

## Step 5: Strip the environment and pick the policy

Every agent spawn below uses the same wrapper, which strips inherited identity variables before
exec:

```bash
unset $(env | sed -n 's/^\(CLAUDE[A-Z_]*\|OPENCODE[A-Z_]*\)=.*/\1/p')
```

Why this matters:

- **Claude-only:** a spawn from inside a Claude Code tool call passes ten `CLAUDE*` variables to the
  child, and two break the new session outright:
  - `CLAUDE_CODE_CHILD_SESSION` turns transcript saving off. The session runs, but writes no
    `.jsonl`, so `--resume` and the `/resume` picker never find it. The session also prints a
    warning about it, which is the only visible symptom.
  - `CLAUDE_CODE_SESSION_ID`, `CLAUDE_CODE_MESSAGING_SOCKET` and `CLAUDE_CODE_MESSAGING_TOKEN`
    carry the parent's identity and message channel. With them set, the new session does not
    register as a peer, so `ListAgents` does not see it and `SendMessage` cannot reach it.
  - Both were confirmed by spawning one session with the variables and one without.
- **OpenCode-only:** `OPENCODE_EXPERIMENTAL` and `OPENCODE_TERMINAL` leak the parent's flags into
  the child. Strip them for the same hygiene.

## Step 6: Launch

### Claude

Claude accepts a caller-supplied stable session id and a display name. UUID5 over the branch name
is stable: the same branch always yields the same id, and a resume needs no lookup. The id is the
machine address; the name is what a human reads.

```bash
SID=$(uuidgen --sha1 -n @url -N "$BRANCH")
PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
if [ -f "$PROJDIR/$SID.jsonl" ]; then
  LAUNCH="claude --resume $SID"
else
  LAUNCH="claude --name $SLUG --session-id $SID \"Read $DOC and implement it.\""
fi
wezterm cli spawn --new-window --cwd "$WT" \
  -- sh -c 'unset $(env | sed -n "s/^\(CLAUDE[A-Z_]*\|OPENCODE[A-Z_]*\)=.*/\1/p"); exec '"$LAUNCH"
```

CRITICAL: the prompt is an argv string the shell expands. Backticks and `$(…)` in it run as
commands. Keep identifiers out of the prompt — the doc holds them.

`--name` sets the display name in the prompt box, the `/resume` picker, and the terminal title. No
separate `wezterm cli set-window-title` call is needed.

### OpenCode

OpenCode generates its own session id; you cannot pre-bake one. The name is what you anchor on, and
it does not exist yet at launch — so make the new session name itself first.

```bash
wezterm cli spawn --new-window --cwd "$WT" \
  -- sh -c 'unset $(env | sed -n "s/^\(CLAUDE[A-Z_]*\|OPENCODE[A-Z_]*\)=.*/\1/p"); exec opencode
  --prompt "Read '"$DOC"' and implement it. First, rename this session to '"$SLUG"'. You have the
  session_rename tool — use it before anything else."'
```

Notes:

- Sessions are directory-scoped. `opencode session list` inside the worktree shows the new session
  and its id once it has one.
- There is no rename endpoint on the server API, so the first-prompt instruction is the only
  headless way to set the name. If the session is already running and unnamed, the user can run
  `/rename` manually in the TUI.
- The request body stays out of the prompt string's variable space: the doc path and slug are the
  only interpolations, since backticks/`$(…)` in an argv prompt run as commands (same rule as
  Claude above).

## Step 7: Report back

Tell the user:

- the session **name** to search for (Claude: in `/resume`; OpenCode: in `opencode session list`
  after `cd <worktree>`, or the TUI session picker)
- the worktree path and branch
- the resume command:
  - Claude: `cd <worktree> && claude --resume <SID>`
  - OpenCode: `cd <worktree> && opencode -s $(opencode session list | grep "<slug>" | cut -f1)`
    — or pick by name from the session list in the TUI
- that the new session appears in `ListAgents` once it boots, if the agent is Claude, so this
  session can `SendMessage` it

## Notes

- The new session groups under its own project in the picker (`<repo> · <branch>`), not under the
  one you launched from. The name is how you find it; the search box matches on it.
- The new session runs its own `SessionStart` hooks. Beans, branch-based renames and anything else
  hooked fire again there.
- OpenCode: a Stop-hook rename (if one is configured) replaces the seeded title after the first
  turn ends, so the `/resume`-searchable name can drift. The slug, the handoff doc filename and the
  branch name keep the link.
- `gwt co` runs the repo's setup hooks, including a dependency install. Expect it to take a moment.
