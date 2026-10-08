---
name: split-work
description: Hand a plan worked out in this session to a fresh agent session in its own worktree and WezTerm window or Herdr pane. Use when planning is done and the implementation should run somewhere else, separately steerable. Triggers on "/split-work", "split this off", or "hand this to a new session".
allowed-tools: Bash(gwt:*) Bash(git:*) Bash(wezterm:*) Bash(herdr:*) Bash(uuidgen:*) Bash(opencode:*) Write Read
---

# split-work

Turn a plan into a running peer session. The session gets a worktree, a handoff doc, a muxer location (WezTerm window or Herdr Space), and a name taken from the work.

The new session is a peer: its own terminal, its own permission prompts, its own hooks, and its own transcript. It is not a subagent. Do not spawn it through subagent tooling. You keep talking to it through its window, or over peer messaging once it registers as a peer in `ListAgents` (Claude only).

## What travels

The handoff doc, and nothing else. The new session starts cold apart from that file.

Do not copy this session's transcript into the new project directory. A `--fork-session` resume carries the whole conversation, including everything the new session has no use for, and buries the plan under it. A tight brief reads better and costs less.

## Prerequisites

Run every check below before any action. If a gate fails, you have created nothing yet: stop and say so, or fall back as noted.

```bash
herdr status >/dev/null 2>&1   # herdr server reachable? use the herdr path
wezterm cli list >/dev/null    # fallback: you are inside a WezTerm mux
command -v gwt                 # worktree helper
git rev-parse --show-toplevel  # must be a repo
command -v claude              # resolve the agent from these two
command -v opencode
```

Pick the muxer in this order: herdr (server reachable over its socket), WezTerm, then stop and say so. The herdr CLI talks to the server socket even from a pane that is not herdr-managed, and it never uses UI focus. Everything below targets explicit IDs read from JSON responses. A herdr instance the user runs in parallel is a feature here, not a failure.

## Step 1: Settle the inputs

Nothing is created yet. Decide three values now, in this order.

**Agent.** Exactly one of `claude` / `opencode` on PATH is the agent. Reserve `$AGENT` for it and reuse it below. If both or neither are on PATH, ask the user once and remember the answer.

**Slug.** The slug names the work, not the directory: `drop-npx-from-agent-docs`, `report-query-counter`. Kebab-case, 3 to 5 words. One slug drives everything downstream: the branch, the worktree path, and the session name. Take it from the user's argument when they gave one. Otherwise propose one from the work, and confirm it before creating anything. A slug is hard to change afterwards: it is baked into the branch name, and the branch name cannot change once a PR is open.

On the herdr path, the slug also becomes the herdr agent name. It must then match `[a-z][a-z0-9_-]{0,31}`: lowercase kebab-case of at most 32 characters. The 3 to 5 word rule already fits. Lowercase everything and strip characters outside that set.

**Branch name.** The branch convention is declared by the repo, not by this skill. Read the repo's `CLAUDE.md`, `AGENTS.md`, or `CONTRIBUTING.md`, and follow what it declares. If no convention is documented, ask the user. Never invent a ticket key.

**Done:** `$AGENT`, `$SLUG`, and `$BRANCH` are decided and confirmed.

## Step 2: Create the worktree

```bash
command gwt co "$BRANCH"
WT=$(git worktree list --porcelain |
     awk -v b="refs/heads/$BRANCH" '/^worktree /{p=$2} $0=="branch "b{print p}')
```

Read the path back from `git worktree list` rather than parsing `gwt` output. Do not `cd` into it. This session stays where it is.

Call the binary with `command gwt`, never bare `gwt`. The shell profile defines a `gwt` wrapper function that runs `cd` into the new worktree after the binary exits, and the agent's shell snapshot carries that function. The Bash tool keeps its working directory between calls, so the wrapper moves this session into the new worktree. `command` skips the function. The binary alone creates the worktree and runs its hooks, but changes no directory.

