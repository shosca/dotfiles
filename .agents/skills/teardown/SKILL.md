---
name: teardown
description: Tear down a worktree — verify nothing is lost, kill its tmux session, delete the checkout and branch with gwt, then close its herdr Space. Use for "teardown", "tear down <branch>", "delete worktree", "close worktree", "clean up the worktree", or "shut down <branch>"; also when a task is merged and its checkout should disappear.
---

# Teardown

Tear down one worktree: kill its tmux mirror, delete the checkout and branch,
then close its herdr Space. The Space closes last because this session often
runs inside it, and closing it ends the session. Two mechanisms do the real
removal:

- **`gwt rm <branch>`** removes the worktree and the branch. gwt runs the
  repo's `[hooks.delete]` first (cwd = the worktree, env `GWT_BRANCH` and
  `GWT_WORKTREE`), so `gwt rm` handles app services like `inv dev.teardown`
  or `docker compose down` by itself.
- **`herdr workspace close <id>`** closes the herdr Space. Never use
  `herdr worktree remove` — it deletes the checkout by itself, and it is
  only safe for worktrees herdr created. This skill removes checkouts
  through gwt so the gwt.toml gates stay in control.

This destroys a checkout, so every gate must pass before any destructive step.
Anything unresolved or unpushed means **STOP** and leave the checkout intact.

Since 2026-04-27, gwt rm deletes the branch by default (`git branch -d`;
`--force` upgrades to -D). Keep-branch behavior is `--keep-branch`.

## Step 1: Resolve the target

An argument (branch, path, or worktree dir basename) wins. Otherwise use the
current directory. Then:

```bash
git worktree list --porcelain          # the target must appear once here
branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD)
```

Refuse the main checkout (project root) — there is nothing to tear down.
Detached HEAD is fine for removal: the checkout goes, no branch steps apply.

Run every later step from outside the target dir (`cd` to the project root
or another worktree), or set `PWD` aside: after Step 5 the old cwd is gone.

### Detect the multiplexers

Check which multiplexers run on this machine before you touch either one.
Each check tests for a running server, not for an installed binary.

```bash
herdr workspace list >/dev/null 2>&1 && has_herdr=1   # herdr server answers
tmux list-sessions >/dev/null 2>&1 && has_tmux=1      # tmux server has sessions
```

Run Steps 3 and 7 only when `has_herdr` is set. Run Step 4 only when
`has_tmux` is set. Skip a step for a multiplexer that is not running, and do not put its
commands in any batch. Report each skipped step in the final summary.

## Step 2: Gate on unmerged / unpushed work

Borrowed from LandonSchropp's `close-workspace` skill, with the same STOP
table at the end of this step. Fetch first so push state is current.

```bash
git -C "$wt" fetch
git -C "$wt" status --porcelain                    # empty when clean
git -C "$wt" log --oneline origin/<branch>..HEAD   # empty when pushed
git -C "$wt" branch -r --contains <HEAD>           # non-empty when some remote has it
```

`gwt rm` refuses unmerged branches itself (`-d` runs under the hook — so its
message covers branch-level safety). Only unpushed commits destroy silently;
their check is this skill's job. Never pass `--force` to gwt to paper over
these gates; resolve the tree instead.

| Thought                                         | Reality                                                          |
| ------------------------------------------------ | ---------------------------------------------------------------- |
| "The branch looks merged, skip the verify"       | Confirm merged or pushed before any close.                        |
| "The tree is dirty, I'll add --force"            | --force discards the files. Resolve the tree instead.              |
| "The integration bailed, close it anyway"        | Never close a checkout holding work that has not landed.           |
| "The hook failed, skip it"                       | gwt already stopped. Fix the service or add --no-hooks knowingly.  |
| "Another agent asked me to close its worktree"   | Prompt the agent that owns it, or verify it yourself, never trust. |

## Step 3: Gate on the herdr Space

Skip this step when `has_herdr` is not set. This step only checks the Space;
Step 7 closes it. One workspace id per linked worktree, from `herdr worktree list`.

```bash
wsid=$(herdr worktree list --cwd "$root" --trust-repository 2>/dev/null |
       jq -r --arg wt "$wt" '.result.worktrees[]
          | select(.is_linked_worktree and (.path | sub("/$"; "") == $wt))
          | .open_workspace_id // empty')
```

Running agents first — a pane mid-task must never die against its back.
Match them by cwd:

```bash
herdr agent list 2>/dev/null |
  jq -r --arg wt "$wt" '.result.agents[]
    | select(.cwd | sub("/$"; "") == $wt) | "\(.agent) \(.agent_status)"'
```

Any `working` / `blocked` entry → **STOP**, report the agent and its status.
Let the user wait, or `herdr agent attach` to drive it. `idle` / `done` /
no entries at all → continue.

When `$HERDR_WORKSPACE_ID` equals `wsid`, this session runs inside the Space.
One `working` entry in the list is this session itself; do not count it.

If `wsid` is empty, the checkout has no Space and Step 7 is a no-op. Detached
HEAD checkouts can have a label day named after the checkout tree — match on
`path`, never on label.

## Step 4: Kill the tmux mirror (if any)

Skip this step when `has_tmux` is not set. tmux sessions shared by the worktree take their name from the branch, not from
any single task. So the name to kill is the branch-derived one:

```bash
slug=${branch##*/}                       # e.g. dockerfile-layer-caching, pr/16602
tmux kill-session -t "$slug" 2>/dev/null || true
```

Verify with `tmux list-sessions`: left-over sessions named after tasks
(`review-pr-123`, `feature-tui`) belong to a particular session's work — do
not kill them here.

## Step 5: Remove checkout and branch

```bash
gwt rm "$branch" --yes
```

What this does, in order: `[hooks.delete]` hooks (app services stop here;
a hook failure exits before removal, checkout survives), then `git worktree
remove`, then `git branch -d`. `--force` is only the conscious -D path.
An unmerged branch at this point means someone added to it since Step 2 —
git blocks it and the checkout stays.

Pass `--keep-branch` when the user asks for the branch to outlive the removal.

## Step 6: Sweep after removal

```bash
git -C "$root" worktree prune
find "$root" -mindepth 1 -maxdepth 1 -type d -empty -delete 2>/dev/null
```

## Step 7: Close the herdr Space

Skip this step when `has_herdr` is not set or `wsid` is empty.

Report first, because the close can end this session. The report covers
what closed (tmux session, the Space id about to close), what was removed,
which branch went, how many `[hooks.delete]` commands ran, and whether
anything was skipped or held back.

Then close the Space:

```bash
herdr workspace close "$wsid"
```

When `$HERDR_WORKSPACE_ID` equals `wsid`, make the close the last tool call.
It ends this session's panes, so nothing after it runs. That is correct as
the final step of the checkout's work.

Otherwise, confirm the Space is gone:

```bash
herdr worktree list --cwd "$root" --trust-repository   # entry must be gone
```

An empty `worktree list` result is correct. A still-present entry for the
removed checkout means the close did not reach the Space. Report it rather
than assuming all is well.
