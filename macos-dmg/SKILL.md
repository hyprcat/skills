---
name: macos-dmg
description: Package a Mac app into a DMG the way Affan's repos do. Sign the bundle (a stable self-signed identity for quick builds, Developer ID for releases), verify the seal, stage it with an /Applications link, build the image with hdiutil, sign it, optionally notarize and staple, report the size, and hand over the file or install it. Use whenever he asks for a DMG, a build he can install, a self-signed or notarized build, a release, a GitHub release asset or a Homebrew cask bump, or says "gimme the dmg", "without apple shenanigans", "notarize it" or "install the dmg for me".
---

# macOS DMG

112 prompts across 8 projects ask for a DMG; 12 repos codesign.

## Pick the path

| He asks for | Sign with | Notarize |
|---|---|---|
| "the dmg, self-signed, without apple shenanigans" | the stable self-signed identity (e.g. "Almanac Dev"), or ad hoc (`-`) | no: it opens with right-click Open, or once quarantine is cleared |
| a release for other people | the keychain's `Developer ID Application: …` identity | yes, then staple |

`security find-identity -v -p codesigning` lists the identities. A script takes the identity from an env var
(`<PRODUCT>_CODESIGN_IDENTITY`) and falls back to a keychain search. It never hardcodes one.

## Steps

1. Use the repo's scripts first (`scripts/build-app.sh`, then `make-dmg.sh`, `build-dmg.sh` or `release/dmg.sh`).
   Read them before running: they know the entitlements, nested helpers and Sparkle.
2. No script? Use `bash ~/.claude/skills/macos-dmg/scripts/make-dmg.sh Name.app [out.dmg]`, with `SIGN_IDENTITY` set
   (and `ENTITLEMENTS` when the app needs them). For a release, also set `NOTARY_PROFILE`, a
   `notarytool store-credentials` profile.
3. Hand over the path and size. For "install it for me": mount the image, `ditto` the app to `/Applications`, unmount,
   `xattr -dr com.apple.quarantine /Applications/Name.app`, then relaunch.

## Traps

- **Sign inside out:** nested frameworks, helpers and XPC services first, the app last, so its seal covers them.
  `--deep` only for third-party frameworks such as Sparkle.
- **Hardened runtime and entitlements:** use `--options runtime` always, plus `--timestamp` for notarization.
  Entitlements (screen capture, microphone, apple-events) go on with `--entitlements`, or TCC has nothing to grant.
- **`ditto`, never `cp`, for bundles:** cp can drop the extended attributes a signature needs, and the break only
  shows at the notary.
- **Ad-hoc signatures change every build**, so TCC grants reset. Dev builds use the stable self-signed identity.
- **Sign the DMG too.** Gatekeeper checks the image the user double-clicks, and the ticket is stapled to it.
- **Read the notary log before rebuilding.** On a rejection, `xcrun notarytool log <id> --keychain-profile <profile>`
  names the binary that failed. "Why are you rebuilding the dmg? What was the failure?"
- **A size budget is a gate** where the repo has one: alma checks 15 MB after signing.
- **Release order on CI** (`macos-26` runners):
  1. check the tag matches the version
  2. build, sign, notarize, make the DMG
  3. `gh release create vX Name.dmg`
  4. then a `cask/vX` PR or the Sparkle appcast, where the repo has them
