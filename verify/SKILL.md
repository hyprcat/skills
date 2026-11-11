---
name: verify
description: Prove work is really done before saying so, the way Affan checks it. Hunt stubs, hardcoding, half-done paths and regressions in the diff, make sure the running build is the fresh one, run the real thing, read its logs, measure against the target, and report plainly what was checked and what wasn't. Use before saying done, finished, fixed, works or ready; after any build, fix, feature or agent run; and whenever Affan asks to verify, check, test it, make sure, "no stubs", "half-assed", "did you rebuild", "is it actually working", "check the logs", or doubts a result.
---

# Verify

Agents claim done falsely. Done means you saw the outcome yourself, on the fresh build, and said what you didn't
check. Seven of his repos write this down, and "verify no stubs or half-assed implementations" comes up in 231
prompts across 32 projects.

## 1. The diff

- Read `git diff` and the untracked files against what was asked. Every changed line traces to the request, and
  nothing else was touched.
- Stubs: run `bash ~/.claude/skills/coding-standards/scripts/check-structure.sh`. Also read the diff for placeholder
  returns, empty catch blocks, `return []` or `null` standing in for real work, mocks outside tests, and words like
  "for now", "simplified", "v1", "phase 2".
- Hardcoding: look for literal app names, task names, benchmark items, URLs, ports, `/Users/...` paths, model names
  and magic numbers. Each belongs in config or a named constant with its reason, or it's a bug.
- Regressions: the repo's existing checks pass, identical to before except for the intended difference.

## 2. The build that's running

"Did you rebuild? It seems like I am using a stale build again" (80 prompts, 12 projects).

- Rebuild after every source or prompt change. A prompt compiled in with `include_str!` needs a rebuild too.
- Prove the running process is the new build: it started after the binary was written (the relaunch skill's
  `fresh-app.sh` checks this), or the version or commit it reports matches HEAD. For a deployed service, the
  deployed commit is the one you pushed.
- Restart whatever holds the old code: the app, its helper or launchd job, the dev server, the MCP server a client
  spawned.

## 3. The real thing

- Run it the way the person will: the app from its bundle, the CLI with real input, the page in a browser, the agent
  on a real task. Ask before a live run that drives Affan's Mac.
- Look at the outcome yourself: a screenshot, the file it wrote, the row in the database, the message that arrived.
  Never the model's or agent's final line.
- Check the scenario really happened. A test that passed because nothing ran is a failure.
- Fakes aren't evidence: no mocks or stub services in a verification run.

## 4. The logs

- Read the logs of the run you just did, not only its exit status: errors, warnings, retries, slow steps, anything
  that passed with an error beside it. A poll loop that outlived shutdown once passed every check.
- Where they are: the repo's CLAUDE.md, else the run's own directory,
  `log show --last 10m --predicate 'subsystem == "<id>"'` for an OSLog app, the dev server's output file, or the
  platform's (`vercel logs`, `kubectl logs`).
- Never pipe a long run through `tail`, which buffers. Write to a file and read the file.

## 5. The number

- When there's a target (latency, size, score, cost), measure it now and give it beside the target and the floor
  (prove-and-optimize). "Should be faster" isn't a result.
- Flaky is a finding. A check that fails 1 run in 10 has a bug behind it: loop it until you know.

## Report

Lead with the outcome in one line, then:
- **Checked:** what ran, how, and what you saw, with paths to the screenshots, logs and numbers.
- **Not checked:** what you couldn't run or see, and why.
- **Found:** anything wrong you didn't fix.

If it didn't run, say it didn't run.
