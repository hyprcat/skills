# Scope: what Affan repeats across repos (2026-11-07)

Sources: 18 own-written CLAUDE.md/AGENTS.md, `research_notes/coding_standards.md` (2026-10-09), `event-games/specs/CONVENTIONS.md`,
16.9k Claude prompts over 82 projects + 396 Codex prompts, CI/tooling of 26 own repos. Forks and the ~30 `ocu-*`/`*-pr*` worktree copies are excluded.
Counts are "repos" for instruction files, "prompts / projects" for history (keyword-clustered, close estimates).

## Rules you keep writing down
| Rule | Evidence |
|---|---|
| ≤500 lines/file, ≤6 entries/folder (7 in older repos), ≤30 lines/function | 9 repos; 3 enforce via `scripts/check-structure.sh` or CI shell |
| Every line earns its place: "If you cannot state what breaks without a line, delete it." Plain words, no buzzwords | 7 repos |
| No stubs, TODOs, v1/v2, flags parking unfinished work | event-games, alma-dictation; 231 prompts / 32 projects |
| No hardcoding | 119 prompts / 18 projects |
| Don't overcomplicate; no abstraction with one implementation | 5 repos; 109 prompts / 26 projects |
| Platform → existing code → dependency (justified) | 5 repos |
| Root cause; defensive/mechanical patches need approval | 4 repos |
| Verify the real outcome yourself; say what wasn't verified | 7 repos |
| Spec/doc is the authority, updated in the same commit; decided = don't relitigate | 7 repos |
| Secrets never in repo, logs, output | 7 repos |
| Never edit vendored/upstream in place | 6 repos |
| Owner's edits are canon; never stage or revert unrelated dirty work | 5 repos; "only commit the edits you made yourself" |
| Fix agent behaviour in prompts before code | 5 repos |
| Perf/latency budgets are gates; a change that doesn't win is reverted | 5 repos |
| Comments say why, never what | 5 repos |
| Live runs drive the real Mac: ask first; never global keystrokes, never kill by bare name | 4 + 4 repos |
| Gates warning-free | 5 repos |
| Facts/Traps section, dated ("checked 2026-10-25"), recorded the day it bites | 10 repos |
| AGENTS.md is a symlink to CLAUDE.md | chatsapp, instinct-memory, phone-use, super-agent (my-page reversed) |
| UI: design tokens only, one accent, no raw hex; real assets logged in CREDITS.md; no AI-slop | 4 repos |
| Copy: no marketing words, no em-dashes/semicolons in visible copy, no "Not X. Y." flips; compact layouts | www |

## Workflows you keep typing
| Workflow | Prompts / projects |
|---|---|
| UI iteration from screenshots / reference ("make it like this") | 536 / 42 |
| Run it and show me (launch, screenshot, video) | 448 / 48 |
| Kill stale processes, rebuild, reinstall, relaunch; DMG builds | 399 / 32 (DMG 112 / 8) |
| PR handling: checkout PR N, read comments, fold in, merge, deploy | 348 / 26 |
| Use LiteLLM proxy (`LITELLM_KEY`, `https://litellm.memfold.ai/v1`), "we don't use ollama" | 336 / 35; 16 repos |
| Fan out to sub-agents; overnight "keep going until done" | 268 / 27; 57 / 19 |
| Use another local repo as reference | 257 / 49 |
| Enforce my coding standards (full list re-typed ~8×) | 274 / 32 |
| Check the logs | 251 / 32 |
| Commit and push | 245 / 25 |
| Deploy (Vercel, Azure, Cloudflare, AWS) | 157 / 21 |
| Design/propose before coding ("why did you dive into implementation?") | 76 / 19 |

Frustrations that should become rules: stale builds (80 / 12), scope creep and regressions (132 / 28), doing the work instead of sub-agents (20 / 9), running unknown things, acting without asking.

