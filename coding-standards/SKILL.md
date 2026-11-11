---
name: coding-standards
description: Affan's coding standards for every repo. Don't be an idiot (no complexity for its own sake), don't reinvent the wheel, every line earns its place, no hardcoding, no stubs, good separation of concerns, max 500 lines per file, 6 entries per folder and 30 lines per function, root-cause fixes only, and how to work in his repos without stepping on his edits. Use whenever writing, changing, refactoring, reviewing or planning code in any of his repos, and whenever he says coding standards, my standards, bloat, hardcoding, overcomplicating, overengineering, stubs, half-assed, surgical, slop, or asks to check work against his standards.
---

# Coding standards

The list Affan has typed into prompts about eight times and copied into nine repos' CLAUDE.md. A repo's own
CLAUDE.md wins where it differs (an older repo may allow 7 entries per folder, or ban comments in code). Run every
change through prove-and-optimize as well: these rules say what to build, that one says how little it can cost.

## The rules

1. **Don't be an idiot.** "An idiot admires complexity. Don't be an idiot." Think from first principles, build the
   simplest thing that meets the bar: state the problem in one line, solve it, stop. No machinery for failures nobody
   has seen: no retries, tiers, fallbacks, thresholds, schema versions or feature flags.
2. **Don't reinvent the wheel.** The platform first, then code already in this repo or a sibling one, then a super
   reliable library used as it comes. Every new dependency earns its bytes, and the commit names it and why.
3. **Every line earns its place.** If you can't say what breaks without a line, delete it. Plain words, no invented
   metaphors, no buzzwords, in code and in prose.
4. **No hardcoding.** No values, app names, task names or strings baked into logic to make one case pass. Tuned
   constants are named, kept together per module, each with a line giving its measured reason. Deployment values come
   from environment variables with the product's prefix (`CUA_*`, `SUPER_AGENT_*`), listed in `.env.example`.
5. **No stubs.** No TODOs, `todo!()`, placeholder returns, mocks standing in for real behaviour, v1/v2 copies, or
   flags parking unfinished work. What ships works end to end.
6. **No abstraction with one implementation.** An interface, protocol or trait arrives with the second real
   implementation. No Manager/Provider/Factory triples, DI containers, event buses or builders.
7. **Fix the root cause.** Defensive or mechanical changes (patches, retries, process babysitting, logging added to
   chase a symptom) need Affan's yes. Diagnose first, reading the source or running a scratch experiment outside the
   repo, say what you found, then make the one real fix where every caller goes through.
8. **Performance from day 1.** Maximal performance, minimal bloat. Budgets (latency, memory, size) are gates: a
   change that doesn't win is reverted, not kept behind a flag.
9. **Separate concerns, maximally modular.** Each file and module has one job you can name in a few words. Things that
   change for different reasons live apart: what's shown and the logic behind it, the logic and its I/O, a format and
   its transport. Typed shapes at every boundary (zod in TS, serde in Rust, pydantic in Python). No module globals and
   no locks: state lives in objects built in one place and handed down.

## Structure caps

- 500 lines per code file, 6 entries (files and folders) per folder, 30 lines per function. The repo root, `packages/`
  and package roots are exempt; lockfiles and `vendor/` don't count.
- Near a cap, split along the real seam. Never squeeze lines to fit.
- Check from inside the repo: `bash ~/.claude/skills/coding-standards/scripts/check-structure.sh`. It also flags stub
  markers. A repo with other caps: `ENTRY_CAP=7 bash …` (also `FILE_CAP`, `FN_CAP`). Functions are measured in Rust
  and Python only.

## Style

- Names are plain domain words (`Run`, `Record`, `GatewayClient`), never pattern names (`RunManagerServiceImpl`).
- Comments say why, never what: no narration, no changelog comments. A deliberate shortcut gets a `ponytail:` comment
  naming its ceiling. Follow the repo's comment habit.
- Errors say what happened and what to do next, in readable words.
- Logs are structured (one JSON line per event) or the platform's own (OSLog). No debug prints left behind, and no
  logging added as incidental cleanup.
- Defaults per language (TS, Rust, Swift, Python, web, shell, CI): [references/languages.md](references/languages.md).
  Read it when starting a project or working in a language for the first time in a session.

## Working in Affan's repos

- His edits on disk are canon. Read the working tree before editing; never revert, restage or absorb changes you
  didn't make.
- Touch only what the task names. "Don't touch rest of the stuff."
- The spec or design doc is the authority; change it in the same commit as the code. A recorded decision isn't
  re-argued: disagree once, with evidence, then do what he decided.
- Never edit vendored or upstream code in place (`vendor/`, submodules, sibling checkouts). Integrate with it as it
  is, or carry a `.patch`.
- Secrets live in the environment, the Keychain or a secret store. Never in the repo, logs, results or your replies.
- Live runs drive his real Mac: ask first. Never post global keystrokes, never kill a process by bare name (use its PID
  or full path), leave other VMs and messaging apps alone.

## Before you say done

1. The caps script passes.
2. The repo's gate passes with no warnings (`tsc -p .`, `cargo check --all-targets`, `swift build`, `ruff check`).
3. Your diff has no hardcoded values, stubs, files you weren't asked to touch, or file doing more than one job.
4. You ran the real thing and looked at the outcome yourself, not at a model's last line.
5. You say what you checked and what you didn't.
