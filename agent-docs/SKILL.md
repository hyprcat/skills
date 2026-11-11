---
name: agent-docs
description: Write and maintain Affan's CLAUDE.md files in his house shape, with AGENTS.md as a symlink so Claude Code and Codex read the same file. A short purpose and read order, the repo's working rules, commands each with a reason, facts and traps dated and recorded the day they bite, and per-package CLAUDE.md files. Use when creating or updating a CLAUDE.md or AGENTS.md, setting a repo up for agents, recording a gotcha, trap, lesson or fact the next agent needs, or when he says "add this to CLAUDE.md", "remember this for the repo", "write it down", or "get my coding standards into this repo".
---

# Agent docs

Every repo of his has a CLAUDE.md (21 of them). It holds what an agent can't get from the code: rules, commands
and traps. It doesn't hold product rationale, architecture tours, or history git already has.

## Shape

````markdown
# CLAUDE.md

One paragraph: what this is, and what to read first (README, then spec/ or context/). Name any package
whose own CLAUDE.md governs it.

## Working rules (non-negotiable)

- Shared rules: every line earns its place, plain words, max 500 lines per file, max 6 entries per folder.
  Affan edits files on disk mid-session; his edits are canon, never revert them.
- <the rules this repo adds or changes>

## Commands

```sh
<command>              # why and when to run it
```

## Facts (checked YYYY-MM-DD)

- **<The claim.>** <What was seen, and why it matters.>
````

Add these sections only when they have content: Budgets (a table of measured targets), Decisions (don't
relitigate), Banned, Verification, Commits.

## Rules

- AGENTS.md is a symlink: `ln -s CLAUDE.md AGENTS.md`, as in chatsapp, instinct-memory, phone-use and super-agent.
  Never keep two hand-synced copies.
- Keep the standards to the one "Shared rules" line, because teammates' agents don't have these skills. Spell out
  only what this repo adds or overrides ("7 entries per folder here", "no function cap").
- A fact or trap goes in the day it bites, with the date and what was seen: "Nothing speculative, nothing already
  in git history."
- Each fact can be checked: a bold claim, then the symptom and the cause. Example: "**Ad-hoc signatures change every
  build**, so macOS drops the TCC grants; dev builds sign with the stable self-signed identity."
- Every command has a trailing `# why`, all in one fenced block, and each one has been run once to be sure it works.
- Every line earns its place: if an agent wouldn't act differently without a line, cut it. Plain words.
- A package with its own rules or commands gets its own CLAUDE.md, and the root one names it.
- Stay under 500 lines. When facts pile up, re-check the old ones and drop those that no longer hold before adding more.

## Writing a new one

1. Read the README, the spec or context folder, the build files, and `git log -30` for what keeps breaking.
2. Write the purpose and read order, the repo's own rules, the commands (run each once), and the facts you verified today.
3. `ln -s CLAUDE.md AGENTS.md`. If an AGENTS.md already exists with its own content, merge that into CLAUDE.md first.
