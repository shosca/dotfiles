---
name: split-work
description: Hand a plan worked out in this session to a fresh agent session in its own worktree and WezTerm window or Herdr pane. Use when planning is done and the implementation should run somewhere else, separately steerable. Triggers on "/split-work", "split this off", or "hand this to a new session".
allowed-tools: Bash(gwt:*), Bash(git:*), Bash(wezterm:*), Bash(herdr:*), Bash(uuidgen:*), Bash(opencode:*), Write, Read
---

# split-work

Turn a plan into a running peer session. The session gets a worktree, a handoff doc, a muxer location (WezTerm window or Herdr Space), and a name taken from the work.

The new session is a peer: its own terminal, its own permission prompts, its own hooks, and its own transcript. It is not a subagent. Do not spawn it through subagent tooling. You keep talking to it through its window, or over peer messaging once it registers as a peer in `ListAgents` (Claude only).

## What travels

The handoff doc, and nothing else. The new session starts cold apart from that file.

Do not copy this session's transcript into the new project directory. A `--fork-session` resume carries the whole conversation, including everything the new session has no use for, and buries the plan under it. A tight brief reads better and costs less.

## Prerequisites

Run every check below before any action. If a gate fails, you have created nothing yet: stop and say
so. The two probes pick the muxer, and both failing is the one stop they cause.

```bash
command -v gwt                     # gate: worktree helper
git rev-parse --show-toplevel      # gate: must be a repo
command -v claude                  # gate: resolve the agent from these two
command -v opencode
herdr status >/dev/null 2>&1       # probe: is the herdr server reachable?
wezterm cli list >/dev/null 2>&1   # probe: is this a WezTerm mux?
```

Pick the muxer in this order: herdr (server reachable over its socket), WezTerm, then stop and say so. The herdr CLI talks to the server socket even from a pane that is not herdr-managed, and it never uses UI focus. Everything below targets explicit IDs read from JSON responses. A herdr instance the user runs in parallel is a feature here, not a failure.

## Step 1: Settle the inputs

Nothing is created yet. Decide three values now, in this order.

**Agent.** Exactly one of `claude` / `opencode` on PATH is the agent. Reserve `$AGENT` for it and reuse it below. If both or neither are on PATH, ask the user once and remember the answer.

**Slug.** The slug names the work, not the directory: `drop-npx-from-agent-docs`, `report-query-counter`. Kebab-case, 3 to 5 words. One slug drives everything downstream: the branch, the worktree path, and the session name. Take it from the user's argument when they gave one. Otherwise propose one from the work, and confirm it before creating anything. A slug is hard to change afterwards: it is baked into the branch name, and the branch name cannot change once a PR is open.

On the herdr path, the slug also becomes the herdr agent name. It must then match `[a-z][a-z0-9_-]{0,31}`: lowercase kebab-case of at most 32 characters. Three to five words can pass that cap, so drop a word when the slug runs long. Lowercase everything and strip characters outside that set.

**Branch name.** The branch convention is declared by the repo, not by this skill. Read the repo's `CLAUDE.md`, `AGENTS.md`, or `CONTRIBUTING.md`, and follow what it declares. If no convention is documented, ask the user. Never invent a ticket key.

**Done:** `$AGENT`, `$SLUG`, and `$BRANCH` are decided and confirmed.

## Step 2: Create the worktree

```bash
command gwt co "$BRANCH"
WT=$(git worktree list --porcelain |
     awk -v b="refs/heads/$BRANCH" '/^worktree /{p=$2} $0=="branch "b{print p}')
```

Read the path back from `git worktree list` rather than parsing `gwt` output. Do not `cd` into it. This session stays where it is. When `$WT` is empty, stop: the lookup found no worktree for the branch, and every later step would run in the wrong directory.

Call the binary with `command gwt`, never bare `gwt`. The shell profile defines a `gwt` wrapper function that runs `cd` into the new worktree after the binary exits, and the agent's shell snapshot carries that function. The Bash tool keeps its working directory between calls, so the wrapper moves this session into the new worktree. `command` skips the function. The binary alone creates the worktree and runs its hooks, but changes no directory.

