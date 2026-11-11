#!/usr/bin/env bash
# A Mac app into a drag-install DMG: signs the bundle, checks its seal, stages it beside an /Applications link,
# builds a compressed image and signs it, then notarizes and staples it when NOTARY_PROFILE names a
# `notarytool store-credentials` profile. From alma-dictation's and screenpipe-swift's scripts.
# usage: SIGN_IDENTITY="Almanac Dev" [ENTITLEMENTS=x.plist] [NOTARY_PROFILE=name] make-dmg.sh Name.app [out.dmg]
#   SIGN_IDENTITY is a keychain identity, or - for ad hoc; unset, the bundle's own signature is kept.
set -euo pipefail
app=${1:?usage: make-dmg.sh Name.app [out.dmg]}
app=${app%/}
[ -d "$app/Contents/MacOS" ] || { echo "$app is not an app bundle" >&2; exit 1; }
name=$(basename "$app" .app)
version=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist" 2> /dev/null || echo 0.0.0)
out=${2:-$(dirname "$app")/$name-$version-$(uname -m).dmg}
id=${SIGN_IDENTITY:-}

if [ -n "$id" ]; then
  flags=(--force --options runtime --sign "$id")
  if [ -n "${ENTITLEMENTS:-}" ]; then flags+=(--entitlements "$ENTITLEMENTS"); fi
  if [ -n "${NOTARY_PROFILE:-}" ]; then flags+=(--timestamp); fi  # the notary requires a secure timestamp
  codesign "${flags[@]}" "$app"
fi
codesign --verify --strict "$app" || { echo "$app fails codesign --verify: sign it (SIGN_IDENTITY=…)" >&2; exit 1; }

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
ditto "$app" "$stage/$name.app"  # ditto keeps what the signature needs; cp can drop it
ln -s /Applications "$stage/Applications"
rm -f "$out"
hdiutil create -volname "$name" -srcfolder "$stage" -fs HFS+ -format ULMO -ov -quiet "$out"

if [ -n "$id" ] && [ "$id" != - ]; then
  codesign --force --sign "$id" ${NOTARY_PROFILE:+--timestamp} "$out"  # Gatekeeper checks the image itself
fi

if [ -n "${NOTARY_PROFILE:-}" ]; then
  result=$(xcrun notarytool submit "$out" --keychain-profile "$NOTARY_PROFILE" --wait --output-format json)
  if ! echo "$result" | grep -Eq '"status" *: *"Accepted"'; then
    echo "notarization failed: $result" >&2
    echo "the reason: xcrun notarytool log <id> --keychain-profile $NOTARY_PROFILE" >&2
    exit 1
  fi
  xcrun stapler staple "$out"
fi

echo "$out ($(du -h "$out" | cut -f1 | tr -d ' '), signed: ${id:-as built}, notarized: ${NOTARY_PROFILE:+yes}${NOTARY_PROFILE:-no})"
