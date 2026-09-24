---
name: split-work
description: Hand a plan worked out in this session to a fresh agent session (Claude or OpenCode) in its own worktree and its own WezTerm window or Herdr pane. Use when planning is done and the implementation should run somewhere else, separately steerable. Triggers on "/split-work", "split this off", "hand this to a new session", "open a window and work on this there".
allowed-tools: Bash(gwt:*) Bash(git:*) Bash(wezterm:*) Bash(herdr:*) Bash(uuidgen:*) Bash(opencode:*) Write Read
---

# split-work

Turn a plan into a running peer session: a worktree, a handoff doc, a muxer location (WezTerm
window or Herdr Space), and an agent session named after the work.

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
herdr status >/dev/null 2>&1   # herdr server reachable? use the herdr path
wezterm cli list >/dev/null    # fallback: you are inside a WezTerm mux
command -v gwt                 # worktree helper
git rev-parse --show-toplevel  # must be a repo
```

Detect the muxer in this order: herdr (server reachable over its socket), WezTerm, then stop and
say so. The `herdr` CLI talks to the server socket even from a pane that is not herdr-managed, and
it never uses UI focus — everything below targets explicit IDs read from JSON responses. A herdr
instance the user runs in parallel is a feature here, not a failure.

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

If the herdr path is taken, the slug also becomes the herdr agent name, so it must match
`[a-z][a-z0-9_-]{0,31}` — lowercase kebab-case of at most 32 characters. The 3-5 word rule already
fits; just lower-case everything and strip characters outside that set.

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

### WezTerm

#### Claude

Claude accepts a caller-supplied stable session id and a display name. UUID5 over the branch name
is stable: the same branch always yields the same id, and a resume needs no lookup. The id is the
machine address; the name is what a human reads.

```bash
SID=$(uuidgen --sha1 -n @url -N "$BRANCH")
PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
if [ -f "$PROJDIR/$SID.jsonl" ]; then
  LAUNCH="claude --resume $SID --permission-mode auto"
else
  LAUNCH="claude --name $SLUG --session-id $SID --permission-mode auto \"Read $DOC and implement it.\""
fi
wezterm cli spawn --new-window --cwd "$WT" \
  -- sh -c 'unset $(env | sed -n "s/^\(CLAUDE[A-Z_]*\|OPENCODE[A-Z_]*\)=.*/\1/p"); exec '"$LAUNCH"
```

CRITICAL: the prompt is an argv string the shell expands. Backticks and `$(…)` in it run as
commands. Keep identifiers out of the prompt — the doc holds them.

`--name` sets the display name in the prompt box, the `/resume` picker, and the terminal title. No
separate `wezterm cli set-window-title` call is needed.

`--permission-mode auto` starts the session in auto mode, so it works through the brief instead of
stopping at the first prompt for a command you would have approved anyway. It is a classifier, not
`bypassPermissions`: dangerous calls are still refused and escalated. It is per-session rather than
stored, so the resume branch passes it too. A `SessionStart` hook can still block before the mode
applies — if a hook's command prompts on every launch, an allow rule in settings is the fix, not a
mode.

#### OpenCode

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

### Herdr

Herdr already groups per repo; `worktree create` here would put checkouts under
`~/.herdr/worktrees/<repo>/<branch-slug>`, past where gwt and the repo hooks manage them. So gwt
owns the disk, herdr hosts the seat: create the worktree with gwt (Step 3), then register the
finished checkout with herdr.

`worktree open` must be anchored at the repo parent — running it from inside a linked worktree
fails with `linked_worktree_source`. Pass the root from Step 4 explicitly:

```bash
BARE=$(dirname "$(git rev-parse --git-common-dir)")
RESP=$(herdr worktree open --cwd "$BARE" --path "$WT" --label "$SLUG" \
             --no-focus --trust-repository)
