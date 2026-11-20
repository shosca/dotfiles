______________________________________________________________________

## name: herdr description: "Control Herdr, the desktop app for coding agents, and its herdr-core terminals. Use only when the user explicitly mentions Herdr or asks to inspect or control spaces, tabs, panes, terminals, or another agent. Do not use merely because a task could benefit from a background terminal, delegation, or parallel work."

# Herdr

Herdr has two binaries:

- `hc` (herdr-core) owns terminal processes (`start`, `read`, `send`, `keys`, `wait`, `get`, `list`,
  `kill`, `label`) and keeps them alive when the window closes. Every agent is an `hc` terminal, and
  your own address is `$HC_TERMINAL_ID` (not a pane ID).
- `herdr-app do` changes what the person sees: spaces, tabs, panes, and focus. Agents report `idle`,
  `working`, `done`, `blocked`, or `error`. The window shows that state.

## Check the session

```bash
test -n "${HC_TERMINAL_ID:-}"   # you run in a core terminal
herdr-app status                # the window is open
```

If the first check fails, report that you are not running in a Herdr terminal and stop.

## Learn the current CLI

Installed binaries are authoritative. Read their manuals before your first control command:

```bash
hc --skill          # terminals, agents, statuses, waiting
herdr-app --skill   # the window, spaces, tabs, panes, mods
herdr-app commands  # every app command with its arguments
hc <command> --help
```

Bare `herdr-app` opens the window, and bare `hc` opens a terminal picker. Run them only when asked.

## Read state

```bash
herdr-app ls     # spaces > tabs > terminals, with pane ids and terminal addresses
hc ls            # live terminals: cwd, program, name, turn
hc get <t>       # one terminal's full record, including status
```

Take IDs from this output. Never derive them from sidebar order.

## Show something the person asked for

```bash
herdr-app do space.new --name api --folder /path/to/api --focus false
herdr-app do tab.new --name "fix login" --space <space-id> --folder /path/to/api --argv '["claude"]' --task "Look at the login bug" --focus false
herdr-app do pane.split --direction right --pane <pane-id>
herdr-app do agent.focus --terminal <t>
```

`--argv` starts a program in the interactive shell. `--task` sends its first message. Name every
space and tab you create.

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

A send does not prove delivery. Read the screen before sending the same text again.

## Hidden workers

```bash
hc run --bg --name build cargo build --release
hc wait build
```

`hc run` starts a hidden terminal. Pass `--label herdr.space=<id>` and `--label herdr.tab=<id>` to
show it in the app.

## Safety

- Do not stop, signal, or restart the app or core. Closing the window does not end terminals.
- Close only spaces, tabs, and terminals you created, and only when asked (`space.close` and
  `tab.close` end their terminals).
- Pass `--confirmed true` only after the person agrees to end that work.
- A `blocked` session waits on the person. Read it, then ask. Do not type an answer.
- Do not automate pointer or key input on the person's screen.
- `idle` and `done` mean ready for input. Neither proves the agent finished the work.
