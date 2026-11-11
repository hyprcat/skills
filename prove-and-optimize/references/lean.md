# Lean 4 for optimisation proofs

Everything here builds on Lean 4.35 core with no Mathlib, checked 2026-11-06. [patterns.lean](patterns.lean) is the
code as one file.

## Contents
- Setup
- Working loop
- Patterns
- Gotchas
- Checks before claiming

## Setup

- A repo with proofs already has `lakefile.toml` and `lean-toolchain`; work there. A new file must be imported from
  the root module (such as `MiniCua.lean`), or `lake build` never checks it.
- A new project: `lake +leanprover/lean4:v4.35.0 new proofs lib.toml`, then `lake build`. A plain `lake new` fails
  with "no default toolchain configured" when elan has no default, so pin the toolchain.
- Core is enough for arithmetic, lists, schedules and orderings. Add Mathlib only for a proof that needs it, since it
  costs a large download and long builds.
- If `elan` isn't installed, ask before installing it.

## Working loop

- Try lemmas and tactics in a scratch file outside the repo, then `cd proofs && lake env lean <scratch>/T.lean`.
  That file sees the project's modules without touching the repo.
- Look a lemma up with `#check @List.foo`. When a name is wrong, grep the toolchain's source:
  `~/.elan/toolchains/<toolchain>/src/lean/Init/Data/List/…`. For example, the sorted-list lemma is
  `List.mergeSort_of_pairwise`, not `mergeSort_of_sorted`.
- `lake build <Module>` for one file while iterating, `lake build` for all before claiming anything.

## Patterns

**1. Fast path equals reference under an invariant (the video's move).** Write the general computation and the
shortcut, prove they agree when the invariant holds, then prove the write path keeps it.
```lean
def feed (k : Nat) (posts : List Post) : List Post := (posts.mergeSort newerFirst).take k
def feedFast (k : Nat) (posts : List Post) : List Post := posts.take k
theorem feedFast_eq (k : Nat) (posts : List Post) (stored : posts.Pairwise fun a b => newerFirst a b) :
    feedFast k posts = feed k posts := by
  unfold feed feedFast
  rw [List.mergeSort_of_pairwise stored]
```
Then `insert_keeps` proves a new post with the newest time, put in front, keeps the list ordered.

**2. A lower bound against every schedule, and one schedule that meets it.** Write the dependencies as constraints on
start and end times, destructure them, and use `omega`. Reaching the bound shows it isn't loose.

**3. The exact saving, so a cap is a theorem.** `serial p - overlapped p = min p.write p.work`: overlap can never
save more than the smaller part. Prove this before building any concurrency.

**4. A median is a count.** For an odd count, "the median is within `B`" is `l.length < 2 * within B f l`, where
`within` counts the elements within `B` (`List.countP`). `within_mono` makes it monotone, so a lower bound on each
element gives a bound on the median. Do the same for each part: the median of a sum is within `B` only if every
part's median is.

**5. Measured data, with a claim for every unknown.** Embed the measured rows as a `List`, count them `by decide`,
and quantify over what you don't know: `∀ extra : Nat → Nat`, added to each row by its index through `zipIdx`. The
claim then holds however fast the unmeasured parts become (`whatever_we_add`).

**6. A mean is a sum.** Savings on a mean add exactly. A run is its turns times its mean, so prove what a split does to
both: one more turn lowers the mean and costs a turn's fixed part (`split_lowers_mean`).

**7. The best order, by exchange.** Prove that swapping two neighbours into ratio order never costs more. Then prove
the ordered list is least among all permutations by induction: split the other list at the head
(`List.append_of_mem`), peel it off (`List.perm_middle`, `List.Perm.cons_inv`), and bubble the head forward with the
swap. This is Smith's rule, `ratio_order_is_least`. Instantiate it only with measured weights and times.

## Gotchas

- `omega` handles `+`, truncated `-`, `*` and `/` by a literal, `%`, `min`, `max`, `∧ ∨ ¬ →`. A product of two
  variables becomes an opaque term, and `x * y` and `y * x` count as different. Distribute first
  (`simp only [Nat.mul_add, Nat.add_mul]`) and line the factors up (`rw [Nat.mul_left_comm a b c, Nat.add_one_mul]`).
- `unfold` doesn't reduce a projection of a structure literal, so `omega` sees nothing. Use
  `refine ⟨⟨a, b⟩, ⟨?_, ?_, ?_⟩, ?_⟩ <;> simp only [defs] <;> omega`.
- `decide` runs in the kernel, which won't unfold well-founded recursion such as `mergeSort`. Check concrete cases
  with `#guard`, which runs the code, and keep the proofs general. `decide` is fine on plain structural recursion over
  lists of a hundred or so rows.
- A structure needs `deriving DecidableEq` before `decide` or `#guard ==` can compare its values.
- Avoid `native_decide`: it adds an axiom, and the proof then trusts the compiler.
- `y :: a ++ b` parses as `(y :: a) ++ b`, which equals `y :: (a ++ b)` by `rfl`.
- `List.mem_cons_self` takes implicit arguments; `by simp` is simpler than spelling them.
- Comparisons in a `Bool` function (`decide (b.time ≤ a.time)`) need `simp [defs, …]` to turn back into
  propositions.

## Checks before claiming

1. `lake build` over the whole package.
2. `#print axioms` on each main theorem: only `propext`, `Quot.sound` and `Classical.choice`, never `sorryAx`.
3. A wrong value fails: `example : ¬ within 1000 f rows = 4 := by decide`, or `#guard` that a fast path differs from
   the reference when the invariant is broken. A check that can't fail checks nothing.
4. Planted bugs get caught: change one line of the model (a `≤` to `<`, a dropped term) and confirm a proof breaks.
5. The code matches the model: run the implementation and the Lean model on the same random inputs and compare them,
   or add a test that shows the old code wrong and the new code right.
6. Say which theorems are only true by definition and which carry the content, and state each premise in words.
