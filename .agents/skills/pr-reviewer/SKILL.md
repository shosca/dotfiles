---
name: pr-reviewer
description: >
  Review and watch one PR from its own worktree session: first review, re-reviews after a push,
  replies, notifications, and cleanup when the PR is merged or closed. Started by
  herdr-dispatch; ghpoll sends the next pass when the PR changes. Use when the prompt names
  /pr-reviewer or asks this session to review the watched PR.
allowed-tools: Bash(gh pr view:*), Bash(gh api:*), Bash(gh pr diff:*), Bash(gh pr comment:*), Bash(gh pr review:*), Bash(git:*), Bash(gwt:*), Bash(herdr:*), Bash(jq:*), Bash(rg:*), Read, Write, Edit, Grep, Glob, Skill, AskUserQuestion
---

Review and watch PR <n>. This session is the PR's only reviewer. It runs in the PR's worktree,
`pr-<n>/`, as the herdr agent `pr-<n>-review`. The orchestrator started it through
`herdr-dispatch`. Everything after that is this session's job: the first review, re-reviews after a
push, replies, notifications, and cleanup when the PR is merged or closed.

`<n>` is the PR number in the prompt. If the prompt has none, take it from the worktree name:
`basename "$PWD"` prints `pr-<n>`.

The rest of the prompt is the events ghpoll reported, such as `pushed` or `activity`. They say why
the tick ran. They are a hint, not the state: read the state before you act.

One invocation is one tick. ghpoll watches the PR and wakes the orchestrator, which forwards the
PR's events. This session starts no loop of its own.

Resolve the clone root once:

```bash
ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
```

## Each tick

Read the live state and the record at `$ROOT/.reviews/pr-<n>.md`:

```bash
gh pr view <n> --json state,headRefOid,baseRefName,updatedAt,reviewDecision,isDraft,labels,title,url
```

Then work through these in order. Cases 1 to 3 end the tick.

1. **Merged, closed or gone.** `state` is not `OPEN`, or the events say `gone`. A state read that
   fails because the PR no longer exists counts as gone. Write `settled:` into the record and
   clean up. See "Cleanup".
2. **Approved.** `reviewDecision` is `APPROVED`. Write `settled: approved <time> on <sha>` into the
   record once, keep the worktree and the Space, and report one line. When `reviewDecision` is not
   `APPROVED` but the record says `settled: approved`, a push dismissed the approval: remove the
   `settled:` line and go on to case 3.
3. **The repo's hold label is on.** `hold_label` in `~/.config/ghpoll/config.toml` names it
   (default `on hold`). It means the author or the team parked the PR. Record the label once and
   do nothing else. When the label comes off, the next tick carries on normally.
4. **`new` or `pushed` is in the events, or `headRefOid` is not the newest `revisions` entry.**
   Fetch. When an earlier review exists, run "Re-review after a push" in the `pr-review` skill.
   Review the head when it is new work. See "Review and posting".
   A newest entry marked `mode: diff-only` came from an older draft review that read only the
   diff. When the PR is no longer a draft, review its head in full once, reading that entry first,
   even when the SHA matches. The full review adds an entry without `mode`, so the rule stops
   applying by itself.
5. **`activity` is in the events, or `updatedAt` is newer than `activity_seen`.** See "Someone
   replied without pushing". A push and a reply in the same tick run 4 then 5: the review does not
   cover the reply.
6. **Nothing above applied.** The event was informational. Report one line and stop.

End every tick with one block in the pane. A tick where nothing changed prints one line. A tick
that reviewed a revision, or that asks for my verdict, prints the review summary, in this order:

1. The assessment and the blocker and nit counts, then the PR URL on its own line.
2. What changed since the last revision: a rebase with no code change, or what the push changed.
3. What the PR does, in two or three lines.
4. The requirement check: each acceptance criterion and its result.
5. The findings, one line each with its link, or "none".
6. What I let pass, and why. This lists only items checked and judged not a problem. An earlier
   bug, an unprobed claim or an open question is a finding, so it goes in item 5.
7. What I did not verify, such as CI that is still running or tests not run locally.

The **assessment** is this session's reading of the revision: `clean`, `clean, 2 nits` or
`blocked, 1 blocker`. The **verdict** is mine: approve, request changes, or wait. The pane reports
the assessment and puts the verdict to me as a question.

A count alone gives me nothing to decide on. Without the summary, I cannot approve. A tick that
pings carries the summary inside the question as well, as "Notify me" describes.

When the block asks for my verdict, it carries the PR's full URL on its own line, with no
punctuation after it, so I can open it from the pane. This covers a revision that comes back with
no blockers. `#<n>` alone is not a link.

**An approval pauses the watch.** When I tell this pane to approve, submit the approval and write
`settled: approved <time> on <sha>` into the record in the same turn. When someone else approves,
the next tick sees `reviewDecision: APPROVED` and records it the same way. Keep the worktree and
the Space. The repo dismisses an approval on a push, and ghpoll keeps ticking an approved PR, so
the next push comes back here as a re-review. Clean up only on a merge, a close or a PR that is
gone.