`gwt co` runs the repo's setup hooks, including a dependency install. Expect it to take a moment.

**Done:** `$WT` holds the new worktree path, and this session's working directory is unchanged.

## Step 3: Write the handoff doc

Write a document summarising the current conversation so a fresh agent can continue the work. Save it to the temporary directory of the user's OS ($TMPDIR, else /tmp, or %TEMP% on Windows), not the current workspace. Pass the absolute path in the launch prompt, since the new session's cwd is the worktree.

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
```

Prose, not a transcript. Aim for one screen. Leave out the exploration that produced the plan.

**Done:** `$DOC` holds an absolute path, and the file exists.

## Step 4: Build the launch command

Step 5 places `$LAUNCH` on either muxer, so build it here for `$AGENT`.

### Claude

Claude accepts a caller-supplied stable session id and a display name. UUID5 over the branch name is stable: the same branch always yields the same id, and a resume needs no lookup. The id is the machine address. The name is what a human reads.

```bash
SID=$(uuidgen --sha1 -n @url -N "$BRANCH")
PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
if [ -f "$PROJDIR/$SID.jsonl" ]; then
  LAUNCH="claude --resume $SID --permission-mode auto"
else
  LAUNCH="claude --name $SLUG --session-id $SID --permission-mode auto \"Read $DOC and implement it.\""
fi
```

`--name` shows the name in the prompt box, the `/resume` picker, and the terminal title. No separate `wezterm cli set-window-title` call is needed.

`--permission-mode auto` starts the session in auto mode, so it works through the brief. It does not stop at the first prompt for a command you would have approved anyway. It is a classifier, not `bypassPermissions`. Dangerous calls are still refused and escalated. It is per-session rather than stored, so the resume branch passes it too. A `SessionStart` hook can still block before the mode applies. If a hook's command prompts on every launch, an allow rule in settings is the fix, not a mode.

### OpenCode

OpenCode generates its own session id, so you cannot pre-bake one. The name is what you anchor on, and it does not exist yet at launch, so make the new session name itself first.

```bash
LAUNCH="opencode --prompt 'Read $DOC and implement it. First, rename this session to $SLUG. You have the session_rename tool. Use it before anything else.'"
```

Sessions are directory-scoped. `opencode session list` inside the worktree shows the new session and its id once it has one. The server API has no rename endpoint, so the first-prompt instruction is the only headless way to set the name. If the session is already running and unnamed, the user can run `/rename` manually in the TUI.

### Prompt rules

The prompt is an argv string the shell expands: backticks and `$(...)` inside it run as commands. Keep identifiers out of the prompt. The handoff doc holds them. Interpolate only `$DOC` and `$SLUG`.

On the herdr path, also keep `$LAUNCH` short. Pane typing injection truncates at 1024 bytes (herdr#2862), and the truncated command never runs. The handoff doc carries everything else.

**Done:** `$LAUNCH` is set for `$AGENT`.

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

Herdr already groups per repo, and `herdr worktree create` would put checkouts under `~/.herdr/worktrees/<repo>/<branch-slug>`, past where gwt and the repo hooks manage them. So gwt owns the disk and herdr hosts the seat: create the worktree with `gwt` (Step 2), then register the finished checkout here.

`herdr worktree open` must be anchored at the repo parent. Running it from inside a linked worktree fails with `linked_worktree_source`, so pass the root explicitly:

```bash
BARE=$(dirname "$(git rev-parse --git-common-dir)")
RESP=$(herdr worktree open --cwd "$BARE" --path "$WT" --label "$SLUG" \
             --no-focus --trust-repository)
