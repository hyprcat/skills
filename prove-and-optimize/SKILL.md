---
name: prove-and-optimize
description: Take everything you touch to its floor. Measure where every millisecond, byte, token and dollar goes, prove the least the work can cost, prove which work the real workload makes unnecessary and delete it, guard that, and verify it. Uses Lean 4 to prove floors, impossibility and that a fast path is safe under an invariant. Use it whenever you design, plan, build, write, change, review or debug code, and above all on anything with latency, throughput, cost, memory, tokens, I/O, network, a database, a loop, an agent's turn or a build. Use it too whenever someone says faster, cheaper, slow, optimize, bottleneck, floor, bound, optimal, provably, mathematically, Lean or "break it down", or asks whether a target is reachable. Use it even when performance isn't mentioned, because every change is a chance to remove work.
---

# Prove, then optimize

**The idea** (from "Lean vs $12 server", the fastest entry in a one-vCPU server challenge): describe how the system
should work, prove what's true of the data it really sees, and use the proofs to skip work a general engine always
does. Posts were already stored newest first, so the feed needed no sort and no query plan. The code read SQLite's
B-tree directly, and a feed went from 16.7 µs to 5.4 µs. The shortcut could be written by hand; the proof is what makes
it safe to keep.

**The goal on every change:** leave the path you touched at its floor, or know exactly what stands between it and the
floor, in measured numbers, and whose it is.

## Rules

- **Measured or proven, never guessed.** No estimated savings, no effort hours, no "should be faster". Where a number
  isn't known, measure it, make the claim hold for every value it could take, or say what would measure it. A guess
  in a plan turns a proof into an opinion.
- **The best optimisation deletes work.** Caches, streams, threads and new layers come last, and only after proving
  what they can save at most. Overlap saves at most the overlapped part. A streaming path built for an agent could
  save 4 ms at the median, which a two-line theorem showed before anyone needed to build it.
- **Name the objective and the class.** Fastest at what, measured how, among which designs. Means add and medians
  don't. A metric that can be gamed isn't the objective: splitting a run into more turns lowers the mean turn time
  and slows the run.
- **The invariant belongs to the workload, not the benchmark.** A fast path that holds only for the tasks, apps or
  inputs in the test set is hardcoding. State the invariant over every input the system will really see; if it names
  a task, an app or a string from the bench, it's wrong. The owner caught bench-tuned cuts in mini-cua (2026-11-06).
- **Fix the cause where every caller goes through.** Measured waste is usually a symptom. An agent was wasting 9.6 s
  starting a new process per check; the cause was a validator that judged checks by their text, which pushed it there.

## Building something new

With nothing to measure yet, start from the floor instead of a number, in the video's order:

1. **Break it down** into the units the user will feel (a request, a turn, a frame, a build) and what each must do.
2. **Write what's true of the data** each unit will really see: its order, size, who writes it, how often it changes.
3. **Find each unit's floor** as in step 3 of the loop below.
4. **Design the path that does only floor work.** Every step above the floor takes one of the cuts in step 5, or
   states why none applies.
5. **Prove and guard the invariants** the design leans on, then build, measure, and compare against the floor.

## The loop, every time

1. **Objective.** Pick the cost the user feels (wall time of the whole task, p50 or p99, money, memory) and write down
   its current measured value.
2. **Account for every unit.** Read what the system already records (logs, journals, traces, timestamps, file mtimes)
   before adding instrumentation, and check one clock against another before trusting it. Instrument where the split
   is unknown: for a request, when it was sent, when its headers and first useful byte came, when it ended, the bytes,
   and the server's own timing headers. Put each part in one of three bins: the work itself, someone else's latency
   (network, disk, another service, a model), or ours (overhead, waits, repeats).
3. **Find the floor:** what any implementation must pay. That's the data dependencies (nothing can use an answer before
   it arrives), physics (a round trip), and others' service times, taken at the least seen, never the median. Keep it
   conservative: anything that might be ours counts zero, so a claim that something is impossible survives scrutiny.
   When the floor decides the direction (is the target reachable, what must a vendor change), prove it in Lean.
4. **List the waste:** everything above the floor, by measured size.
5. **Cut it,** each cut justified by an invariant, in this order:
   1. **Don't do it.** The workload makes it unnecessary (the table below).
   2. **Do it once.** Reuse an answer nothing has invalidated, keep one process up, let one pass answer two questions.
   3. **Do it at the right layer.** When the access path is fixed, call the layer under the generic engine.
   4. **Do it alongside other work,** only when independent, and only after proving the cap.
   5. **Do less of it.** Fewer bytes, tokens, rows, nodes.
   6. **Do it faster.** A better algorithm, data structure or native path.
6. **Guard the invariant.** A proof covers a model, so enforce the invariant where it could break: prove the write path
   keeps it, and add a runtime check or a test where the code could drift from the model.
7. **Verify.** Write a test that fails before the change and passes after. Existing checks must be identical except
   for the intended difference. Then measure the objective again.
8. **Report.** Lead with the measured result and the floor, with theorem names inline and premises in words. Say
   what's left above the floor, and whose it is.

## Work the workload makes unnecessary

| When this holds | This work goes | Seen |
|---|---|---|
| Data is stored in the order needed | the sort, the ordering, the query plan | the video: newest posts read straight off the B-tree |
| Nothing has written since the last read | the re-read | 22 identical reads, 2.8 s in one benchmark |
| A long-lived process can serve repeat requests | starting one per call | a new `osascript` per check, 129-434 ms, against 5-25 ms |
| Every possible answer leads to the same next step | waiting for the answer | acting ahead while a reply is still coming |
| One pass can collect both answers | the second pass | one tree walk instead of two |
| What's being waited for gives a signal | fixed sleeps, "safe" timeouts, coarse polling | waiting on the target itself |
| The access path is fixed | the generic engine around it | SQLite's B-tree API, a native exec |
| A rule judged by text can be judged by behaviour | false rejections forcing a slow detour | a check that read through a helper was rejected |

## Lean: when, and how

Use Lean when an optimisation rests on an invariant that's easy to get subtly wrong. Examples are ordering,
uniqueness, no write since a read, independence for overlap, and idempotence. Use it too when the question is whether
a target is reachable at all, or which order or choice is optimal. The shape is the video's: a reference that does the
general work, a fast path that skips it, a proof that they agree under the invariant, and a proof that every write
keeps the invariant. Skip Lean where the code and a test already make safety plain: the proof has to pay for itself too.

Read [references/lean.md](references/lean.md) before writing Lean: setup, the patterns, the gotchas that cost time,
and the checks before claiming anything. [references/patterns.lean](references/patterns.lean) holds the same patterns
as one file that builds.

## Repos with their own setup

- If `references/<repo>.md` exists here for the repo you are in (or the repo a worktree belongs to), read it first:
  it says where that repo's proofs and measurements are, its helper script, and the owner's standing rules. These
  notes are private and are not part of the published skill.