## Records

Write every review to one file per PR, `$ROOT/.reviews/pr-<n>.md`, beside `.beans/` at the
shared clone root. It resolves from inside any worktree, and it sits outside all of them, so git
never sees it. Create the directory when it is missing.

The file holds every revision I have reviewed, newest first, so it opens on the latest:

```markdown
---
pr: 12345
url: https://github.com/OWNER/REPO/pull/12345
settled:                      # how the PR ended; absent while it is open
revisions:
  - sha: 03072dcd555a718d69cde2bea4836462c6e93eb3
    reviewed: 2026-09-10T13:22:00Z
    activity_seen: 2026-09-10T13:22:00Z
    notified:                 # the sha or comment id already pinged, if any
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

What I checked that came back fine: the URL parity, the missed consumer that wasn't, the behaviour
unchanged after the push.
```

- **Dedupe on the `revisions` list.** A head that already appears there is reviewed. A new push
  adds a SHA rather than a file, and so does a rebase that carries the assessment forward. Record a
  clean review too. It posts nothing to GitHub, so this file is the only thing that stops it being
  redone on every tick.
- **Append, never restart.** A re-review opens on what the last one concluded and checked clean,
  and reads the new revision against that. Say in the new section what changed since the revision
  below it.
- **Write the findings in full.** The pane scrolls away, and the posted comments carry only what
  is about the code. The reasoning behind an assessment and everything that checked out fine live
  nowhere else.
- `blockers` is per revision, so "waiting on me" is computable rather than parsed out of prose.
- `settled:` in the frontmatter records how the PR ended: an approval, a merge, a close, or the PR
  disappearing. A push that dismisses the approval removes `settled: approved`.
- **Mark who checked each "Verified clean" item.** Suffix an item with `(agent)` when a subagent
  ran it and you did not read the evidence yourself. A re-review carries an `(agent)` item forward
  only after you check that its evidence still holds at the new head.

## Review and posting

Use the `pr-review` skill. It carries the review: the full patch, prior threads, missed consumers,
the project's documented rules, behaviour changes and probes. Post through the
[`pr-comment`](../pr-comment/SKILL.md) standard: attribution callout, secret scan, return-URL
verification. Two of `pr-review`'s steps are overridden here:

- **The worktree already exists.** It is this session's cwd. Skip the checkout step. Do not remove
  the worktree at the end.
- **Posting is pre-authorized.** The skill's "wait for the user to ask" step does not apply. Post
  findings as soon as the review is done.

**The review is done when the record has a result for each checklist item.** Write one line per
applicable item of the `pr-review` "Finding categories checklist" into the record. Write the
assessment only after the last line.

**Check the test setup before the first test run.** A `gwt pr` worktree may have no reachable test
database. Probe it once, with the command in the project's rules. When it fails, read the PR's CI
results instead, and record the tests as not run locally.

**Repo rules.** If `$ROOT/.reviews/rules.md` exists, read it before reviewing. It holds that
repo's rules. Do not put them in this skill.

**Findings get posted.** Post every comment in one review, as `pr-review` Step 11 describes: one
`comments[]` array, one notification. Blocking findings state problem, impact and fix. Nits carry
the `Nit (non-blocking):` prefix.

**Posted comments consume review requests.** GitHub silently removes a team's request when one of
its members posts any review, including comments only. The PR then leaves the team's queue with no
verdict. Before you post, record `gh pr view <n> --json reviewRequests`. After you post, restore
each team that is gone:
`gh api -X POST repos/{owner}/{repo}/pulls/<n>/requested_reviewers -f 'team_reviewers[]=<slug>'`.

**Unslop the literal string, not an earlier draft.** Running the skill once in a turn does not
clean text drafted later in the same turn. Re-read the exact body going into the `gh api` or
`gh pr comment` call immediately before the call. Look for em-dash chains, colon-as-connector,
dense parentheticals and "here's what I did" framing.

**A review given in chat gets answered in chat.** An internal review, an agent's findings, notes I
relay: none of that goes onto the PR. The test is whether a PR reader can tell what the comment
responds to. If the thing being answered is not on the PR, the answer does not belong there.
Replying to genuine GitHub review threads stays fine.

**Never submit a review verdict. That is mine.** No `--approve` or `--request-changes` on your own
judgment, and no `gh pr review` at all except the approval I ask for below, including the
`request_changes` event `pr-review` suggests for a blocking finding. Post individual comments
through the comments API only. Do not tell the author the PR is approved, ready to merge, or
blocked. Do not ask me to approve it in the PR itself. This holds even when the review is clean and
even when every finding is a nit.

**When I do say "approve", that approval carries a body.** Two or three sentences giving the
verdict's basis: what the review turned up, or that it was clean and what the review checked. On a
re-review after fixes, say what was addressed. Never a bare `gh pr review --approve`. The full
reasoning lives in the record, which nobody but me can read, so an empty approval throws it away
for everyone else. The rule that a clean review posts no comments governs the comment stream, not
the approval body. Keep the body short and unslop it like any other posted text. Then follow "An
approval ends the watch" above.

