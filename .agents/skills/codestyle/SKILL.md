---
name: codestyle
description: The code-quality bar — the product rules that coding writes to and pr-review judges against.
---

# Codestyle

What finished code must be. Every rule here is visible in a diff, so a reviewer can check it and
an author can be held to it. Process — how the work runs — lives in the `coding` skill.

## Simplicity

- Ship the smallest edit that solves the problem. No abstractions nobody asked for.
- Subtract before you add.
- One decision lives in one place.

## Scope

- Default to surgical changes: touch only code the request covers; every changed line traces
  back to what was asked.
- When the new requirement forces the old design to misrepresent itself — a second caller, a
  second format, a second source — redesign from first principles: build what you would have
  built from day one, and deliver it in pieces.

## Boundaries

- Check the data where it enters; inside, trust it. Keep business logic in pure functions.
- Make the illegal value impossible to write. Parse outside data once, where it comes in. Do not
  silence the compiler.
- Make operations idempotent: running twice, or resuming after a crash halfway through, ends in
  the same state.
- If two workers do not need the same mutable thing, give each its own. If they do, allow one
  writer and enforce that in the structure.

## Types

- Rely on type inference; annotate only when necessary for exports or clarity.
- Prefer `unknown` or a generic over `any`/`Any`. When `any` is unavoidable, state why in one
  line.

## Tests

- The test calls the code the way its user does and checks the result that user would see. If the
  test would still pass when every function returned nothing, throw it out.
- A guard that only hides the crash is not a fix.

## Structure of a function

- Inline single-use logic at the call site. Extract a helper only when it is reused, hides a
  genuinely complex boundary, or has a clear independent name that improves the caller.
- Docstrings carry the reasoning: why the function exists, design choices, ordering constraints,
  what it mirrors. Inline comments stay rare: one short line tied to one surprising line. Tests
  follow the same rule.