`gwt co` runs the repo's setup hooks, including a dependency install. Expect it to take a moment.

**Done:** `$WT` holds the new worktree path, and this session's working directory is unchanged.

## Step 3: Write the handoff doc

Write a document summarising the current conversation so a fresh agent can continue the work. Save it to the temporary directory of the user's OS ($TMPDIR, else /tmp), not the current workspace. Pass the absolute path in the launch prompt, since the new session's cwd is the worktree.

The doc carries what the code cannot say for itself:

```markdown
# <slug>

## Goal
One or two sentences. What is different when this is done.

## Decisions
Each choice that is already settled, with the reason. Include the approaches that were
rejected and why. That is the part the new session cannot re-derive from the code.

## Scope
The files and symbols in play, by path. Name them. Do not describe them.

## Out of scope
What to leave alone, and why. Be specific. This is the section that keeps the PR small.

## Done when
Verifiable criteria. A command that passes, a behavior that changes, a PR that exists.

## Gotchas
What we found the hard way: a hook that rewrites files, a flag that drops TZ, a fixture
that overwrites the field you set.

## After the PR is open
Run the `babysit-pr` skill on the PR. It owns the watch, the merge, and recovery from a failed
check. It runs one pass per prompt; ghpoll sends the next prompt when the PR changes, so do not
write a loop into this session. When a comment needs the user's judgment, or a reviewer asks for
changes you do not agree with, ask the user with your question tool and wait for the answer. Do
not end the turn to signal that you need the user. On a merge or a close, stop and run `teardown`.
```

Prose, not a transcript. Aim for one screen. Leave out the exploration that produced the plan.

Always include **After the PR is open**, as written. An open question puts the session in a waiting state the muxer can detect: herdr calls it `blocked`, and the rich-notifications plugin turns that into a desktop notification. That is the one channel that behaves the same for every agent; do not send a notification call of your own. A finished turn looks the same as a quiet check, so it never reaches the user. For Claude, the question tool is `AskUserQuestion`. For OpenCode, it is `question`.

**Done:** `$DOC` holds an absolute path, and the file exists.

## Step 4: Build the launch command

Only the WezTerm path uses `$LAUNCH`. On the herdr path, `herdr-dispatch` builds it from the task
line, so skip this step there.

### Claude

Claude accepts a caller-supplied stable session id and a display name. UUID5 over the branch name is stable: the same branch always yields the same id, and a resume needs no lookup. The id is the machine address. The name is what a human reads.

```bash
SID=$(uuidgen --sha1 -n @url -N "$BRANCH")
PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
if [ -f "$PROJDIR/$SID.jsonl" ]; then
  LAUNCH="claude --resume $SID"
else
  LAUNCH="claude --name $SLUG --session-id $SID \"Read $DOC and implement it.\""
fi
```

`--name` shows the name in the prompt box, the `/resume` picker, and the terminal title. No separate `wezterm cli set-window-title` call is needed.

### OpenCode

OpenCode generates its own session id, so you cannot pre-bake one. The name is what you anchor on, and it does not exist yet at launch, so make the new session name itself first.

```bash
LAUNCH="opencode --prompt 'Read $DOC and implement it. First, rename this session to $SLUG. You have the session_rename tool. Use it before anything else.'"
```

Sessions are directory-scoped. `opencode session list` inside the worktree shows the new session and its id once it has one. The server API has no rename endpoint, so the first-prompt instruction is the only headless way to set the name. If the session is already running and unnamed, the user can run `/rename` manually in the TUI.

### Prompt rules

The prompt is an argv string the shell expands: backticks and `$(...)` inside it run as commands. Keep identifiers out of the prompt. The handoff doc holds them. Interpolate only `$DOC` and `$SLUG`.