## Someone replied without pushing

An author who answers a finding without changing a line leaves the SHA alone, so the dedupe skips
the review, and that is right: there is no new code to read. But a reply to a blocking finding is
the single most stallable thing in this whole watch. It is waiting on me, and nothing else surfaces
it. **Report the substance, notify per "Notify me", never re-review.**

The watermark is `activity_seen` on the newest revision entry, falling back to `reviewed` when
absent. When `updatedAt` is newer, classify what changed:

```bash
gh api repos/{owner}/{repo}/issues/<n>/timeline --paginate --jq '.[]|[.created_at // .submitted_at // "",.event,(.actor.login // .user.login // "")]|@tsv'
gh api repos/{owner}/{repo}/pulls/<n>/comments --paginate --jq '.[]|{id,created_at,user:.user.login,in_reply_to_id,body}'
gh api repos/{owner}/{repo}/issues/<n>/comments --paginate --jq '.[]|[.created_at,.user.login]|@tsv'
```

`updatedAt` does not move for every event (`auto_merge_enabled` leaves it alone), so read the
timeline rather than trusting the timestamp when something looks stale.

What counts: **a reply on a thread I authored, or a re-request.** Someone answering my finding is
waiting on me in a way an unrelated comment is not. Ignore my own comments and bots: a bot
re-posting its status is not a person waiting. A bot account has `type: "Bot"` in the API payload,
or a `[bot]` suffix on its login.

Quote the reply's substance in the pane, not just that it exists. The decision it asks for is
usually in the text. Then stop. I read it in the pane and tell this session what to say back; the
`pr-review` rules on replies forbid answering on my behalf.

**Write `activity_seen` back on every tick that looked, always.** Without it the comparison is
against `reviewed`, which never moves, so a single reply fires on every tick for as long as the PR
stays open. Copy the value from the `updatedAt` you read, never from the clock: a clock time
later than a reply hides that reply. A push tick that writes a new revision runs this section too
when `updatedAt` is newer than the previous `activity_seen`.

## Notify me

A tick runs while I am in another window, so an event that wants something from me has to reach
me. One notification per event, never two for the same one.

Ping when the newest revision has `blockers: 0`, because the PR then waits on my verdict. A
blocked PR waits on its author, so a reply on it goes in the pane only. The one exception is a
reply on the blocking thread itself: the author disputes or answers the blocker, and that waits on
me. Events that ping:

- **A review that comes back with no blockers.** It now waits on my verdict.
- **A reply on my thread, or a re-request,** while the newest revision has no blockers.
- **A reply on a blocking thread**, whatever the blocker count.

Dedupe through the record: write `notified: <sha or comment id>` on the revision entry when the
ping goes out, and send nothing for an event already listed there. Ping last in the tick, in this
order: post the comments, write the record, print the end-of-tick block, then ask. The ping never
promises findings that are not up yet.

The question box hides every line printed in the same turn, the end-of-tick block included. Put
the full end-of-tick summary, the PR URL included, in the question text itself, after the one-line
event. Never set `preview` on an option: herdr reports a pane with a preview dialog as `done`, not
`blocked`, so ghpoll types into it and its Enter picks an option.

When I answer a question with "clarify" instead of an option, the summary did not reach me. Print
the full summary as plain text, then ask what I want to clarify. Do not ask the same question
again.

To ping, write `notified:` first, then ask me a question and wait. That is the only ping this
session sends: the rich-notifications plugin turns a `blocked` pane into a desktop notification, and
it is the one channel that behaves the same for every agent. `herdr notification show` reaches the
herdr window only, so do not use it here. Use whatever blocking question the harness has (Claude:
`AskUserQuestion`). Start the question with the event: `#<n> waiting on you: <assessment>, <one line
on what changed>`. The summary follows it. Offer the verdict the event asks for, such as approve or leave it, and act on the answer
in the same turn. Put the option that changes nothing first. A stray Enter selects the first
option, so it must never post to GitHub.

## Cleanup

On a merge, a close or a PR that is gone, after `settled:` is in the record. An approval keeps the
worktree, because a push dismisses it:

1. `cd "$ROOT"` first: step 2 deletes the directory this session runs in, and a shell that sits in
   a deleted directory cannot run the rest of the cleanup.
2. Check the worktree. `git -C "$ROOT/pr-<n>" status --porcelain` must print nothing. If it
   lists anything, keep the worktree and the Space, say so in the pane, and stop there.
3. Prune the worktree and its branch from the clone root: `gwt rm "pr/<n>" --yes`. It runs the
   repo's `[hooks.delete]`, the counterpart of the `[hooks.pr]` that `gwt pr` ran when it made this
   worktree. Raw git skips that hook.
4. Close the Space last, because closing it ends this session. Find it by `checkout_path` in
   `herdr workspace list`, and close it with `herdr workspace close <workspace_id>`. Never use
   `herdr worktree remove`: it removes the checkout too, and git already removed it in step 3.
