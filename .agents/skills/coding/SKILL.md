---
name: coding
description: Coding discipline. Load before writing, editing, or reviewing code, and before planning a change.
---

# Coding

How the work runs. What the finished code must be is the `codestyle` skill — load it with this
one; a failing codestyle rule is a failing change regardless of process.

## Think

- State your assumptions and restate the intent. Turn vague instructions into verifiable success
  criteria.
- Ask when unsure rather than guessing.

## Order the work

- Get the data shape right before you write the logic.
- Sequence work into verifiable units: finish one small unit, check it, then start the next.
- Aim at the end state you can check. A break in the middle is allowed when you planned it and
  can undo it — e.g. change a function's signature first, let the type checker list every broken
  caller, and fix them one by one; the build stays red until the last caller, and `git checkout`
  undoes it.

## Test first

- Write the failing test before you change the code. See it fail for the reason you expect. Make
  the smallest change that makes it pass.
- If an honest test is impractical, say so rather than write a bad one.
- For a change to test code only, the suite passing with the warning or failure gone is the
  check.

## Fix causes

- Reproduce it, then fix the cause. Before you edit a shared function, grep its callers. Fix it
  once in the function, not in each caller.

## Meet the project's gates

- Treat the project's existing gates as the bar for done: coverage floors, complexity caps,
  duplication checks. If a gate is missing, suggest it to the user; do not add one.

## Discipline

- Before adding complexity for a speculative race or security edge case, explain the concrete
  failure mode, likelihood, and cost to the user and get their buy-in.
- Run the project's tests and lint before reporting done. Stop any background servers or temp
  files you started.
