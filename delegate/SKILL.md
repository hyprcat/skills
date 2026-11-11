---
name: delegate
description: Run big or long work the way Affan wants it. Break it down and plan first, then give fresh, tightly scoped sub-agents one change set each while the main agent orchestrates and checks, with no side quests, regressions or half-done pieces. Keep going unattended (overnight) with a progress file until it's truly done. Use when he says use sub-agents, opus-based agents, parallelise, fan out, plan this carefully, don't stop until done, keep working, keep tuning overnight or I'm going to sleep; when a task is too big for one context; and before a compaction he announces ("dump anything valuable").
---

# Delegate

"Plan this approach carefully and use opus-based sub-agents to carefully implement this without causing
regressions" (268 prompts, 27 projects). But also "Do it yourself. Kill the sub-agent": delegation is for work that's
big or parallel, not for a two-line fix.

## Plan before anyone writes code

"Why did you dive right into implementation?"

1. Break the task down as in prove-and-optimize's "Building something new": the units, what each must do, its floor.
2. Split it into change sets that don't touch the same files. Each gets a goal, the files it owns, what's off limits,
   the checks it must pass, and how it reports.
3. Show the plan first when he asked to design or propose. Otherwise start.

## Running agents

- The orchestrator plans, briefs, reads results and checks them. It doesn't edit code that agents are working on
  (memfold-computer: the root agent only orchestrates).
- A fresh agent per change set. Don't resume one long-lived agent across sets (cua-gen-ui-mobile).
- The brief is all an agent knows. Include:
  - the goal
  - the files it owns, and the ones that are off limits
  - the standards it follows: name the coding-standards and agent-design skills
  - what's already ruled out
  - the check it must pass
  - "report what you verified and what you didn't"
- No side quests. Work outside an agent's brief gets checked or reverted, not merged. ("What are your sub-agents
  doing? Are they on their own side quests?")
- The strongest model for design and hard changes; a fast one for searches and mechanical sweeps.
- Independent sets run in parallel, launched together. Sets that share files run in order.
- Check each result yourself before building on it: read the diff, run the gate, run the real thing (verify). An
  agent's summary is a claim, not a result.
- Run the full gate after each set lands, not only at the end, so a regression has one suspect.
- When he says another session holds the context ("talk to the other agent"), message that session rather than
  re-deriving what it knows.

## Unattended

"I am going to sleep. Keep on working on it and keep perfecting everything."

- Keep a progress file (`context/progress-YYYY-MM-DD.md`, or the repo's tracker). It holds the goal, the plan, each
  set's state, the measured numbers after each round, and what's blocked and why.
- Don't stop at the first green. Work down the plan, then keep improving the measured result until the goal is met
  or every remaining path is blocked. No v1/v2 and no phases left for later.
- Don't wait on questions nobody is there to answer. Take the sensible default, note it in the progress file and keep
  going. Stop only before something irreversible or outward-facing (spending money, sending messages, deleting data,
  deploying to production) and leave it for the morning.
- Live runs on his Mac only if he said so, with messaging apps blocked (`CUA_BLOCK_MESSAGING=1` where it exists).
- By morning the progress file ends in a one-screen summary: what's done and how it was verified, the numbers before
  and after, and what's left.

## Before a compaction

When he says he's about to compact, write everything a fresh context needs into the progress file: decisions, what's
done, what's next, traps found. Then give him its path.
