______________________________________________________________________

## name: codestyle description: The code-quality bar for finished code. Coding writes to these rules and pr-review judges against them.

# Codestyle

Rules for finished code that a reviewer can check in a diff. Process lives in the `coding` skill.

## Simplicity and scope

- Ship the smallest edit that solves the problem. Avoid unrequested abstractions.
- Subtract before you add.
- Keep one decision in one place.
- Default to surgical changes. Touch only code the request covers so every changed line traces back
  to it.
- When a new requirement (a second caller, format, or source) makes the old design lie, redesign
  from first principles. Build what day one should have had, and deliver it in pieces.

## Boundaries and types

- Check data where it enters, then trust it inside. Keep business logic in pure functions.
- Parse outside data once at the boundary so illegal values cannot compile. Do not silence the
  compiler.
- Make operations idempotent. Running twice or resuming after a crash ends in the same state.
- Give workers separate state when they do not need shared mutable data. Otherwise enforce one
  writer in the structure.
- Rely on type inference. Annotate only when exports or clarity require it.
- Prefer `unknown` or a generic over `any`/`Any`. When `any` is unavoidable, state why in one line.

## Tests

- Call the code the way its user does and check the result that user sees. Delete any test that
  still passes if every function returns nothing.
- A guard that only hides a crash is not a fix.

## Function structure

- Inline single-use logic at the call site. Extract a helper only when multiple callers share it, it
  hides a complex boundary, or a clear name improves the caller.
- Put reasoning in docstrings (why the function exists, design choices, ordering constraints, what
  it mirrors). Keep inline comments rare: one short line tied to one surprising line. Apply the same
  rule to tests.
