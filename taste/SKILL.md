---
name: taste
description: Build and iterate UI the way Affan judges it. Match a reference screenshot closely, including its premium finish (never flatten it), keep the existing aesthetic and design tokens, use real assets logged with their licences, extreme, fancy, choreographed motion that costs nothing at rest, compact layouts, normal casing, warm specific sentences with plain labels and no AI tells or marketing words, mobile checked, and page weight and idle cost treated as gates. Use whenever building or changing UI, a landing page, a component, a site, an app screen or copy; when he sends a screenshot or reference ("make it like this", "heavy inspiration from here"); and when he says it doesn't match the aesthetic, looks off, isn't centered, isn't mobile optimised, feels AI-generated or needs polish. Pairs with frontend-design.
---

# Taste

The biggest single thing he does with agents: 536 prompts across 42 projects iterate on UI from screenshots. Load
frontend-design for direction; this skill is how he judges the result.

## From a reference

- A screenshot or URL is the spec. "Heavy inspiration" means the layout, proportions, type scale, spacing rhythm and
  feel of the motion match closely, while the content and brand stay ours. Before saying it matches, put your
  screenshot beside the reference and list the differences.
- The reference's finish is part of the spec: its light, depth and materials. That means bezels, carved and embossed
  surfaces, inner glows, glossy badges and layered shadows. Read its CSS or design board and copy the layers, then
  re-colour them for our palette. Never flatten a premium reference to satisfy a generic rule below: when they conflict,
  the reference wins. (Maggie, 2026-11-08: "we have lost how premium the components feel… This is unacceptable.")
- Keep the product's existing aesthetic. A section that "does not match the japanese aesthetic we have" is wrong
  however good it looks alone. Read the design tokens and two existing sections first.
- Iterate in small passes, one thing per pass (spacing, type, motion, copy), with a screenshot after each.

## House look: new.quest

Quest's app ([new.quest](https://www.new.quest)) is his taste in general. When there's no other reference, start from
its vibe, then put the product's own palette and brand on it:
- **Ground:** a soft, fogged backdrop with slow-blurred glows.
- **Surfaces:** off-white paper, shadows tinted with ink (never black) in two layers.
- **Bezels:** every card and every button sits in a lighter rim of its own. The main action is the carved "door" button
  (a white rim, a glow inside, light on the top-left edge). Quiet buttons are embossed paper. Badges are glossy and lit
  from above.
- **Chrome:** a floating embossed tab bar with the selected item raised, plus a round button in its own bezel. Hero
  artifact cards tilt a few degrees.
- **Type:** Season (Displaay), never regular weight, and big confident headlines with one phrase lifted onto paper.
- **Feel:** warm, tactile and specific, with choreographed springs and nothing generic.

## The bar

- Tokens are the one source of colour, type and spacing: one accent, no raw hex and no ad-hoc font-family in
  components.
- No AI slop: no generic gradients, purple glow, emoji in UI chrome, or glass for its own sake. Layered surfaces
  (a card in a bezel, a carved button) are finish, not slop, when the reference has them.
- Normal casing everywhere: no all-caps labels, badges or eyebrows, even when the reference uses them.
- Compact over spacious: tighten the spacing between blocks before adding containers.
- Motion is a feature: extreme, fancy and choreographed, never a plain fade.
  - Where it goes: every appearance, state change and answer.
  - Techniques: staggered spring entrances with blur, morphs and matched geometry, numbers that roll, symbol effects,
    a burst when something good happens, and haptics on taps and wins.
  - Springs, never linear.
  - It still costs nothing at rest: nothing loops while the screen is idle or hidden, and Reduce Motion gets a
    crossfade.
- Real assets only: fonts, icons, sounds and models from real libraries (Google Fonts, Fontshare, Kenney, freesound
  and the like), downloaded into the repo and logged in `CREDITS.md` with their URL and licence. No hand-drawn
  stand-ins for what the internet has: a gradient sunset or clip-art scene in place of a photo is slop (Maggie,
  2026-11-08). Use the person's own photo, or a real licensed one (Wikimedia Commons CC0 works). If a download fails,
  say so.
- Native first: CSS over JS, the platform's own controls, and on Apple platforms Liquid Glass with the real
  `.glassEffect`. The exception is chrome the reference defines itself (Quest's embossed tab bar): build that.
- Centered means measured: check it in the browser's box model or on a screenshot, never by eye.
- Mobile: check it at phone width. Decoration that crowds a phone comes off on mobile ("No doodles on mobile at all").

## Costs are gates

Use prove-and-optimize on these, measured after any visual change that added something:
- Idle CPU near zero: no animation loop or polling when nothing moves, and loops pause when the page is hidden.
- Memory under the budget: event-games held each screen under 40 MB of heap.
- Page weight: tree-shaken imports, images sized to their box (1024 px at most unless justified), subset fonts.

## Copy

- No marketing words: powerful, revolutionary, seamless, cutting-edge, leverage, empower, unlock, transform, magical,
  robust, scalable, innovative, intelligent.
- No em-dashes or semicolons in visible copy, because they read as AI-written. Split the sentence, or use a comma,
  a colon or parentheses.
- No AI rhythm:
  - "Not X. Y." flips
  - three-beat triplets more than once a page
  - three or more sentences opening the same way
  - mirror sentences
  - pithy abstract-noun endings
- Voice, the way Quest writes: warm and specific, never cute. The personality lives in one or two sentences built from
  the person's real content. Quest: "Two calls before lunch, then the afternoon is yours to build." Maggie: "Dinner and
  Priya's Thursday need a yes. The morning is yours."
- Labels stay plain:
  - Section titles, settings, statuses and buttons are ordinary nouns and verbs ("Running", "Approvals", "Memory",
    "Not now").
  - An action button names its action ("Pay ₹2,340", "Book it").
  - No quips, puns or cute rewrites of standard words. "Nope", "Do it", "The crew", "3 things in the oven", "How
    chatty I am" and "That's not a setting, it's a promise" were all called slop (Maggie, 2026-11-08).
- Direct and second person, short sentences, specific moments over abstract claims. No exclamation points.
- Outcomes, not mechanics: marketing copy never explains the internals.
- A paragraph over three sentences gets split or turned into a list. Read the section as plain text before shipping.
- Grep before calling a page clean, e.g.
  `grep -rniE "seamless|leverage|unlock|empower|robust|scalable" src` and `grep -rn "—\|;" src/pages src/components`.

## Show it

Screenshot at desktop and phone width and look at both yourself before reporting (relaunch, "Show it").
