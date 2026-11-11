#!/usr/bin/env bash
# Quits every running copy of a Mac app (any build folder, matched by the bundle's executable path, never a bare
# process name), opens the given bundle, and fails unless the new process started after its binary was built.
# usage: fresh-app.sh /path/to/Name.app [open args…]
set -euo pipefail
app=$(cd "${1:?usage: fresh-app.sh /path/to/Name.app}" && pwd); shift
exe=$(/usr/libexec/PlistBuddy -c 'Print CFBundleExecutable' "$app/Contents/Info.plist")
bin="$app/Contents/MacOS/$exe"
copies="/$(basename "$app")/Contents/MacOS/$exe"

pids=$(pgrep -f "$copies" || true)
if [ -n "$pids" ]; then
  ps -o pid=,command= -p "$(echo $pids | tr ' ' ,)" | sed 's/^/quitting /'
  kill $pids
  for _ in $(seq 50); do pgrep -f "$copies" > /dev/null || break; sleep 0.1; done
  left=$(pgrep -f "$copies" || true)
  if [ -n "$left" ]; then kill -9 $left; fi
fi

open "$app" "$@"
pid=
for _ in $(seq 100); do pid=$(pgrep -nf "^$bin" || true); [ -n "$pid" ] && break; sleep 0.1; done
[ -n "$pid" ] || { echo "$app did not start within 10 s" >&2; exit 1; }

started=$(date -j -f '%a %b %d %T %Y' "$(ps -o lstart= -p "$pid" | sed 's/ *$//')" +%s)
built=$(stat -f %m "$bin")
[ "$started" -ge "$built" ] || { echo "pid $pid started before $bin was built: stale" >&2; exit 1; }
echo "fresh: pid $pid started $(date -r "$started" +%T), binary built $(date -r "$built" +%T)"