On the herdr path, keep the task line short: pane typing injection truncates at 1024 bytes
(herdr#2862), and a truncated command never runs. The handoff doc carries everything else.

**Done (WezTerm):** `$LAUNCH` is set for `$AGENT`.

## Step 5: Launch

### Strip the environment first

Every spawn below uses the same wrapper, which strips inherited identity variables before exec:

```bash
unset $(env | sed -n 's/^\(CLAUDE[A-Z_]*\|OPENCODE[A-Z_]*\)=.*/\1/p')
```

A spawn from inside a Claude Code tool call passes ten `CLAUDE*` variables to the child, and two break the new session outright:

- `CLAUDE_CODE_CHILD_SESSION` turns transcript saving off. The session runs but writes no `.jsonl`, so `--resume` and the `/resume` picker never find it. The printed warning is the only visible symptom.
- `CLAUDE_CODE_SESSION_ID`, `CLAUDE_CODE_MESSAGING_SOCKET`, and `CLAUDE_CODE_MESSAGING_TOKEN` carry the parent's identity and message channel. With them set, the new session does not register as a peer, so `ListAgents` does not see it and `SendMessage` cannot reach it.

Both facts were confirmed by spawning one session with the variables and one without. OpenCode leaks the parent's flags the same way: strip `OPENCODE_EXPERIMENTAL` and `OPENCODE_TERMINAL` for the same hygiene.

### WezTerm

```bash
wezterm cli spawn --new-window --cwd "$WT" \
  -- sh -c 'unset $(env | sed -n "s/^\(CLAUDE[A-Z_]*\|OPENCODE[A-Z_]*\)=.*/\1/p"); exec '"$LAUNCH"
```

**Done:** the new window's title shows the slug. `--name` set it.

### Herdr

Herdr already groups per repo, and `herdr worktree create` would put checkouts under
`~/.herdr/worktrees/<repo>/<branch-slug>`, past where gwt and the repo hooks manage them. So gwt
owns the disk and herdr hosts the seat: create the worktree with `gwt` (Step 2), then seat the
session with the `herdr-dispatch` skill.

Pass it four values:

    path=$WT
    name=$SLUG
    task=Read <doc path> and implement it.
    agent=$AGENT

Substitute the absolute path of `$DOC` for `<doc path>` before you dispatch. `herdr-dispatch`
forbids `$` in the task, and the launching shell expands it to nothing.

`herdr-dispatch` registers the Space, starts the agent, and reports the pane and its state. It owns
the launch rules: `wait-output` before `pane run`, a resume of the worktree's transcript, and the
`agent start` failure modes. Do not repeat them here, and do not run `worktree open`, `pane run` or
`agent start` yourself.

Skip Step 4 on this path. The task line replaces `$LAUNCH`.

**Done:** the skill reports a pane and an agent state, or it reports the pane whose agent did not
start.

## Step 6: Report back

Tell the user:

- the worktree path and branch
- the session **name** to search for (Claude: in `/resume`. OpenCode: in `opencode session list` after `cd <worktree>`, or the TUI session picker)
- that the new session appears in `ListAgents` once it boots if the agent is Claude, so this session can `SendMessage` it

On the WezTerm path:

- the resume command: Claude: `cd <worktree> && claude --resume <SID>`. OpenCode: `cd <worktree> && opencode -s $(opencode session list | grep "<slug>" | cut -f1 | head -1)`, or pick by name from the session list in the TUI

On the herdr path, instead:

- the Space and the pane id. `herdr agent list` finds the agent, and the sidebar groups it under the repo.
- how to prompt it later: `herdr agent prompt "$PANE" "..."`
- how to resume it: `herdr agent attach "$PANE"`, which takes over the pane. `herdr-dispatch` names the session `$SLUG`, so this is the name to look for.
- the pane, if `herdr agent get` still failed for it after about 90 seconds

## Notes

- The new session groups under its own project in the picker (`<repo> · <branch>`), not under the one you launched from. The name is how you find it: the search box matches on it.
- The new session runs its own `SessionStart` hooks. Beans, branch-based renames, and anything else hooked fire again there.
- OpenCode: a Stop-hook rename, if one is configured, replaces the seeded title after the first turn ends, so the `/resume`-searchable name can drift. The slug, the handoff doc filename, and the branch name keep the link. On the herdr path, herdr's own `herdr agent rename` can re-pin it.
- Herdr names: the agent name follows the pane occupant and clears when the agent exits or is replaced. Check `herdr agent get` before scripting against it.
- Deleting a Space is `herdr workspace close <id>`, never `git worktree remove`. The second deletes the checkout. Delete only a checkout that herdr created itself.
