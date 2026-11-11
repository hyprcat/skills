#!/usr/bin/env bash
# Links every skill here into Claude Code (~/.claude/skills) and Codex and other agents (~/.agents/skills).
set -euo pipefail
cd "$(dirname "$0")"
for s in */SKILL.md; do
  s=${s%/SKILL.md}
  for d in ~/.claude/skills ~/.agents/skills; do
    mkdir -p "$d"
    if [ -d "$d/$s" ] && [ ! -L "$d/$s" ]; then echo "skipped $d/$s: a real folder is there"; continue; fi
    ln -sfn "$PWD/$s" "$d/$s" && echo "linked $d/$s"
  done
done
