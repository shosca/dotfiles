---
name: herdr-dispatch
description: Seat an agent session in an existing git checkout inside a herdr Space. Use when a skill or a poller must start a fresh agent on a worktree that already exists, such as a PR reviewer, a review cleanup, or a handoff session.
allowed-tools: Bash(herdr:*), Bash(git:*), Bash(claude:*), Bash(opencode:*), Bash(ls:*), Bash(python3:*), Bash(sleep:*), Read
---

# herdr-dispatch

Start one agent in a checkout that already exists. Creating the checkout is not this skill's job:
the caller creates it first, with whatever tool it uses.

## Inputs

Pass all four values as text:

    path=/path/to/repo/pr-17121
    name=pr-17121-review
    task=/review-pr 17121
    agent=claude

- `path` is the checkout. The caller creates it; this skill never does.
- `name` matches `[a-z][a-z0-9_-]{0,31}`. It comes from the work, not from the path.
- `task` is the first prompt. One line. No `$`, backticks or quotes: `pane run` types it into a
  shell.
- `agent` is `claude` or `opencode`. The caller decides; do not ask.

## Steps

Map the inputs to shell variables first: `WT` from `path`, `NAME` from `name`, `TASK` from
`task`, `AGENT` from `agent`. Never use a variable named `PATH`: the shell needs it.

1. Check herdr and the checkout, and find the repo root:

   ```bash
   herdr status >/dev/null 2>&1 || { echo "herdr server not reachable"; exit 1; }
   git -C "$WT" rev-parse --is-inside-work-tree
   BARE=$(dirname "$(git -C "$WT" rev-parse --path-format=absolute --git-common-dir)")
   ```

2. Register the checkout as a Space and read its root pane. On a Space that is already open this
   returns `already_open` with the same pane.

   ```bash
   RESP=$(herdr worktree open --cwd "$BARE" --path "$WT" --label "$NAME" \
            --no-focus --trust-repository)
   PANE=$(printf '%s' "$RESP" | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])')
   ```

3. Stop when an agent already runs there. This skill starts cold sessions only.

   ```bash
   herdr agent get "$PANE" >/dev/null 2>&1 && { echo "agent already live on $PANE"; exit 0; }
   ```

4. Build the launch. Resume the worktree's transcript when one exists; otherwise start a new
   session. Either way the session carries `$NAME`.

   ```bash
   PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
   if ls "$PROJDIR"/*.jsonl >/dev/null 2>&1; then
     FLAGS="--continue"
   else
     FLAGS=""
   fi
   LAUNCH="claude $FLAGS --name $NAME \"$TASK\""
   ```

   For OpenCode: `LAUNCH="opencode --prompt '$TASK. First, rename this session to $NAME.'"`.
   Keep the line under 1024 bytes: a longer prompt is truncated and never runs.

5. Wait for the shell prompt, then type the launch. If the wait times out, send it anyway: zsh
   reads typed-ahead input.

   ```bash
   herdr pane wait-output "$PANE" --match '❯' --lines 3 --timeout 30000
   herdr pane run "$PANE" "$LAUNCH"
   ```

6. Poll for the agent. The `SessionStart` hook registers it.

   ```bash
   for _ in {1..18}; do herdr agent get "$PANE" >/dev/null 2>&1 && break; sleep 5; done
   herdr agent get "$PANE"
   ```

## Rules

- Never send the command twice. The first one may still be starting, and a second runs after it
  exits.
- Do not use `herdr agent start`: it rejects a pane still running zsh startup and times out on
  agents that did start.
- No environment strip is needed. `pane run` types into a shell the herdr server spawned.
- A Space a hook already opened keeps the label that hook gave it, not `$NAME`. The agent carries
  `$NAME`. Report both, and do not claim they share a name.
- When `agent get` still fails after the poll, report the pane and stop. The poll covers about 90
  seconds, because a Claude boot with `SessionStart` hooks outlasts the 30 seconds that `agent
  start` allows.

## Report

One line: pane id, agent name and state. `herdr agent get` prints the workspace id with them. On
failure, the step that failed and its output.
