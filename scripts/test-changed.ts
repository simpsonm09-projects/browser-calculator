#!/usr/bin/env bun
// Run the tests the pull request diff can reach. A documentation-only diff runs
// nothing, a diff that maps to one source file runs that file's suite, and
// anything the map cannot place runs the full suite. `main` and the weekly
// schedule run `just test` instead. See the owner standard C5.2 and C5.3.
import { spawnSync } from "node:child_process";

interface Mapping {
  sources: string[];
  tests: string[];
}

const MAP: Mapping[] = [
  { sources: ["src/evaluator.js"], tests: ["tests/evaluator.test.js"] },
  {
    sources: ["src/app.js", "src/server.js", "public/"],
    tests: ["tests/api.test.js"],
  },
];
const IGNORED = /^(docs\/|\.github\/|.*\.md$)/;

function changedFiles(): string[] | null {
  const base = process.env.BASE ?? "origin/main";
  const result = spawnSync("git", ["diff", "--name-only", `${base}...HEAD`], {
    encoding: "utf8",
    windowsHide: true,
  });
  if (result.error || result.status !== 0) return null;
  return result.stdout
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);
}

function selected(files: string[]): string[] | null {
  const tests = new Set<string>();
  for (const file of files) {
    if (IGNORED.test(file)) continue;
    const match = MAP.find((entry) =>
      entry.sources.some(
        (source) => file === source || file.startsWith(source),
      ),
    );
    if (!match) return null;
    for (const test of match.tests) tests.add(test);
  }
  return [...tests];
}

function test(args: string[]): never {
  process.exit(
    spawnSync("bun", ["test", ...args], { stdio: "inherit", windowsHide: true })
      .status ?? 1,
  );
}

const files = changedFiles();
if (files === null) {
  process.stdout.write(
    "test-changed: cannot read the diff, running the full suite\n",
  );
  test([]);
}

const tests = selected(files ?? []);
if (tests !== null && tests.length === 0) {
  process.stdout.write(
    "test-changed: the diff reaches no test, nothing to run\n",
  );
  process.exit(0);
}

if (tests === null)
  process.stdout.write(
    "test-changed: the diff is not mapped, running the full suite\n",
  );
test(tests ?? []);
