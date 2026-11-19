---
name: herdr-dispatch
description: Seat an agent session in an existing git checkout inside a herdr-app space. Use when a skill or a poller must start a fresh agent on a worktree that already exists, such as a PR reviewer, a review cleanup, or a handoff session.
allowed-tools: Bash(herdr-app:*), Bash(hc:*), Bash(git:*), Bash(claude:*), Bash(opencode:*), Bash(ls:*), Bash(python3:*), Bash(sleep:*), Read
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
- `name` is the tab name. It matches `[a-z][a-z0-9_-]{0,31}` and comes from the work, not from
  the path.
- `task` is the first message. One line. The handoff doc carries everything else.
- `agent` is `claude` or `opencode`. The caller decides; do not ask.

## Steps

Map the inputs to shell variables first: `WT` from `path`, `NAME` from `name`, `TASK` from
`task`, `AGENT` from `agent`. Never use a variable named `PATH`: the shell needs it.

These helpers read the app's live state. Run them as written.

```bash
space_for() {
  herdr-app ls | python3 -c 'import json,sys
wt = sys.argv[1].rstrip("/")
print(next((s["id"] for s in json.load(sys.stdin)["spaces"]
            if (s.get("folder") or "").rstrip("/") == wt), ""))' "$@"
}

agent_on() {
  herdr-app ls | python3 -c 'import json,sys
wt, name = sys.argv[1].rstrip("/"), sys.argv[2]
for s in json.load(sys.stdin)["spaces"]:
    for tab in s["tabs"]:
        for t in tab["terminals"]:
            if t["status"] and ((s.get("folder") or "").rstrip("/") == wt or tab["name"] == name):
                print(t["terminal"], t["status"])' "$@"
}
```

1. Check the window and the checkout:

   ```bash
   herdr-app status >/dev/null 2>&1 || { echo "herdr-app window not reachable"; exit 1; }
   git -C "$WT" rev-parse --is-inside-work-tree
   ```

2. Stop when an agent already reports there. This skill starts cold sessions only.

   ```bash
   found=$(agent_on "$WT" "$NAME")
   [ -z "$found" ] || { echo "agent already live: $found"; exit 0; }
   ```

3. Build the launch. Resume the worktree's transcript when one exists; otherwise start a new
   session. Either way the tab carries `$NAME`.

   ```bash
   PROJDIR=~/.claude/projects/$(printf %s "$WT" | tr / -)
   if [ "$AGENT" = claude ]; then
     if ls "$PROJDIR"/*.jsonl >/dev/null 2>&1; then
       ARGV='["claude","--continue"]'
     else
       ARGV=$(python3 -c 'import json,sys; print(json.dumps(["claude","--name",sys.argv[1]]))' "$NAME")
     fi
   else
     ARGV='["opencode"]'
     TASK="Read $TASK and implement it. First, rename this session to $NAME. You have the session_rename tool. Use it before anything else."
   fi
   ```

4. Find the space that holds the checkout, and start the tab in it:

   ```bash
   sid=$(space_for "$WT")
   if [ -z "$sid" ]; then
     # The space's first tab is the agent: space.new takes the argv and the task,
     # so no empty shell tab is left behind.
     herdr-app do space.new --name "$NAME" --folder "$WT" --tab "$NAME" --argv "$ARGV" --task "$TASK" --focus false >/dev/null
     sid=$(space_for "$WT")
     started=1
   fi
   [ -n "$sid" ] || { echo "no space for $WT"; exit 1; }
   if [ -z "$started" ]; then
     herdr-app do tab.new --space "$sid" --name "$NAME" --folder "$WT" --argv "$ARGV" --task "$TASK" --focus false
   fi
   ```

5. Poll for the terminal, then read its status:

   ```bash
   for _ in {1..18}; do
     t=$(herdr-app ls | python3 -c 'import json,sys
for s in json.load(sys.stdin)["spaces"]:
    for tab in s["tabs"]:
        if tab["name"] == sys.argv[1]:
            for x in tab["terminals"]:
                print(x["terminal"]); raise SystemExit' "$NAME")
     [ -n "$t" ] && break
     sleep 5
   done
   hc get "$t"
   ```

## Rules

- Never send the task twice. `tab.new` or `space.new` delivers it, and a duplicate runs a
  second turn. When `hc get` reports `first_message: {sent: false}`, read the screen first,
  then send once.
- `tab.new` and `space.new --argv` run argv in the person's interactive shell, with that
  shell's environment. No environment strip is needed, because the caller's agent variables
  do not reach it.
- Create the space with `--tab --argv --task` when it is missing. A bare `space.new` leaves an
  empty shell tab in the space, and it stays after the agent exits.
- Keep `$TASK` to one line. A newline can submit the message early.
- Pass `--focus false` to `space.new` and `tab.new`. Both take the focus by default, which
  moves the person out of what they were working on.
- A space that an earlier command created keeps its name, not `$NAME`. The tab carries `$NAME`.
  Report both, and do not claim they share a name.
- If no terminal appears after about 90 seconds, report the space and stop. The tab may show an
  error toast with the launch failure.

## Report

One line: space id, tab name, terminal address, status. On failure, the step that failed and its
output.
