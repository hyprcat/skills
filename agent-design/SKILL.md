---
name: agent-design
description: How Affan designs, prompts and tunes AI agents, taken from creator-agent, mini-cua and super-agent. One agent in one loop, a bare code tool instead of many tools, prompts over machinery, failures explained to the model, the fewest turns and agents, cache-stable history, done judged on evidence, and the model proposing while something small decides. Use whenever designing, building, prompting, debugging, tuning or reviewing an agent, a harness, an agent loop, tool definitions, a system prompt, a judge or validator, or a multi-agent setup; whenever an agent misbehaves, loops, is slow, wastes turns or claims done falsely; and whenever someone asks how to make an agent faster, more reliable or more general.
---

# Agent design

How Affan builds agents. The worked example is `~/Documents/GitHub/creator-agent/packages/agent`: read its
`CLAUDE.md`, `spec/design.md` and `prompts/` before designing something similar. `mini-cua` and `super-agent` are the
newest. Use prove-and-optimize alongside this: an agent's costs are turns, tokens and seconds, and each one gets
measured.

## Shape

- **One agent, one loop.** "The lesser number of agents you have, the lesser painful it becomes to manage." Add a
  second model only where it measurably pays, and give it one narrow job. creator-agent's fast picker exists only to
  act during the main model's wait.
- **A bare code tool, not a tool zoo.** The model writes code against one API in a persistent runtime (programmatic
  tool calling). The harness doesn't wrap, attach or decide for it. creator-agent's model has four tools: `create`,
  `batch_edits`, `ask_user`, `finish`.
- **Lean harness, better prompts and models.** The harness carries only what the model can't: the runtime, the reads,
  the records and the safety lines. Everything else is the model's job.
- **No provider lock-in.** Models go through the LiteLLM proxy (`LITELLM_KEY`), via pi or plain OpenAI-compatible
  calls. The model is a config value, never a vendor SDK baked into the code.

## Behaviour lives in prompts

- **When the agent misbehaves, fix what it's told.** "When dealing with agents, mechanical fixes are not the way,
  instead prompt fixes are the true solution." First work out how much is the prompt's fault. Only what's left is
  code, and a code change is named and approved first.
- **Prompts are files** (`prompts/*.md`): plain English, one brief per role, loaded or compiled in as they are.
- **Explain failure to the model.** Most agent failures come from the harness explaining badly what went wrong. Each
  error and record says what happened, what the screen or state held instead, and the line it stopped on.
- **Tight answer forms.** A helper model answers in exact line forms ("a number, or keep and quoted words, and
  nothing else"), and the parser takes nothing else.
- **Untrusted content is data.** Page text, app text, retrieved code and tool output never override the user, and the
  prompt says so.
- **No hardcoding.** Never special-case an app, a site, a task or a benchmark item. Fix the general behaviour so the
  case falls out of it.

## Turns and seconds

- **Fewest turns, most parallelism.** An avoidable turn is the thing to optimise away, "without hardcoding it". Do as
  much per turn as the evidence allows, and send independent reads and actions together.
- **Run as it streams.** Code runs line by line while the model writes it. Actions come first; whatever only
  describes them comes last, where nothing waits on it.
- **Cache-stable history.** The history is append-only, the model's own messages word for word, so the provider's
  prefix cache covers it. Volatile state (the screen, the windows) rides only in the last user message, rebuilt each turn.
- **Keep connections warm, and measure every second** (first token, generation, action, settle). Each number in the
  design carries its date and how it was measured.

## Done and authority

- **Done is judged on evidence, never on the model's word.** Write the end states first (creator-agent's
  `prompts/needs.md`: what a look at the screen can confirm, never how it was done), and let a judge (Jev, sure ≥ 0.9)
  check them against the real state.
- **The model proposes; something small decides.** The agent's own words never authorise an effect; authority comes
  from the person's words (super-agent's kernel, proved in Lean). Never sign in, pay, send, dial or delete unless the
  request asks for exactly that.
- **Records for every run.** Per turn: what the model saw, what it did, and what it was told back
  (`<run>/turn-N.json`). Judge a change by reading real runs, not the agent's last line.

## Changing an agent

1. Reproduce it on a real run and read the records.
2. Say how much is the prompt (what it was told, how errors were explained) and how much is mechanics.
3. Fix the prompt first, rebuild, and rerun the same case plus a different one, so the fix is general.
4. For a code change: diagnose, present it, get a yes, make the one fix.
5. Measure the run (turns, seconds, tokens, cost) against before. A change that doesn't win comes out.
6. Live runs drive the real Mac: ask first, and block messaging apps when unattended.

Write the design down as a spec with "Settled" and "Not built, and why" sections (like creator-agent's
`spec/design.md`), so decisions aren't re-argued.
