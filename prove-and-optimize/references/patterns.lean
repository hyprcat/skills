-- The patterns of references/lean.md, as one file that builds on Lean 4.35 core, no Mathlib (checked 2026-11-06).
-- To check it: lake +leanprover/lean4:v4.35.0 new probe lib.toml, copy this to probe/Probe/Patterns.lean, add
-- `import Probe.Patterns` to probe/Probe.lean, then lake build. The #print axioms lines must show no sorryAx.

-- The video's move: a reference that does the general work, a fast path that skips it, and a proof they agree under
-- the workload's invariant. Here: the feed sorts posts newest first, but posts are stored newest first already.
structure Post where
  time : Nat
  likes : Nat
  deriving DecidableEq

def newerFirst (a b : Post) : Bool := decide (b.time ≤ a.time)

/-- What the query engine computes: sort, then take the newest `k`. -/
def feed (k : Nat) (posts : List Post) : List Post := (posts.mergeSort newerFirst).take k
/-- The fast path: read the stored order. -/
def feedFast (k : Nat) (posts : List Post) : List Post := posts.take k

/-- Under the invariant, skipping the sort changes nothing. -/
theorem feedFast_eq (k : Nat) (posts : List Post) (stored : posts.Pairwise fun a b => newerFirst a b) :
    feedFast k posts = feed k posts := by
  unfold feed feedFast
  rw [List.mergeSort_of_pairwise stored]

/-- The invariant is kept by the one write path: a new post goes in front with a time at least every stored one's. -/
theorem insert_keeps (p : Post) (posts : List Post) (stored : posts.Pairwise fun a b => newerFirst a b)
    (newest : ∀ q ∈ posts, q.time ≤ p.time) : (p :: posts).Pairwise fun a b => newerFirst a b := by
  refine List.pairwise_cons.mpr ⟨fun q hq => ?_, stored⟩
  simp [newerFirst, newest q hq]

-- the checks the skill asks for
#print axioms feedFast_eq
#guard feedFast 2 [⟨3, 0⟩, ⟨2, 0⟩, ⟨1, 0⟩] == feed 2 [⟨3, 0⟩, ⟨2, 0⟩, ⟨1, 0⟩]
#guard feedFast 1 [⟨1, 0⟩, ⟨3, 0⟩] != feed 1 [⟨1, 0⟩, ⟨3, 0⟩]   -- without the invariant they differ

-- a floor any schedule pays, and a cap on what overlap can save
structure Parts where
  wait : Nat
  work : Nat
  write : Nat
def serial (p : Parts) : Nat := p.wait + p.write + p.work
def overlapped (p : Parts) : Nat := p.wait + max p.write p.work
theorem overlap_saves (p : Parts) : serial p - overlapped p = min p.write p.work := by unfold serial overlapped; omega

-- a median is a count
def within {α : Type} (B : Nat) (f : α → Nat) (l : List α) : Nat := l.countP fun x => decide (f x ≤ B)
theorem within_mono {α : Type} (B : Nat) (f g : α → Nat) (l : List α) (h : ∀ x ∈ l, g x ≤ f x) :
    within B f l ≤ within B g l :=
  List.countP_mono_left fun x hx hf => by
    simp only [decide_eq_true_eq] at hf ⊢
    exact Nat.le_trans (h x hx) hf

-- nonlinear: distribute and line the factors up before omega
theorem split_lowers_mean (k R S : Nat) (hS : 0 < S) : k * ((k + 1) * R + S) < (k + 1) * (k * R + S) := by
  simp only [Nat.mul_add]
  rw [Nat.mul_left_comm k (k + 1) R, Nat.add_one_mul k S]
  omega

-- a lower bound against every schedule that respects the dependencies, and a schedule that meets it
structure Sched where
  start : Nat
  done : Nat
def Sched.fits (s : Sched) (p : Parts) : Prop := p.wait ≤ s.start ∧ s.start + p.work ≤ s.done ∧ p.wait + p.write ≤ s.done
theorem overlapped_is_least (p : Parts) (s : Sched) (h : s.fits p) : overlapped p ≤ s.done := by
  obtain ⟨_, _, _⟩ := h
  unfold overlapped; omega
