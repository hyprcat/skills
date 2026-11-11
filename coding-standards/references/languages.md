# Language defaults

From the newest repos (Oct–Nov 2026). A repo's existing setup wins over these; they're for new projects and new files.

## TypeScript
- ESM (`"type": "module"`), npm with `package-lock.json`. pnpm or bun only where the repo already uses them.
- Node runs `.ts` directly, no build step: `"start": "node src/server.ts"`.
- tsconfig: `strict`, `noEmit`, `erasableSyntaxOnly`, `allowImportingTsExtensions`, `module: nodenext`, target `es2024`.
- The gate is `"check": "tsc -p ."`. Tests run on `node --test`.
- zod at every boundary.

## Rust
- Edition 2021, `[profile.release] lto = "thin"`.
- A tiny dependency set: serde, serde_json, ureq, tungstenite, sha2, libc, and rusqlite (bundled) when a store is needed.
  No tokio where sync code suffices.
- Parse arguments by hand with a `match` over the argument slice; no clap for a few flags.
- Binaries return `Result<T, String>` with readable messages; a library crate has one `thiserror` enum. No `unwrap`
  outside tests.
- A patched dependency is `[patch.crates-io]` pointing at a sibling checkout, plus a `.patch` file against the pristine crate.
- Prompts are compiled in with `include_str!`: rebuild after editing one.
- Gate: `cargo build --release --offline --locked` or `cargo check --all-targets`, no warnings.

## Swift
- Swift 6 with strict concurrency `complete`, SwiftPM, macOS 15 and later.
- SwiftUI views, then `@Observable @MainActor` models, then actor services, joined by `AsyncStream`.
- `OSLog` with one subsystem, never `print`.
- Liquid Glass is the real `.glassEffect` behind `#available(macOS 26)`, never blur plus opacity.
- Tests need `DEVELOPER_DIR=/Applications/Xcode.app`. Launch an app from its bundle, not a terminal, or the TCC grants
  go to the terminal.

## Python
- uv (`uv sync`, `uv run`), Python 3.13, ruff (line 100; `E,F,I,N,W,UP,B,SIM,RUF`), pytest, pydantic v2 at boundaries.

## Web
- Astro for sites, with three.js and lenis only for effects. Vite for apps.
- Design tokens are the one source of colour and type: one accent, no raw hex in components.

## Shell
- `#!/usr/bin/env bash` and `set -euo pipefail`, written for bash 3.2 (macOS).
- Scripts live in `scripts/`: `build-app.sh`, `make-dmg.sh`, `ci.sh`, `check-structure.sh`.

## CI and tests
- The workflow calls one gate script (`./scripts/ci.sh <lane>`) and never spells out a check itself. Steps are named
  as claims ("The gate is green for this commit").
- An LLM review through the LiteLLM proxy comments on each PR and never blocks; the caps are checked exactly in shell.
- New repos gate on a warning-free build plus a live run whose outcome you check yourself. Product repos with suites
  keep them. Test the pure layer (state machines, codecs) with fixture data; a test that needs elaborate mocks means
  the code does too much. Never make real paid API calls in unit tests.
