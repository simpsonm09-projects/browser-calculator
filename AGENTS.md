# browser-calculator working agreements

A Fastify service and a static page that evaluate arithmetic. `repo-template` is the reference repository for the standard; this one is a Fastify feature service.

## Ground rules

- The evaluator is the security boundary. It accepts numbers, `+ - * / % **`, parentheses, and unary `+` and `-`. Never add a feature that lets an expression run code or touch the host.
- Keep the container image small and the server dependency list short.
- The form route is stateless. Keep state per request.
- No secret, credential, or machine path is committed.

## Commands

- `just install`, `just deps`, `just fmt-check`, `just lint`, `just typecheck`, `just test`, `just coverage`, `just spec`, `just check`, `just agent-files`.
- `just docker-build` and `just docker-run` build and run the image.

## Repo facts

- Language and toolchain: Node 26, Fastify 5, plain ESM JavaScript. Bun 1.4.5 formats, lints, type checks the scripts and runs the tests (`bun fmt`, oxlint, `bun check`, `bun test`); versions pin in `mise.toml` and the lockfile is `bun.lock`. The container runs Node.
- Data: no database. State is per request.
- Domain: the page sends an expression to `POST /api/evaluate`. The server parses it with the safe evaluator in `src/evaluator.js` and returns the number. The page posts a form to `POST /api/tools/form`, which validates and acknowledges it.
- Contracts: `docs/openapi.json` is generated from the route schemas. Regenerate it with `just spec`; do not hand-edit it.
- Docs: `docs/README.md` indexes the architecture, the calculator feature, the form feature, and the OpenAPI contract.
- Skills: the `verify` skill lives in `.agents/skills/verify`; `.claude/skills/verify` is its relative symlink. `just agent-files` checks the pair.
- Hooks: `just hooks` installs the shared Lefthook jobs from `simpsonm09-projects/.github` at the `hooks-v2` tag; `lefthook-local.yml` is git-ignored. Never skip a hook: no `LEFTHOOK=0`, no `--no-verify`, and never create `lefthook-local.yml` (C7.11). The ruleset is the real gate.

## Skills

`.agents/skills/verify/` drives the app end to end. General best practices and integration come from the plugins.
