#!/usr/bin/env bash
# The caps, checked exactly in the git repo it runs from: lines per code file, entries per folder, lines per function
# (Rust and Python), and stub markers. From instinct-memory's check. Bash 3.2 (macOS).
# A repo with other caps: FILE_CAP=… ENTRY_CAP=… FN_CAP=… (defaults 500, 6, 30).
set -euo pipefail
root=$(git rev-parse --show-toplevel)  # outside a repo git says so and this stops
cd "$root"
FILE_CAP=${FILE_CAP:-500} ENTRY_CAP=${ENTRY_CAP:-6} FN_CAP=${FN_CAP:-30}
code='\.(rs|ts|tsx|js|jsx|mjs|cjs|swift|py|sh|go|m|h|c|cc|cpp|kt|astro|vue|svelte|css)$'
failed=0

files() {
  git ls-files --cached --others --exclude-standard | while IFS= read -r f; do
    case "$f" in vendor/* | */vendor/* | *.lock | *-lock.json | *-lock.yaml) continue ;; esac
    [ -f "$f" ] && printf '%s\n' "$f"
  done
}

while IFS= read -r f; do
  n=$(wc -l < "$f" | tr -d ' ')
  if [ "$n" -gt "$FILE_CAP" ]; then echo "$f is $n lines (cap $FILE_CAP)"; failed=1; fi
done < <(files | grep -E "$code" || true)

# a folder's entries are the files and folders in it that git tracks or would; the repo root, packages/ and any
# folder holding a package manifest (a package root) are exempt
while read -r count d; do
  [ "$d" = . ] || [ "$d" = packages ] && continue
  for m in package.json Cargo.toml Package.swift pyproject.toml go.mod; do [ -f "$d/$m" ] && continue 2; done
  if [ "$count" -gt "$ENTRY_CAP" ]; then echo "$d/ holds $count entries (cap $ENTRY_CAP)"; failed=1; fi
done < <(files | awk -F/ '{ p = "."; for (i = 1; i <= NF; i++) { print p "\t" $i; p = (p == "." ? $i : p "/" $i) } }' \
  | sort -u | awk -F'\t' '{ n[$1]++ } END { for (d in n) print n[d], d }')

# a function runs from its `fn`/`def` line to the first line back at its indent
long=$(files | grep -E '\.(rs|py)$' | while IFS= read -r f; do
  awk -v f="$f" -v cap="$FN_CAP" '
    function indent(s) { match(s, /^ */); return RLENGTH }
    open && NF && indent($0) <= depth && $0 !~ /^ *[)\]]/ {
      n = NR - start + ($0 ~ /^ *}/ ? 1 : 0)
      if (n > cap) printf "%s:%d %s is %d lines (cap %d)\n", f, start, name, n, cap
      open = 0
    }
    !open && /^ *(pub(\([a-z]+\))? )?(async )?(fn|def) / {
      open = 1; start = NR; depth = indent($0); name = $0; sub(/^ */, "", name); sub(/\(.*/, "", name)
    }
    END { if (open && NR - start + 1 > cap) printf "%s:%d %s is %d lines (cap %d)\n", f, start, name, NR - start + 1, cap }
  ' "$f"
done || true)
if [ -n "$long" ]; then echo "$long"; failed=1; fi

# stub markers in code; the words are split so this file never matches itself
stubs=$(files | grep -E "$code" | tr '\n' '\0' | xargs -0 grep -nHE "TO""DO|FIX""ME|todo""!\(|unimplemented""!\(" /dev/null || true)
if [ -n "$stubs" ]; then echo "$stubs" | sed 's/$/ (stub)/'; failed=1; fi

[ "$failed" = 0 ] && echo "caps and stubs: clean"
exit "$failed"