WS_ID=$(printf '%s' "$RESP" | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["workspace"]["workspace_id"])')
PANE=$(printf '%s' "$RESP"  | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')
```

Read IDs out of the response, and never guess them. Rerunning `worktree open` on an already-open worktree returns `already_open` true with the same workspace and root pane, so the check-then-open dance is unnecessary. `--label "$SLUG"` is the one human-facing name this skill writes: the sidebar shows the slug, and the branch appears there anyway via the group row. `--trust-repository` silences git's other-user owner check for this command only. It does not weaken any other check, and repos you do not own stay rejected. Herdr panes or rows that predate this grouping can stay standalone. Nothing newer breaks.

No pane split and no `herdr agent start`. The workspace root pane boots with `cwd` already at the checkout. Type the launch command into its shell with `pane run`, after `wait-output` sees the prompt:

```bash
herdr pane wait-output "$PANE" --match '❯' --lines 3 --timeout 30000
herdr pane run "$PANE" "$LAUNCH"
```

Do not use `herdr agent start`. On 0.9.1 it fails in two ways, and this skill hit both:

- It rejects a pane that is still running zsh startup (keychain, direnv, mise) with `agent_pane_busy`, and `worktree open` returns before that startup ends. `pane get` returns the same output before and after the shell is ready, so you cannot poll for it ([herdr#3208](https://github.com/herdrdev/herdr/issues/3208)).
- It waits only 30 seconds for the agent to become ready, and a Claude boot with `SessionStart` hooks takes longer. It then reports `timed out waiting for agent startup` for an agent that did start.

Notes:

- If `wait-output` times out, send the command anyway. zsh reads typed-ahead input once the prompt appears.
- About 30 seconds after `pane run`, check the pane with `herdr agent get "$PANE"`. States are `idle`, `working`, `blocked`, `done`, and `unknown`. If it still fails, report the pane to the user. **Never send the command a second time.** The first one may still be starting, and a second one runs after the first exits.
- No env strip is needed here. `pane run` types into a shell that the herdr server spawned, so that shell does not inherit this session's `CLAUDE*`/`OPENCODE*` variables.
- Keep `$LAUNCH` short (see the prompt rules in Step 4, herdr#2862).
- Drive the agent later with `herdr agent prompt` or `herdr agent send-keys`, and target it by pane id.

The herdr `SessionStart` hook registers the agent. The agent's name comes from the terminal title, which `--name` and the slug set, so the slug must match the rule from Step 1.

**Done:** `herdr agent get "$PANE"` returns a state, or the pane is reported to the user.

## Step 6: Report back

Tell the user:

- the session **name** to search for (Claude: in `/resume`. OpenCode: in `opencode session list` after `cd <worktree>`, or the TUI session picker)
- the worktree path and branch
- the resume command: Claude: `cd <worktree> && claude --resume <SID>`. OpenCode: `cd <worktree> && opencode -s $(opencode session list | grep "<slug>" | cut -f1)`, or pick by name from the session list in the TUI
- that the new session appears in `ListAgents` once it boots if the agent is Claude, so this session can `SendMessage` it

On the herdr path, additionally:

- the Space and the pane id. `herdr agent list` finds the agent, and the sidebar groups it under the repo.
- how to prompt it later: `herdr agent prompt "$PANE" "..."`
- how to resume it: `herdr agent attach "$PANE"`, which takes over the pane, or the per-agent resume commands above
- the pane, if `herdr agent get` still failed for it after about 30 seconds

## Notes

- The new session groups under its own project in the picker (`<repo> · <branch>`), not under the one you launched from. The name is how you find it: the search box matches on it.
- The new session runs its own `SessionStart` hooks. Beans, branch-based renames, and anything else hooked fire again there.
- OpenCode: a Stop-hook rename, if one is configured, replaces the seeded title after the first turn ends, so the `/resume`-searchable name can drift. The slug, the handoff doc filename, and the branch name keep the link. On the herdr path, herdr's own `herdr agent rename` can re-pin it.
- Herdr names: the agent name follows the pane occupant and clears when the agent exits or is replaced. Check `herdr agent get` before scripting against it.
- Deleting a Space is `herdr workspace close <id>`, never `worktree remove`: that deletes the checkout, and only herdr workspaces it created itself are safe targets.
