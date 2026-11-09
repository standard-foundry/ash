<!--
SPDX-FileCopyrightText: 2019 ash contributors <https://github.com/ash-project/ash/graphs/contributors>

SPDX-License-Identifier: MIT
-->

# AGENTS.md

This file guides Claude Code in this repository: a fork of the
[Ash Framework](https://github.com/ash-project/ash) core library.

## About Me

I am an expert programmer. When you do not know something, or where to look, ask me first.

## Critical Rules

- NEVER commit, push, or open issues or PRs unless I tell you to.
- Run `mix check` after code changes. Work is not complete until it passes with zero warnings.
- Read the docs before you use a feature. Do not assume prior knowledge of Ash or Spark. Read
  the guides under `documentation/`, the source under `deps/`, or run `h Module.fun` in `iex -S mix`.

## Working Style

- Delegate long-output commands (`mix check`, `mix test`, `mix compile`) and broad codebase
  searches to sub-agents. Report only pass/fail and the key failures or findings.
- Run small, single-shot actions inline.
- New code follows the nearest existing precedent in the repo. Find it first.

## Commands

```bash
mix deps.get
mix test                         # full suite; no database needed (ETS + Mnesia data layers)
mix test test/path_test.exs:42   # one test
mix check                        # everything CI runs, configured by .check.exs
mix format                       # aliased to `format --migrate`
mix credo                        # aliased to `credo --strict`
mix spark.formatter              # update locals_without_parens after DSL changes
mix spark.cheat_sheets           # regenerate documentation/dsls/ after DSL changes
mix docs
```

`mix check` includes `mix spark.formatter --check`, `mix spark.cheat_sheets --check`, and
`reuse lint` (through `pipx`). It does **not** run Dialyzer, though `CONTRIBUTING.md` says it does.
CI also runs these, so run them before calling work done:

```bash
mix compile --warnings-as-errors && MIX_ENV=test mix compile --warnings-as-errors
mix dialyzer
mix deps.unlock --check-unused
mix sobelow --skip --exit low
```

Tests use Picosat by default. Run `SAT_SOLVER=SimpleSat mix test` to cover the other solver.

## Conventions

- **Commits:** prefix with `fix:`, `improvement:`, `test:`, `docs:` or `chore:`, as upstream does.
  `git_ops` builds `CHANGELOG.md` from them at release time, so never edit the changelog by hand.
  CI fails a PR that adds an `## [Unreleased]` section.
- **PRs:** a bug fix needs a regression test, and a feature needs tests. The upstream
  [AI policy](https://github.com/ash-project/.github/blob/main/AI_POLICY.md) requires a human to
  take part in PR and issue discussions, so never post a comment or review on GitHub.
- **License headers:** every new file needs an SPDX header (REUSE compliance). Copy it from a
  neighbouring file of the same type, or add a `<file>.license` sidecar when the format has no
  comments.
- **DSL docs are generated:** `documentation/dsls/*.md` comes from the DSL definition modules such
  as `lib/ash/resource/dsl.ex`. Edit the source, then run `mix spark.cheat_sheets`.
- **Usage rules:** `usage-rules.md` and `usage-rules/*.md` ship to Ash users. Update them when a
  change alters the guidance they give.
- **Tests:** use the ETS data layer and the shared resources under `test/support/`.
- See `.github/CONTRIBUTING.md` for the upstream contribution process.

## Fork Workflow

`origin` is our fork and `upstream` is `ash-project/ash`. The `devcontainer` branch holds
fork-only files (`.devcontainer/`, `AGENTS.md`, `.claude/`) that must never reach upstream.

- Branch upstream PRs from `upstream/main`, never from `devcontainer`:
  `git fetch upstream && git switch -c fix/whatever upstream/main`
- Then restore the fork-only files untracked:
  `git restore --source=devcontainer -- .devcontainer AGENTS.md .claude`
  `.git/info/exclude` and `.gitignore` keep them out of `git add -A`.
- Change these files only on `devcontainer`, and commit them there.

## Layout

- `lib/ash/` — core: `resource/`, `domain/`, `query/`, `changeset/`, `actions/`, `policy/`,
  `data_layer/` (ETS, Mnesia, Simple), `reactor/`, `type/`
- `lib/mix/tasks/` — `mix ash.*` tasks and Igniter installers
- `documentation/` — guides (`topics/`, `tutorials/`, `how-to/`) and generated DSL references
- `test/` — mirrors `lib/`; shared resources in `test/support/`
