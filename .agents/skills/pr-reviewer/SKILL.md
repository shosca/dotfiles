______________________________________________________________________

## name: pr-reviewer description: > Review and watch one PR from its own worktree session across first review, push re-reviews, replies, notifications, and cleanup. Started by herdr-dispatch and ticked by ghpoll on PR changes. Use when the prompt names /pr-reviewer or asks this session to review the watched PR. allowed-tools: Bash(gh pr view:*), Bash(gh api:*), Bash(gh pr diff:*), Bash(gh pr comment:*), Bash(gh pr review:*), Bash(git:*), Bash(wt:*), Bash(herdr-app:*), Bash(hc:*), Bash(jq:*), Bash(rg:\*), Read, Write, Edit, Grep, Glob, Skill, AskUserQuestion

# PR Reviewer

Review and watch PR `<n>` as its sole reviewer from the PR worktree (`<repo-root>/<branch>`) in
Herdr tab `pr-<n>-review`.

- Take `<n>` from the prompt, or fall back to
  `gh pr view "$(git branch --show-current)" --json number -q .number`.
- Treat prompt events (`pushed`, `activity`) as hints, not live state.
- One invocation is one tick. Never start a polling loop. Let `ghpoll` wake the next tick.
- Resolve the shared clone root once:

```bash
ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
```

## Each tick

Read live PR state and `$ROOT/.reviews/pr-<n>.md`:

```bash
gh pr view <n> --json state,headRefOid,baseRefName,updatedAt,reviewDecision,isDraft,labels,title,url
```

Work through cases 1–6 in order. Cases 1–3 end the tick.

