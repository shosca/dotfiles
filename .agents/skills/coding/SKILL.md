______________________________________________________________________

## name: coding description: Coding discipline. Load before writing, editing, or reviewing code, and before planning a change.

# Coding

This skill defines how the work runs. Load `codestyle` alongside it for the bar on finished code.
A failing `codestyle` rule fails the change regardless of process.

## Think and sequence

- State assumptions, restate intent, and turn vague requests into checkable criteria. Ask when
  unsure instead of guessing.
- Get the data shape right before writing logic.
- Split work into small, checkable units. Finish and check one unit before starting the next.
- Temporary red states are fine when planned and reversible. For example, change a signature first,
  let the type checker list broken callers, fix each one, and undo with `git checkout` if needed.

## Test first and fix causes

- Write a failing test before changing code, watch it fail for the expected reason, then write the
  smallest fix that makes it pass.
- If an honest test is impractical, say so instead of writing a weak one.
- For test-only edits, the suite passing with the failure or warning gone is the check.
- Reproduce a bug, then fix its root cause. Grep every caller before editing a shared function, and
  fix the cause once in the function rather than in each caller.

## Gates and discipline

- Meet the repo's existing gates (coverage floors, complexity caps, duplication checks). Suggest a
  missing gate to the user instead of adding one unasked.
- Before adding complexity for a speculative race or security edge case, present the failure mode,
  likelihood, and cost to the user for approval.
- Run the repo's tests and lint before reporting done. Stop background servers and remove temp
  files you created.
