---
name: pr-comment
description: >
  Standard for every agent-authored comment left on GitHub on the user's behalf: attribution
  callout, secret scan, post-then-verify. Use before posting any PR comment, review comment,
  reply, resolve or dismiss explanation — whenever a comment leaves GitHub through this agent.
---

# PR Comment

Govern the format and delivery of comments this agent posts to GitHub. The review content
itself — findings, verdicts, style — lives in the calling skill ([`pr-review`](../pr-review/SKILL.md),
[`pr-reviewer`](../pr-reviewer/SKILL.md), [`babysit-pr`](../babysit-pr/SKILL.md)) and its
`asd-ste100` + `unslop` prose rules. This skill covers what those skills do not: who the comment
says it is from, and whether it landed.

## Attribution

Prefix every agent-authored comment with this callout:

```md
> 🤖 ** responding on behalf of <user>**

Actual comment starts here.
```

- `<model>` is the verified model that wrote the comment; `<user>` is the user's name or GitHub
  login, resolved through `gh api user --jq .nameOrLogin` when in doubt.
- **When the model name is not exposed, omit it**: `🤖 **on behalf of <user>**`. Never guess a
  model name, and never name a model the session is not.
- Delegate case: a sub-agent's comment names the sub-agent's model when the harness exposes it,
  otherwise falls back to the parent session's, otherwise omits.
- Keep the attribution inside the note and the actual reply outside it. The context line starts
  with the robot emoji. Add no horizontal rule, Setext underline, heading, signature footer, or a
  second attribution anywhere in the comment.

### Where attribution applies

| Applies | Does not apply |
| --- | --- |
| Top-level PR comments | PR descriptions |
| Inline review comments | Commit messages |
| Replies to bots or reviewers | Text the user asked to post verbatim |
| Explanations used before resolving or dismissing feedback | |

## Before posting

- **Scan the whole comment for secrets and private details** — quoted text and attachments
  included. This expands the `pr-review` rule beyond customer data: credentials, tokens,
  internal hostnames, anything that must not be public. Anything found: redact, do not post.
- The user gave no instruction to post this text verbatim; the attribution applies.

## After posting

- **Verify GitHub returned the comment or review URL.** A silent failure means no comment
  exists. The POST response's `html_url` is the evidence; no URL, no comment — retry or report
  before going on.
- **Post before resolve.** Resolve, dismiss, or reply linking the comment only after the response
  is confirmed on GitHub (`babysit-pr` section 5 encodes the same ordering for its push).
- Preview the final markdown first so quoting and blank lines render as shown.