1. **Merged, closed, or gone**: `state` is not `OPEN`, events say `gone`, or the PR lookup reports
   not found. Write `settled:` in the record and run [Cleanup](#cleanup).
1. **Approved**: `reviewDecision` is `APPROVED`. Write `settled: approved <time> on <sha>` once,
   keep the worktree and Space, and print one line. If `reviewDecision` is not `APPROVED` while the
   record has `settled: approved`, a push dismissed it: remove `settled:` and continue to case 3.
1. **Hold label active**: the label named by `hold_label` in `~/.config/ghpoll/config.toml`
   (default `on hold`) is present. Record it once and stop.
1. **New commits or draft upgrade**: `new` or `pushed` is in events, or `headRefOid` differs from
   the newest `revisions` entry. Run `git fetch`, and when `git status --porcelain` is empty, run
   `git reset --hard <headRefOid>`. If an earlier review exists, run "Re-review after a push" in
   `pr-review`. Review new work under [Review and posting](#review-and-posting). Also run one full
   review when the newest entry has `mode: diff-only` and the PR leaves draft, even if the SHA
   matches.
1. **Activity**: `activity` is in events, or `updatedAt` is newer than `activity_seen`. Handle under
   [Someone replied without pushing](#someone-replied-without-pushing). Run case 4 then case 5 when
   both occur in one tick.
1. **No action**: print one informational line and stop.

### End-of-tick block

Print one line when nothing changed. After any review or verdict request, print the summary in this
exact order:

1. Assessment (`clean`, `clean, 2 nits`, or `blocked, 1 blocker`) and counts, then the full PR URL
   on its own line with no trailing punctuation.
1. What changed since the last revision (no-op rebase or push changes).
1. What the PR does (two or three lines).
1. Requirement check (each acceptance criterion and result).
1. Findings (one line each with link, or `none`).
1. Items checked and judged clean (never put bugs, unprobed claims, or open questions here).
1. Items not checked (running CI, tests skipped locally).

The **assessment** is this session's reading. The **verdict** (approve, request changes, wait)
belongs to the user.

## Records

Store all revisions for PR `<n>` in `$ROOT/.reviews/pr-<n>.md` (create `.reviews/` if missing),
newest revision first:

```markdown
---
pr: 12345
url: https://github.com/OWNER/REPO/pull/12345
settled:                      # how the PR ended; absent while open
revisions:
  - sha: 03072dcd555a718d69cde2bea4836462c6e93eb3
    reviewed: 2026-09-10T13:22:00Z
    activity_seen: 2026-09-10T13:22:00Z
    notified:                 # sha or comment id already pinged, if any
    mode:                     # diff-only when that pass read only the diff
    assessment: clean, 3 nits
    blockers: 0
    findings:
      - https://github.com/…#discussion_r3979500097
---

## 03072dcd — clean, 3 nits

### Findings

The finding, and the evidence that made it real.

### Verified clean

Items checked clean (suffix with `(agent)` when a subagent checked them).
```

- **Dedupe on `revisions`**: any listed SHA counts as reviewed, including clean reviews and no-op
  rebases.
- **Append, never restart**: open each re-review from the prior conclusion and note what changed.
- **Record full reasoning**: store findings, evidence, and checked-clean items here because pane
  scrollback disappears. Keep numeric `blockers` per revision.
- **Tag `(agent)` items**: a re-review carries an `(agent)` item forward only after you re-check its
  evidence at the new head.

## Review and posting

Run the `pr-review` skill with two overrides: skip worktree checkout/cleanup (this session owns the
worktree), and post findings immediately without waiting for permission.

- **Repo rules**: if `$ROOT/.reviews/rules.md` exists, read it first.
- **Test DB probe**: probe the test setup once using the repo's command. If unreachable, read CI
  results instead and record tests as not run locally.
- **Completion bar**: write one line per applicable item of `pr-review` "Finding categories
  checklist" into the record before writing the assessment.
- **Before every post (approvals included)**: load `pr-comment` via the Skill tool for the exact
  attribution prefix, secret scan, and returned-URL check. Re-run `unslop` on the exact literal
  string right before `gh api` or `gh pr comment`.
- **Post findings in one review**: follow `pr-review` Step 11 (`comments[]` array, `event: "COMMENT"`). Blocking comments state problem, impact, and fix. Nits start with
  `Nit (non-blocking):`.
- **Restore team review requests**: posting any review removes a team's request. Record
  `gh pr view <n> --json reviewRequests` before posting, then restore missing teams with
  `gh api -X POST repos/{owner}/{repo}/pulls/<n>/requested_reviewers -f 'team_reviewers[]=<slug>'`.
- **Keep chat feedback in chat**: never post replies to internal chat reviews or relayed notes onto
  the PR. Only reply to real GitHub threads.
- **Never submit a verdict on your own**: never run `--approve`, `--request-changes`, `gh pr review`, or `event: "REQUEST_CHANGES"`. Never claim approval, readiness, or a block to the author,
  and never ask for approval on GitHub.
- **User-directed approval**: when the user tells you to approve, check `headRefOid` first (if it
  moved, review new commits and report before approving). Write a short 2–3 sentence unslopped body
  explaining the basis (clean checks or addressed fixes). Submit pinned to the reviewed SHA and
  record `settled: approved <time> on <sha>`, keeping the worktree and Space so future pushes
  re-trigger review:

```bash
gh api -X POST repos/{owner}/{repo}/pulls/<n>/reviews \
  -f commit_id=<reviewed sha> -f event=APPROVE -f body="<body>"
```

## Someone replied without pushing

Compare `updatedAt` against `activity_seen` on the newest revision (falling back to `reviewed`).
When newer, inspect activity (also check timeline if `updatedAt` looks stale, since events like
`auto_merge_enabled` do not bump it):

```bash
gh api repos/{owner}/{repo}/issues/<n>/timeline --paginate --jq '.[]|[.created_at // .submitted_at // "",.event,(.actor.login // .user.login // "")]|@tsv'
gh api repos/{owner}/{repo}/pulls/<n>/comments --paginate --jq '.[]|{id,created_at,user:.user.login,in_reply_to_id,body}'
gh api repos/{owner}/{repo}/issues/<n>/comments --paginate --jq '.[]|[.created_at,.user.login]|@tsv'
```

- **What counts**: a human reply on a thread you authored, or a review re-request. Ignore your own
  comments and bots (`type: "Bot"` or `[bot]` login suffix).
- **Action**: quote the reply's substance in the pane, notify under [Notify me](#notify-me), and
  stop. Never re-review without new code and never answer on the user's behalf (`pr-review` reply
  rule).
- **Update watermark**: always write the `updatedAt` value you read (never wall-clock time) back to
  `activity_seen` on every tick that checked activity.

## Notify me

Send at most one ping per event, deduped via `notified: <sha or comment id>` on the revision entry.
Ping on three events:

- A review completes with `blockers: 0` (waits on user verdict).
- A reply on your thread or a re-request arrives while `blockers: 0`.
- A reply arrives on a blocking thread (any blocker count).

Replies on non-blocking threads of a blocked PR go in the pane only.

**Order at end of tick**: post comments, write the record, print the end-of-tick block, write
`notified:`, then ask the blocking question (`AskUserQuestion` in Claude). Do not trigger desktop
notifications. Herdr's `blocked` terminal state is the notification channel.

- **Question format**: start with `#<n> waiting on you: <assessment>, <one line on what changed>`,
  then include the full end-of-tick summary and PR URL inside the question text (the prompt UI
  hides earlier pane output).
- **Option safety**: put the no-op option first (a stray Enter selects option 1 and must never post
  to GitHub). Never set `preview` on an option (preview dialogs can exit `blocked` state so `ghpoll`
  types into them).
- **Clarify fallback**: if the user answers `clarify`, print the full summary as plain text and ask
  what to clarify instead of repeating the same question.
- Act on the user's chosen verdict in the same turn.

## Cleanup

Run only on merge, close, or gone (never on approval), after writing `settled:` into the record:

1. Run `cd "$ROOT"` first so the shell leaves the worktree before step 3 removes it.

1. Resolve the checkout and check for uncommitted work:

   ```bash
   BRANCH=$(gh pr view <n> --json headRefName -q .headRefName)
   WT=$(git worktree list --porcelain |
        awk -v b="refs/heads/$BRANCH" '/^worktree /{p=$2} $0=="branch "b{print p}')
   git -C "$WT" status --porcelain
   ```

   If status is non-empty, keep the worktree and Space, report it in the pane, and stop.

1. Remove the worktree and branch from `$ROOT`: `wt remove "$BRANCH" -y -D` (runs `[pre-remove]`
   hooks).

1. Close the Space last (this ends the session): locate its id by matching folder `$WT` in
   `herdr-app ls`, then run `herdr-app do space.close --id <space_id> --confirmed true`.
