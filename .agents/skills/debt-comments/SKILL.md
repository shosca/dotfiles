---
name: debt-comments
description: >
  Mine the codebase's comments for unmarked debt. Look for workarounds,
  second sources of truth, hacks, ignored errors, hand-rolled retries, and
  deviations from documented standards. Produces one ranked list. One-shot
  report, changes nothing. Use when the user says "find debt comments",
  "audit hacks", or "find workarounds". Also use for "TODO audit",
  "where do we ignore errors", or "second source of truth". Or invokes
  /debt-comments.
---

Comments record debt that nobody filed. This collects it into one ranked list
so it gets triaged instead of rotting.

## Scan

Search comment lines only. Skip `node_modules`, `.git`, `dist`, `build`,
`vendor`, lockfiles, and generated code. Treat a file as generated when its
header says `@generated` or `DO NOT EDIT`. When the user names a path, scan
that path only.

Match a keyword only after a comment prefix on the same line. The prefix
anchor keeps code, strings, and prose out of the results. Use double quotes
around the pattern, because several keywords contain an apostrophe.

```sh
grep -rnEi --exclude-dir={.git,node_modules,dist,build,vendor,coverage,.venv} \
  --exclude='*.lock' --exclude='package-lock.json' --exclude='go.sum' \
  --exclude='*.min.*' --exclude='*.pb.go' \
  '(^[[:space:]]*(//|#|/\*|\*|--)).*(<keywords>)' .
```

Run it once per group below. Read the surrounding lines of each hit. A keyword
inside a multi-line block comment counts only when its line starts with a
prefix or `*`.

1. **Workarounds** — `workaround`, `temporary`, `temp fix`, `for now`, `until we`, `revisit`, `revert this`
2. **Second sources of truth** — `keep in sync`, `must match`, `mirror`, `copied from`, `duplicated in`
3. **Hacks** — `hack`, `kludge`, `gross`, `ugly`, `nobody knows why`
4. **Ignored errors** — `ignore`, `swallow`, `continue on error`, `fail silently`, `eslint-disable`, `# noqa`, `# type: ignore`, `@ts-ignore`, `@SuppressWarnings`
5. **Hand-rolled retries** — `retry`, `give up after`, `backoff`, `retries`
6. **Standard exemptions** — `exception to`, `we don't follow`, `deliberately not`, `deviates from`, `instead of the standard`
7. **Magic values and fallbacks** — `hardcoded`, `default to`, `should be fine`, `seems enough`, `assume`
8. **Classic markers** — `TODO`, `FIXME`, `XXX`, `tech debt`, `clean this up`
9. **Bypassed layers** — `bypass`, `goes around`, `call directly`
10. **Manual steps** — `remember to`, `don't forget`, `must manually`, `requires a manual`
11. **Fragile coupling** — `order matters`, `do not reorder`, `must run before`, `relies on`, `depends on the fact`
12. **Fear comments** — `don't touch`, `last time we`, `broke production`, `do not change`
13. **Contract and deprecation** — `@deprecated`, `Deprecated:`, `not thread-safe`, `caller must`, `internal use only`

### Doc comments

JSDoc and `///` doc comments already match the prefix anchor. Docstring bodies
do not, and the general groups stay out of them. In doc prose, `assume`,
`default to`, and `must match` are normal documentation.

Scan group 13 alone, without the anchor and limited to code files:

```sh
grep -rnEi --include='*.{py,pyi,ts,tsx,js,mjs,go,rs,java,kt}' \
  --exclude-dir={.git,node_modules,dist,build,vendor,.venv} \
  '(@deprecated|Deprecated:|not thread-safe|caller must|internal use only)' .
```

Findings are comments, not code smells. A disabled lint rule with a stated
reason is not debt. One with no reason is.

## Skip owned markers

`ponytail:` and `shortcut:` comments name their own limit and upgrade trigger.
`ponytail-debt` reports them. Drop them here.

## Classify

For each hit, decide whether it is real debt or an innocent comment that
contains the keyword. Keep real debt. Drop innocent hits without comment.

## Rank

Order findings by this ladder, most urgent first.

1. `silent-failure` — swallowed errors, magic defaults, unsupported assumptions.
   Wrong data leaves no trace.
2. `drift` — second sources of truth, bypassed layers, deprecation markers left
   in place. They diverge or rot over time.
3. `blocked-change` — workarounds, exemptions from a standard, fragile ordering.
   They stop the next change.
4. `manual-step` — work that a script or a hook should do.
5. `marker` — untracked `TODO` and `FIXME` comments.

A `TODO` with an owner or a ticket reference is already tracked. Leave it out.

## Report

One ranked list. Cap each tier at 20 findings and say when a tier is
truncated. When the same comment text appears in several files, report it once
and give the file count.

```
path/to/file.py:123  [drift]
    "quoted comment text"
    One sentence: what breaks, or what it blocks.
```

End with the count per tier. Read-only: change no files.
