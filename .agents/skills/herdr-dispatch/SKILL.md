______________________________________________________________________

## name: herdr-dispatch description: Seat an agent session in an existing git checkout inside a herdr-app space. Use when a skill or poller must start a fresh agent on an existing worktree, such as a PR reviewer or handoff session. allowed-tools: Bash(herdr-app:*), Bash(hc:*), Bash(git:*), Bash(claude:*), Bash(opencode:*), Bash(ls:*), Bash(python3:*), Bash(sleep:*), Read

# herdr-dispatch

Start one cold agent session in an existing git checkout.

## Inputs

Pass all four values as text:

```text
path=/path/to/repo/pr-17121
name=pr-17121-review
task=/review-pr 17121
agent=claude
```

- `path`: existing checkout directory. The caller creates it before invoking this skill.
- `name`: tab name matching `[a-z][a-z0-9_-]{0,31}`, named after the work rather than the path.
- `task`: one-line first message (a newline submits early). The handoff doc holds everything else.
- `agent`: `claude` or `opencode`. Use the caller's choice without asking.

## Steps

Map inputs to shell variables first: `WT` from `path`, `NAME` from `name`, `TASK` from `task`,
`AGENT` from `agent`. Never overwrite `PATH`.

Load these helpers to read live Herdr state:

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

1. Check the Herdr window and the checkout:

   ```bash
   herdr-app status >/dev/null 2>&1 || { echo "herdr-app window not reachable"; exit 1; }
   git -C "$WT" rev-parse --is-inside-work-tree
   ```

1. Stop if an agent already runs on that checkout or tab name:

   ```bash
   found=$(agent_on "$WT" "$NAME")
   [ -z "$found" ] || { echo "agent already live: $found"; exit 0; }
   ```

1. Build `ARGV`. Resume an existing Claude transcript when one exists, or start a new session:

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

1. Find the checkout's space, or create one with `--tab --argv --task` (so no stray empty shell tab
   remains), then start the tab:

   ```bash
   sid=$(space_for "$WT")
   if [ -z "$sid" ]; then
     herdr-app do space.new --name "$NAME" --folder "$WT" --tab "$NAME" --argv "$ARGV" --task "$TASK" --focus false >/dev/null
     sid=$(space_for "$WT")
     started=1
   fi
   [ -n "$sid" ] || { echo "no space for $WT"; exit 1; }
   if [ -z "$started" ]; then
     herdr-app do tab.new --space "$sid" --name "$NAME" --folder "$WT" --argv "$ARGV" --task "$TASK" --focus false
   fi
   ```

1. Poll up to 90 seconds for the terminal, then read its status:

   ```bash
   for _ in {1..18}; do
     t=$(herdr-app ls | python3 -c 'import json,sys
   ```

for s in json.load(sys.stdin)\["spaces"\]:
for tab in s\["tabs"\]:
if tab["name"] == sys.argv\[1\]:
for x in tab\["terminals"\]:
print(x["terminal"]); raise SystemExit' "$NAME")
[ -n "$t" ] && break
sleep 5
done
hc get "$t"

```

## Rules

- Never send `$TASK` twice. `space.new` and `tab.new` deliver it automatically. If `hc get` reports
`first_message: {sent: false}`, read the screen first, then send it once.
- Do not strip agent env vars. `space.new` and `tab.new` start `argv` in the user's interactive
shell, so parent agent variables do not leak.
- Always pass `--focus false` to `space.new` and `tab.new` so the app does not steal focus.
- An existing space keeps its original name while the new tab uses `$NAME`. Report both accurately.
- If no terminal appears after 90 seconds, stop and report the space (the tab may hold an error
toast with the failure).

## Report

Return one line with space id, tab name, terminal address, and status. On failure, report the failed
step and its output.
```
