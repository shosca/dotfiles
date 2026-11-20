______________________________________________________________________

## name: mise description: "Diagnose and fix wrong or missing project environment variables in a mise project. Use this whenever a session runs a dev server, test runner, e2e suite, or database command in a directory with a mise.toml. Use it especially when such a command fails with missing config, connects to the wrong database, or ignores the project .env. Also use for `mise exec`, `mise env`, and `uv run --env-file` precedence questions, and whenever a command works in a fresh terminal but fails inside the agent session."

# mise

## Why the session environment can be wrong

An agent session inherits a fixed environment from its parent process, and `cd` does not update it.
`mise` scopes `.env` per directory, so a session started elsewhere (or before project setup ran)
holds stale or missing variables. Failures surface indirectly, such as tests hitting the wrong
database or servers missing config.

## Check before you debug

Before running anything that reads `.env` (dev server, test runner, e2e suite, database command),
query `mise` instead of reading `.env` directly (it may be unreadable or hold secrets):

```bash
mise env -s bash | grep -c <VAR>
```

- `1`: compare against `printenv <VAR>`. A mismatch or blank means this session missed the project
  environment.
- `0` with `mise.toml` present: the project still needs setup. Run its setup task instead of
  debugging env vars.
- `0` without `mise.toml`: you are outside a project root.

## Fix: wrap the outermost command

Prefix the outermost command once with `mise exec --`:

```bash
mise exec -- pnpm test
```

`mise exec` overrides exported variables and propagates into child scripts and processes.

## Boundaries and precedence

- `mise exec` fixes environment variables, not `PATH`. Fix shell activation for `command not found`.
- `mise exec` applies only inside a `mise` project. Outside one, inherited values pass through: it
  fixes wrong values, never reports missing ones.
- `uv run --env-file` has opposite precedence: exported variables shadow the file.
- Prefer the project script runner (`pnpm <script>`, `just`, `make`) over `npx` or direct binaries
  because scripts carry required flags such as `TZ`.