WS_ID=$(printf '%s' "$RESP" | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["workspace"]["workspace_id"])')
PANE=$(printf '%s' "$RESP"  | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')
```

Read IDs out of the response; never guess them. Rerunning `worktree open` on an already-open
worktree is safe: `already_open` comes back true and the same workspace and root pane are returned,
so the check-then-open dance is unnecessary. `--label "$SLUG"` is the one human-facing name this
skill writes — the sidebar shows the slug; the branch appears there anyway via the group row.
`--trust-repository` silences git's other-user owner check for this command only; it does not
weaken any other check, and repos you don't own deliberately stay rejected.

Split is unnecessary: the workspace root pane boots with `cwd` already at the checkout and is an
available shell, so `agent start` can take it directly. Names: the agent name is the slug (it
matches the `[a-z][a-z0-9_-]{0,31}` rule from Step 1); the kind follows the agent resolved in
Step 0 (`claude` / `opencode` both ship as herdr kinds).

#### Claude

```bash
SID=$(uuidgen --sha1 -n @url -N "$BRANCH")
PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
if [ -f "$PROJDIR/$SID.jsonl" ]; then
  ARGS=(--resume "$SID" --permission-mode auto)
else
  ARGS=(--name "$SLUG" --session-id "$SID" --permission-mode auto "Read $DOC and implement it.")
fi
herdr agent start "$SLUG" --kind claude --pane "$PANE" -- "${ARGS[@]}"
```

`--permission-mode auto` is there for the same reason as on the WezTerm path above: the session
works through the brief rather than stopping at the first prompt. It does not cover a `SessionStart`
hook, which runs before the mode applies.

#### OpenCode

```bash
herdr agent start "$SLUG" --kind opencode --pane "$PANE" -- \
  --prompt "Read '$DOC' and implement it. First, rename this session to '$SLUG'. You have the
  session_rename tool — use it before anything else."
```

Notes:

- `agent start` returns only once herdr detects the agent and considers it ready; on
  `agent_not_ready` the name is kept and `herdr agent get "$SLUG"` / `herdr agent read "$SLUG"`
  still work — wait instead of relaunching, a second `agent start` on the same pane errors.
- The env strip from Step 5 still wraps the call for hygiene; the pane process itself is spawned by
  the herdr server, so the child does not inherit this shell's `CLAUDE*`/`OPENCODE*` variables
  directly, but stripping keeps the herdr CLI call itself clean.
- State check and idle-wait: `herdr agent get "$SLUG"` (states `idle`, `working`, `blocked`,
  `done`, `unknown`); `herdr agent prompt` and `herdr agent send-keys` drive it later.
- Resume for Claude: run `claude --resume "$SID"` inside the pane (or `herdr agent attach`). For
  OpenCode, resume by session id from `opencode session list` inside the worktree.

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

On the herdr path, additionally:

- the Space and agent name (`herdr agent list` finds it; the sidebar groups it under the repo)
- nudge or prompt it later by name: `herdr agent prompt "$SLUG" "..."`
- resume via `herdr agent attach "$SLUG"` (takes over the pane) or the per-agent resume commands
  above

## Notes

- The new session groups under its own project in the picker (`<repo> · <branch>`), not under the
  one you launched from. The name is how you find it; the search box matches on it.
- The new session runs its own `SessionStart` hooks. Beans, branch-based renames and anything else
  hooked fire again there.
- OpenCode: a Stop-hook rename (if one is configured) replaces the seeded title after the first
  turn ends, so the `/resume`-searchable name can drift. The slug, the handoff doc filename and the
  branch name keep the link. On the herdr path herdr's own `herdr agent rename` can re-pin it.
- Herdr names: the agent name follows the pane occupant and clears when the agent exits or is
  replaced — verify with `herdr agent get` before scripting against it. Deleting a Space is
  `herdr workspace close <id>` (never `worktree remove` — that deletes the checkout and only herdr
  workspaces it created itself are safe targets).
- `herdr` general rule: only one human-facing label touches this skill (`--label "$SLUG"`); every
  identifier is parsed out of a JSON response, and herdr panes/rows that predate the grouping can
  stay standalone without breaking anything newer.
- `gwt co` runs the repo's setup hooks, including a dependency install. Expect it to take a moment.
