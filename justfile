# Cross-platform task runner for humans and agents. `just --list` shows every
# recipe. Keep each recipe a thin call to a portable tool or a script under
# scripts/. See https://github.com/simpsonm09-projects/repo-standard/blob/main/docs/task-runner.md
set windows-shell := ["powershell.exe", "-NoLogo", "-NoProfile", "-Command"]

# List the recipes.
default:
    @just --list

# Install the pinned tools.
install:
    mise install

# Install the JavaScript dependencies from the lockfile.
deps:
    mise exec -- bun install --frozen-lockfile

# Format JavaScript and TypeScript with Bun.
fmt:
    mise exec -- bun fmt src tests scripts public/app.js

# Check JavaScript and TypeScript formatting with Bun.
fmt-check:
    mise exec -- bun fmt --check src tests scripts public/app.js

# Type check the repository scripts with Bun.
typecheck:
    mise exec -- bun check

# Lint JavaScript and TypeScript, through Bun with an oxlint fallback.
lint:
    mise exec -- bun scripts/lint.ts

# Run the AI-slop gate.
aislop:
    npx --yes aislop@0.16.1 ci

# Run the test suite.
test:
    mise exec -- bun test

# Run only the tests the pull request diff can reach.
test-changed:
    mise exec -- bun scripts/test-changed.ts

# Run the tests and write an lcov report to coverage/lcov.info.
coverage:
    mise exec -- bun test --coverage --coverage-reporter=lcov --coverage-dir=coverage

# Regenerate docs/openapi.json from the route schemas.
spec:
    mise exec -- bun scripts/write-openapi.mjs

# Fail when the generated API document differs from the code.
spec-check:
    mise exec -- bun scripts/write-openapi.mjs
    git diff --exit-code -- docs/openapi.json

# Everything CI requires.
check: fmt-check lint typecheck test spec-check

# Install the guarded git hook.
hooks:
    git config --local core.hooksPath .githooks

# Check the .agents/skills tree and its .claude/skills links.
agent-files:
    mise exec -- bun scripts/agent-files.mjs

# Serve the calculator on http://127.0.0.1:8000 without a container.
serve:
    mise exec -- node src/server.js --host 127.0.0.1 --port 8000

# Build the container image.
docker-build:
    docker build -t browser-calculator:local .

# Run the container on http://localhost:8000.
docker-run:
    docker run --rm -p 8000:8000 browser-calculator:local

# Prune remote-tracking refs and delete local branches merged into main.
prune:
    mise exec -- bun scripts/prune.mjs
