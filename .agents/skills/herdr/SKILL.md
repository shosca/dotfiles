---
name: herdr
description: "Control Herdr, the desktop app for coding agents, and its herdr-core terminals. Use only when the user explicitly mentions Herdr or asks to inspect or control spaces, tabs, panes, terminals, or another agent. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work."
---

# Herdr

Herdr has two parts. The app (`herdr-app`) shows spaces, tabs and panes in a window.
herdr-core (`hc`) runs the terminals and keeps them alive when the window closes.
An agent reports `idle`, `working`, `done`, `blocked` or `error`; the app shows that state.

## Verify the session

```bash
test -n "${HC_TERMINAL_ID:-}"   # you run in a core terminal
herdr-app status                # the window is open
```

If the first check fails, say that you are not running in a Herdr terminal and stop.

## Learn the current CLI

The installed binaries are the authority. Read their manuals before the first control command:

```bash
hc --skill          # terminals, agents, statuses, waiting
herdr-app --skill   # the window, spaces, tabs, panes, mods
herdr-app commands  # every app command with its arguments
hc <command> --help
```

Bare `herdr-app` opens the window. Bare `hc` opens a terminal picker. Use these two
only when the person asked for that.

## Choose the binary

- `hc` owns processes: start, read, send, keys, wait, get, list, kill, label.
  Every agent is an hc terminal.
- `herdr-app do` changes what the person sees: spaces, tabs, panes, focus.

Your own address is `$HC_TERMINAL_ID`, not a pane id.

## Read state

```bash
herdr-app ls     # spaces > tabs > terminals, with pane ids and terminal addresses
hc ls            # live terminals: cwd, program, name, turn
hc get <t>       # one terminal's full record, including status
```

Take ids from this output. Do not derive them from sidebar order.

## Show something the person asked for

```bash
herdr-app do space.new --name api --folder /path/to/api
herdr-app do tab.new --name "fix login" --space <space-id> --folder /path/to/api --argv '["claude"]' --task "Look at the login bug"
herdr-app do pane.split --direction right --pane <pane-id>
herdr-app do agent.focus --terminal <t>
```

`--argv` starts a program in the person's interactive shell. `--task` sends its first message.
Name every space and tab you create.

## Work an agent

```bash
hc send <t> "Focus on the first bug"      # paste and Enter
hc send --if idle <t> "next step"         # only when it can take input
hc wait <t>                               # until it stops working or exits
hc wait <t> --timeout 60                  # a check-in; wait again after
hc read <t> --lines 120                   # screen plus history
hc read <t> --lines 0                     # visible screen only
hc keys <t> esc                           # answer a dialog
hc interrupt <t>                          # stop its turn, keep the process
```

A send is not proof of delivery. Read the screen before you send the same text again.

## Start a worker the window need not show

```bash
hc run --bg --name build cargo build --release
hc wait build
```

`hc run` starts a hidden terminal. Passing `--label herdr.space=<id>` and
`--label herdr.tab=<id>` makes the app show it.

## Safety

- Do not stop, signal or restart the app or the core. A closed window does not end terminals.
- Close only spaces, tabs and terminals you created, and only when the person asked.
  `space.close` and `tab.close` end their terminals.
- Pass `--confirmed true` only after the person agreed to end that work.
- A `blocked` session waits on the person. Read it, then ask; do not type an answer.
- Do not experiment with pointer or key automation on the person's display.
- `idle` and `done` mean ready for input. Neither proves the work is finished.
