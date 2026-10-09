---
name: mise
description: "Diagnose and fix wrong or missing project environment variables in a mise project. Use this whenever a session runs a dev server, test runner, e2e suite, or database command in a directory with a mise.toml. Use it especially when such a command fails with missing config, connects to the wrong database, or ignores the project .env. Also use for `mise exec`, `mise env`, and `uv run --env-file` precedence questions, and whenever a command works in a fresh terminal but fails inside the agent session."
---

# mise

## Why the session's environment can be wrong

An agent session inherits its environment from the process that launched it, and that environment
stays fixed for the session. Changing directories does not update it. Two sessions in the same
directory can hold different project variables. mise handles `.env` per directory, so a session
launched elsewhere, or before the project was provisioned, runs with the wrong variables. The
failure surfaces somewhere unrelated: a test suite against the wrong database, a server missing
its config.

## Check before you debug

Before running anything that reads a project `.env` (dev server, test runner, e2e suite, database
command), ask mise what the directory defines. Do not read the file: it may be unreadable or hold
secrets.

```bash
mise env -s bash | grep -c <VAR>
```

- `1`: compare against `printenv <VAR>`. A mismatch or a blank means this session did not inherit
  the project's env.
- `0` with a `mise.toml` present: the project has not been provisioned. Run its setup task rather
  than debugging the environment.
- `0` with no `mise.toml`: you are outside a project root.

## Fix: wrap the outermost command

To work in a session that did not inherit the project's env, prefix the outermost command with
`mise exec --`:

```bash
mise exec -- pnpm test
```

`mise exec` overrides variables that are already exported, and it propagates into shell scripts
and the processes they spawn. Wrap once at the top rather than per command.

## Boundaries and precedence

- `mise exec` here fixes environment variables, not PATH. A "command not found" is an activation
  problem: fix the shell activation instead of wrapping commands.
- `mise exec` guards only inside a mise project. Where there is no config, mise sets nothing and
  an inherited value passes straight through: it fixes a wrong value, never reports a missing
  one.
- `uv run --env-file` has the opposite precedence: an exported variable shadows the file.
- Prefer a project's own script runner (`pnpm <script>`, `just`, `make`) over `npx` or a direct
  binary. The scripts carry flags the tool needs, such as `TZ`.
