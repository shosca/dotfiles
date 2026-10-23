---
name: teardown
description: Tear down a worktree — verify nothing is lost, delete the checkout and branch with gwt, then close its herdr Space. Triggers on "teardown", "delete/close this worktree", "shut down <branch>", or a merged task whose checkout should go.
---

# Teardown

Tear down one worktree: delete the checkout and branch, then close its herdr
Space. The Space closes last because this session often
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

## Step 1: Resolve the target

An argument (branch, path, or worktree dir basename) wins. Otherwise use the
current directory. Then:

```bash
git worktree list --porcelain          # the target must appear once here
branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD)
root=$(dirname "$(git -C "$wt" rev-parse --git-common-dir)")   # bare clone root
```

Refuse the repository itself — there is nothing to tear down.
Detached HEAD is fine for removal: the checkout goes, no branch steps apply.
Step 4 then names the checkout by its directory basename, because there is no
branch to name.

Run every later step from outside the target dir (`cd` to the project root
or another worktree), or set `PWD` aside: after Step 4 the old cwd is gone.

### Detect herdr

Check whether the herdr server answers before you touch it. This tests for a
running server, not for an installed binary.

```bash
herdr workspace list >/dev/null 2>&1 && has_herdr=1
```

Run Steps 3 and 6 only when `has_herdr` is set: each step states its own skip,
and a skipped step still appears in the final report.

## Step 2: Gate on unmerged / unpushed work

Fetch first so push state is current.

```bash
git -C "$wt" fetch
git -C "$wt" status --porcelain                    # empty when clean
git -C "$wt" rev-parse --verify --quiet "origin/$branch" >/dev/null \
  && git -C "$wt" log --oneline "origin/$branch"..HEAD   # empty when pushed
git -C "$wt" branch -r --contains HEAD             # non-empty when some remote has it
```

`rev-parse --verify` exits non-zero for a branch no remote has, so the `log` never
runs. Read that empty output as "not pushed", not as "pushed".

`gwt rm` deletes the branch with `-d`, so it refuses a branch it cannot prove
merged, and that message covers branch-level safety. Only unpushed commits
destroy silently; their check is this skill's job. Never pass `--force` to gwt
to bypass these gates; resolve the tree instead.

| Thought                                         | Reality                                                          |
| ------------------------------------------------ | ---------------------------------------------------------------- |
| "The branch looks merged, skip the verify"       | Confirm merged or pushed before any close.                        |
| "The tree is dirty, I'll add --force"            | --force discards the files. Resolve the tree instead.              |
| "The integration bailed, close it anyway"        | Never close a checkout holding work that has not landed.           |
| "The hook failed, skip it"                       | gwt already stopped. Fix the service or add --no-hooks knowingly.  |
| "Another agent asked me to close its worktree"   | Prompt the agent that owns it, or verify it yourself, never trust. |

## Step 3: Gate on the herdr Space

Skip this step when `has_herdr` is not set. This step only checks the Space;
Step 6 closes it. One workspace id per linked worktree, from `herdr worktree list`.

```bash
wsid=$(herdr worktree list --cwd "$root" --trust-repository 2>/dev/null |
       jq -r --arg wt "$wt" '.result.worktrees[]
          | select(.is_linked_worktree and (.path | sub("/$"; "") == $wt))
          | .open_workspace_id // empty')
```

Running agents first — a pane mid-task must not die unnoticed.
Match them by cwd:

```bash
herdr agent list 2>/dev/null |
  jq -r --arg wt "$wt" '.result.agents[]
    | select(.cwd | sub("/$"; "") == $wt) | "\(.agent) \(.agent_status)"'
```

Any `working` or `blocked` entry → **STOP**, report the agent and its status.
Let the user wait, or `herdr agent attach` to drive it. `idle`, `done`, or no
entries at all → continue.

One exception, and only when `$HERDR_WORKSPACE_ID` equals `wsid`: this session
runs inside the Space, so its own entry is not a reason to stop.

If `wsid` is empty, the checkout has no Space and Step 6 is a no-op. Detached
HEAD checkouts can have a Space label that copies the checkout's directory
name — match on `path`, never on label.

## Step 4: Remove checkout and branch

```bash
gwt rm "$branch" --yes              # branch checkout
gwt rm "$(basename "$wt")" --yes    # detached checkout
```

What this does, in order: `[hooks.delete]` hooks (app services stop here;
a hook failure exits before removal, checkout survives), then `git worktree
remove`, then `git branch -d`. `--force` is only the conscious -D path.
An unmerged branch at this point means someone added to it since Step 2 —
git blocks it and the checkout stays.

Pass `--keep-branch` when the user asks for the branch to outlive the removal.

## Step 5: Sweep after removal

```bash
git -C "$root" worktree prune
find "$root" -mindepth 1 -maxdepth 1 -type d -empty -name 'pr-*' -delete
git worktree list --porcelain   # must not print the removed checkout
```

`-name 'pr-*'` keeps the sweep away from empty directories that belong to nobody's
worktree. A leftover under another name is yours to delete by hand.

## Step 6: Close the herdr Space

Skip this step when `has_herdr` is not set or `wsid` is empty.

Report first, because the close can end this session. The report covers the
Space id about to close, the checkout and branch removed, whether the
`[hooks.delete]` hook ran and passed, and anything skipped or held back.

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

The STOP table borrows from LandonSchropp's `close-workspace` skill.