theorem overlapped_is_reached (p : Parts) : ∃ s : Sched, s.fits p ∧ s.done = overlapped p := by
  refine ⟨⟨p.wait, p.wait + max p.write p.work⟩, ⟨?_, ?_, ?_⟩, ?_⟩ <;> simp only [overlapped] <;> omega

-- measured rows, and a bound that holds whatever is added to each
def rows : List Nat := [400, 900, 1200, 300, 1500]
theorem whatever_we_add (extra : Nat → Nat) : within 1000 (fun c : Nat × Nat => c.1 + extra c.2) rows.zipIdx ≤ 3 := by
  have h : within 1000 (fun c : Nat × Nat => c.1) rows.zipIdx = 3 := by decide
  have := within_mono 1000 (fun c : Nat × Nat => c.1 + extra c.2) (fun c => c.1) rows.zipIdx (fun _ _ => Nat.le_add_right _ _)
  omega

-- ordering work by exchange (Smith's rule): most weight per unit of time first minimises total weighted completion time
structure Job where
  weight : Nat
  time : Nat
def cost : Nat → List Job → Nat
  | _, [] => 0
  | t, x :: l => x.weight * (t + x.time) + cost (t + x.time) l
def First (x y : Job) : Prop := y.weight * x.time ≤ x.weight * y.time
instance : DecidableRel First := fun x y => inferInstanceAs (Decidable (y.weight * x.time ≤ x.weight * y.time))
theorem swap_if_first (t : Nat) (x y : Job) (l : List Job) (h : First x y) : cost t (x :: y :: l) ≤ cost t (y :: x :: l) := by
  unfold First at h
  simp only [cost]
  rw [show t + y.time + x.time = t + x.time + y.time by omega]
  simp only [Nat.mul_add]
  omega
theorem bubble (x : Job) (b : List Job) : ∀ (a : List Job) (t : Nat), (∀ y ∈ a, First x y) → cost t (x :: (a ++ b)) ≤ cost t (a ++ x :: b)
  | [], _, _ => Nat.le_refl _
  | y :: a, t, h => by
    have ih := bubble x b a (t + y.time) (fun z hz => h z (by simp [hz]))
    have hs := swap_if_first t x y (a ++ b) (h y (by simp))
    calc cost t (x :: (y :: a ++ b)) = cost t (x :: y :: (a ++ b)) := rfl
      _ ≤ cost t (y :: x :: (a ++ b)) := hs
      _ = y.weight * (t + y.time) + cost (t + y.time) (x :: (a ++ b)) := rfl
      _ ≤ y.weight * (t + y.time) + cost (t + y.time) (a ++ x :: b) := Nat.add_le_add_left ih _
      _ = cost t (y :: a ++ x :: b) := rfl
theorem ratio_order_is_least : ∀ (l m : List Job) (t : Nat), l.Pairwise First → l.Perm m → cost t l ≤ cost t m
  | [], m, _, _, hp => by obtain rfl := List.nil_perm.mp hp; exact Nat.le_refl _
  | x :: l, m, t, hs, hp => by
    rw [List.pairwise_cons] at hs
    obtain ⟨a, b, rfl⟩ := List.append_of_mem (hp.subset (List.mem_cons_self ..))
    have hp' : l.Perm (a ++ b) := (hp.trans List.perm_middle).cons_inv
    have hx : ∀ y ∈ a, First x y := fun y hy => hs.1 y (hp'.symm.subset (List.mem_append_left b hy))
    calc cost t (x :: l) = x.weight * (t + x.time) + cost (t + x.time) l := rfl
      _ ≤ x.weight * (t + x.time) + cost (t + x.time) (a ++ b) := Nat.add_le_add_left (ratio_order_is_least l (a ++ b) _ hs.2 hp') _
      _ = cost t (x :: (a ++ b)) := rfl
      _ ≤ cost t (a ++ x :: b) := bubble x b a t hx
#print axioms ratio_order_is_least