## Tooling defaults
- TS: ESM, npm + package-lock (11 repos; pnpm 2, bun 1), Node runs `.ts` directly, `strict`+`noEmit`+`erasableSyntaxOnly`, `check` = `tsc -p .`, `node --test`.
- Rust: edition 2021, `lto = "thin"`, tiny dep set, hand-parsed args, `Result<_, String>` in newest code, JSON-line events.
- Swift 6 strict concurrency, SwiftPM, macOS 15+, OSLog, Liquid Glass behind `#available(macOS 26)`.
- Python: uv, 3.13, ruff, pytest. Websites: Astro.
- Shell: `set -euo pipefail`; `scripts/{build-app,make-dmg,ci,check-structure}.sh`.
- No lint/format configs anywhere; rules live in CLAUDE.md and are enforced by scripts + AI review.
- CI: one gate script (`scripts/ci.sh <lane>`), steps named as claims, LLM PR review via LiteLLM that comments and never blocks.
- Commits: behaviour-first subject. Newest repos `area: outcome sentence`; older/infra Conventional Commits. Co-Authored-By trailer. Branches `feat/ fix/ claude/ codex/ cask/vX deploy/`.

## Conflicts (default = newest)
Folder cap 6 vs 7 → 6. Commit style → match the repo's log, `area: sentence` in new repos. Comments: `//!`+`///` everywhere (Oct) vs none (alma-dictation) → match repo. Tests: build + verified live run (new) vs suites (product repos) → match repo.

## Already covered (don't duplicate)
ponytail (laziness/review/audit), ralph-skills (prd/ralph), frontend-design, grill-me, built-ins `code-review`, `simplify`, `init`, `run`, `security-review`.

## Skills (all built by 2026-11-08; `./install.sh` links them into ~/.claude/skills and ~/.agents/skills)
0. **prove-and-optimize** (in this repo since 2026-11-07, symlinked into `~/.claude/skills` and `~/.agents/skills`): the lens every
   other skill applies. Break the work into units, find each unit's floor, delete what the real workload makes unnecessary,
   prove the invariants (Lean 4 where they're easy to get wrong), measure against the floor. Used 7× via slash since 11-06
   (mini-cua, mini-cua-bench, super-agent), plus Lean/"prove it's optimal" prompts since 11-05. How the others use it:
   `standards` makes the loop the default for every change; `delegate` breaks the plan down to units with floors before
   spawning anyone; `verify` reports the measured number against the floor; `taste` treats page weight and frame cost as gates.
1. **coding-standards** (built 2026-11-07): the house rules above, separation of concerns,
   `references/languages.md`, bundled `scripts/check-structure.sh` (from instinct-memory's, plus the EOF-function fix and stubs).
1b. **agent-design** (built 2026-11-07): how agents are built, from creator-agent, mini-cua, super-agent.
2. **verify**: done means done. Hunt stubs/hardcoding/half-done paths, confirm a fresh build is what's running, run it, read the logs, report checked vs unverified.
3. **relaunch**: kill stale processes by PID/bundle path, rebuild, reinstall, launch from the app bundle (TCC trap), prove it's the new build, screenshot.
4. **ship**: surgical commit (own edits only, one concern per commit, house message style), push, PR checkout/review/fold-in/merge, deploy via the repo's own script.
5. **agent-docs**: house CLAUDE.md shape (purpose + read order, Working rules, Commands with `# why`, Facts (checked DATE), Traps), AGENTS.md symlink, per-package files.
6. **litellm**: call models through the proxy; env var, base URL, model listing, no local model servers.
7. **macos-dmg**: build-app → codesign (self-signed or Developer ID) → optional notarize → DMG → GitHub release/cask.
8. **delegate**: plan first, fresh tightly scoped sub-agents per change set, orchestrator doesn't edit, verify each result, keep going overnight with a progress file.
9. **taste**: UI from a reference screenshot, existing tokens/aesthetic, copy rules, real assets + CREDITS.md. Complements frontend-design.

Skipped: invite-teammate (one `gh api` call), status/continue (built-in), benchmark loop (one project), repo map (goes stale).
