---
name: teardown
description: Tear down a worktree — verify nothing is lost, delete the checkout and branch with wt, then close its Herdr space. Triggers on "teardown", "delete/close this worktree", "shut down <branch>", or a merged task whose checkout should go.
---

# Teardown

Tear down one worktree: delete the checkout and branch, then close its Herdr
space. The space closes last because this session often
runs inside it, and closing it ends the session. Two mechanisms do the real
removal:

- **`wt remove <branch>`** removes the worktree and the branch. wt runs the
  repo's `[pre-remove]` hooks first (cwd = the worktree, templates like
  `{{ branch }}` and `{{ worktree_path }}`), so `wt remove` handles app
  services like `inv dev.teardown` or `docker compose down` by itself.
- **`herdr-app do space.close --id <id> --confirmed true`** closes the Herdr
  space and ends its terminals. This skill removes checkouts through wt, so
  the `.config/wt.toml` hooks stay in control; `git worktree remove` never
  runs here.

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

Run every later step from outside the target dir: `cd "$root"`, or use
`git -C`. After Step 4 the old cwd is gone.

### Detect Herdr

Check whether the app window answers before you touch it.

```bash
herdr-app status >/dev/null 2>&1 && has_herdr=1
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

`wt remove` keeps a branch it cannot prove merged, with a hint to rerun with
`-D`. Only unpushed commits destroy silently; their check is this skill's job.
Never pass `-D` to wt to bypass these gates; resolve the tree instead.

| Thought                                         | Reality                                                          |
| ------------------------------------------------ | ---------------------------------------------------------------- |
| "The branch looks merged, skip the verify"       | Confirm merged or pushed before any close.                        |
| "The tree is dirty, I'll add --force"            | --force discards the files. Resolve the tree instead.              |
| "The PR merged, so -D is fine"                   | Only when the PR's `headRefOid` equals the local `HEAD`.            |
| "The integration bailed, close it anyway"        | Never close a checkout holding work that has not landed.           |
| "The hook failed, skip it"                       | wt already stopped. Fix the service or add --no-hooks knowingly.   |
| "Another agent asked me to close its worktree"   | Prompt the agent that owns it, or verify it yourself, never trust. |

## Step 3: Gate on the Herdr space

Skip this step when `has_herdr` is not set. This step only checks the space;
Step 6 closes it. Find it by its folder, which equals the checkout path.

```bash
sid=$(herdr-app ls | python3 -c 'import json,sys
wt = sys.argv[1].rstrip("/")
print(next((s["id"] for s in json.load(sys.stdin)["spaces"]
            if (s.get("folder") or "").rstrip("/") == wt), ""))' "$wt")
```

Running agents first — a session mid-task must not die unnoticed.
Match them by the space they sit in:

```bash
herdr-app ls | python3 -c 'import json,sys
wt = sys.argv[1].rstrip("/")
for s in json.load(sys.stdin)["spaces"]:
    if (s.get("folder") or "").rstrip("/") != wt: continue
    for tab in s["tabs"]:
        for t in tab["terminals"]:
            if t["status"]: print(t["terminal"], tab["name"], t["status"])' "$wt"
```

Any `working` or `blocked` entry → **STOP**, report the terminal and its status.
Let the user wait, or `hc attach <terminal>` to drive it. `idle`, `done`, or no
entries at all → continue.

One exception, and only when `$HC_TERMINAL_ID` equals a listed terminal: this
session runs inside the space, so its own entry is not a reason to stop.

If `sid` is empty, the checkout has no space and Step 6 is a no-op. Detached
HEAD checkouts can have a space name that copies the checkout's directory
name — match on folder, never on name.

## Step 4: Remove checkout and branch

```bash
cd "$root" && wt remove "$branch" -y $force     # branch checkout
cd "$root" && wt remove "$(basename "$wt")" -y  # detached checkout
```

For a self-teardown, do not run this alone. Run the chain in Step 6.

What this does, in order: `[pre-remove]` hooks (app services stop here;
a hook failure exits before removal, checkout survives), then `git worktree
remove`, then branch deletion. wt deletes the branch when it is merged or
equal to the default branch; otherwise it keeps the branch and prints a hint.
An unmerged branch means someone added to it since Step 2. Report it.

Pass `--no-delete-branch` when the user asks for the branch to outlive the removal.

## Step 5: Sweep after removal

```bash
git -C "$root" worktree prune
find "$root" -mindepth 1 -maxdepth 1 -type d -empty -name 'pr-*' -delete
git worktree list --porcelain   # must not print the removed checkout
```

`-name 'pr-*'` keeps the sweep away from empty directories that belong to nobody's
worktree. A leftover under another name is yours to delete by hand.

## Step 6: Close the Herdr space

Skip this step when `has_herdr` is not set or `sid` is empty.

Report first, because the close can end this session. The report covers the
space id about to close, the checkout and branch removed, whether the
`[hooks.delete]` hook ran and passed, and anything skipped or held back.

Then close the space:

```bash
herdr-app do space.close --id "$sid" --confirmed true
```

For a self-teardown, send the report, then run Steps 4 to 6 as one call:

```bash
cd "$root" && wt remove "$branch" -y $force &&
  git worktree prune &&
  find "$root" -mindepth 1 -maxdepth 2 -type d -empty \( -name 'pr-*' -o -name pr \) -delete &&
  herdr-app do space.close --id "$sid" --confirmed true
```

The `&&` chain stops at the first failure. A `wt remove` hook failure then leaves
the checkout and the space open, so the session can report it. Skip the
`herdr-app` part when `sid` is empty.

When `$HC_TERMINAL_ID` equals a terminal in that space, make the close the last
tool call. It ends this session's terminal, so nothing after it runs. That is
correct as the final step of the checkout's work.

Otherwise, confirm the space is gone:

```bash
herdr-app ls | python3 -c 'import json,sys
wt = sys.argv[1].rstrip("/")
print(",".join(s["id"] for s in json.load(sys.stdin)["spaces"]
               if (s.get("folder") or "").rstrip("/") == wt))' "$wt"
```

An empty line is correct. A space that still matches the removed checkout means
the close did not reach it. Report it rather than assuming all is well.
