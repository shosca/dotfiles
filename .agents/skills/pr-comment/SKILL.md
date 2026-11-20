______________________________________________________________________

## name: pr-comment description: > Standard for agent-authored GitHub comments: attribution callout, secret scan, and delivery check. Use before posting any PR comment, review comment, approval body, reply, or resolve note.

# PR comment

## Attribution

Prefix every agent-authored comment with this callout verbatim:

```md
> 🤖 **Responding on behalf of <user>**

Actual comment starts here.
```

- `<user>` is the user's GitHub login from `gh api user --jq .login`.
- Name the user only, with no model or tool name.
- Keep the attribution inside the quote block and the reply outside it.
- Add no horizontal rule, Setext underline, heading, signature footer, or second attribution.
- **Applies to.** Top-level PR comments, inline review comments, approval bodies, replies to bots or
  reviewers, and resolve or dismiss notes.
- **Skip on.** PR descriptions, commit messages, and text the user asked to post verbatim.

## Before posting

- **Scan for secrets and private details.** Check the whole comment, including quoted text and
  attachments, for credentials, tokens, internal hostnames, customer data, and anything private.
  Redact anything you find, or do not post.
- **Preview the markdown.** Check that quoting and blank lines match the template above.

## After posting

- **Check the response URL.** GitHub must return `html_url` in the POST response. A silent failure
  means no comment exists, so retry or report before continuing.
- **Post before resolving.** Resolve, dismiss, or link the comment only after GitHub returns its
  URL.
