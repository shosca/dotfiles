______________________________________________________________________

## name: teardown description: Tear down a worktree. Check that nothing is lost, remove the checkout and branch with wt, then close its Herdr space. Triggers on "teardown", "remove/close this worktree", "shut down <branch>", or a merged task whose checkout should go.

# Teardown

Remove one worktree and its branch with `wt remove`, then close its Herdr space. Always use `wt`
(never `git worktree remove`) so `.config/wt.toml` `[pre-remove]` hooks stop app services such as
`inv dev.teardown` or `docker compose down`. Close the Herdr space last because closing it can end
this session.

Every gate must pass before any destructive step. Anything unresolved or unpushed means **STOP** and
leave the checkout intact.

## Step 1: Resolve the target

An argument (branch, path, or worktree directory basename) wins. Otherwise use the current
directory:

```bash
git worktree list --porcelain          # the target must appear once here
branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD)
root=$(dirname "$(git -C "$wt" rev-parse --git-common-dir)")   # bare clone root
```

Refuse the bare repository itself. Detached HEAD is valid: no branch steps apply, and Step 4 names
the checkout by its directory basename.

Run every later step from outside the target directory (`cd "$root"` or `git -C`). After Step 4 the
old working directory no longer exists.

### Detect Herdr

Check whether the Herdr window answers before touching it:

```bash
herdr-app status >/dev/null 2>&1 && has_herdr=1
```

Run Steps 3 and 6 only when `has_herdr` equals `1`. Still include any skipped step in the final
report.

## Step 2: Gate on unmerged or unpushed work

Fetch first so remote state is current:

```bash
git -C "$wt" fetch
git -C "$wt" status --porcelain                    # empty when clean
git -C "$wt" rev-parse --verify --quiet "origin/$branch" >/dev/null \
  && git -C "$wt" log --oneline "origin/$branch"..HEAD   # empty when pushed
git -C "$wt" branch -r --contains HEAD             # non-empty when some remote has it
```

`rev-parse --verify` exits non-zero when no remote has the branch, so `log` does not run. Read that
empty output as unpushed, not pushed.

Gate rules:

- Check merged or pushed state before closing anything. Never close a checkout holding unlanded
  work, even if an integration check failed.
- Never pass `--force` to discard a dirty tree. Resolve the tree first.
- Never pass `-D` to bypass these gates. Pass `-D` for a merged PR only when the PR's `headRefOid`
  equals local `HEAD`.
- If a `[pre-remove]` hook fails, `wt` stops cleanly. Fix the service or pass `--no-hooks`
  intentionally.
- Never trust another agent's claim that its worktree is safe. Check it yourself or ask the owning
  agent.

## Step 3: Gate on the Herdr space

Skip when `has_herdr` is unset. Look up the space by its folder path, never by name (detached HEAD
spaces can copy the directory name):

```bash
sid=$(herdr-app ls | python3 -c 'import json,sys
wt = sys.argv[1].rstrip("/")
print(next((s["id"] for s in json.load(sys.stdin)["spaces"]
            if (s.get("folder") or "").rstrip("/") == wt), ""))' "$wt")
```

Check for active agents in that space so no mid-task session dies unnoticed:

```bash
herdr-app ls | python3 -c 'import json,sys
wt = sys.argv[1].rstrip("/")
for s in json.load(sys.stdin)["spaces"]:
    if (s.get("folder") or "").rstrip("/") != wt: continue
    for tab in s["tabs"]:
        for t in tab["terminals"]:
            if t["status"]: print(t["terminal"], tab["name"], t["status"])' "$wt"
```

- Any `working` or `blocked` terminal: **STOP** and report its terminal ID and status so the user
  can wait or run `hc attach <terminal>`. Exception: ignore a terminal whose ID equals
  `$HC_TERMINAL_ID` (this session).
- Only `idle`, `done`, or no entries: continue.
- Empty `sid`: no space exists, so Step 6 is a no-op.

## Step 4: Remove checkout and branch

For a self-teardown, skip running this alone and use the Step 6 chain instead:

```bash
cd "$root" && wt remove "$branch" -y $force     # branch checkout
cd "$root" && wt remove "$(basename "$wt")" -y  # detached checkout
```

`wt remove` runs `[pre-remove]` hooks first (a failure aborts before removal), removes the
worktree, then removes the branch if merged or equal to the default branch. If `wt` keeps an
unmerged branch, someone added commits since Step 2: report it. Pass `--no-delete-branch` when the
user asks to keep the branch.

## Step 5: Sweep after removal

```bash
git -C "$root" worktree prune
find "$root" -mindepth 1 -maxdepth 1 -type d -empty -name 'pr-*' -delete
git worktree list --porcelain   # must not print the removed checkout
```

`-name 'pr-*'` avoids removing unrelated empty directories. Leave other leftovers for the user.

## Step 6: Close the Herdr space

Skip when `has_herdr` is unset or `sid` is empty.

Send the final report first because closing the space can end this session. Include the space ID,
removed checkout and branch, `[pre-remove]` hook outcome, and anything skipped or kept.

Standalone close:

```bash
herdr-app do space.close --id "$sid" --confirmed true
```

Self-teardown (send the report, then run Steps 4 to 6 in one `&&` chain, omitting the `herdr-app`
line if `sid` is empty):

```bash
cd "$root" && wt remove "$branch" -y $force &&
  git worktree prune &&
  find "$root" -mindepth 1 -maxdepth 2 -type d -empty \( -name 'pr-*' -o -name pr \) -delete &&
  herdr-app do space.close --id "$sid" --confirmed true
```

`&&` stops on the first failure, so a hook failure leaves the checkout and space intact to report.
When `$HC_TERMINAL_ID` sits inside that space, make the close the last tool call.

When running from outside that space, check that the space closed:

```bash
herdr-app ls | python3 -c 'import json,sys
wt = sys.argv[1].rstrip("/")
print(",".join(s["id"] for s in json.load(sys.stdin)["spaces"]
               if (s.get("folder") or "").rstrip("/") == wt))' "$wt"
```

Empty output means success. If an ID still prints, report that the close did not reach it.
