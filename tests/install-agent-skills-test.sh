#!/usr/bin/env bash
# Regression test: a skills CLI that reads stdin must not consume registry rows.
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
registry_source="$repo_root/.agent-skills/sources.tsv"

curl() {
  cp "$REGISTRY_SOURCE" "${@: -1}"
}

npx() {
  printf '%s\n' "$*"
  [[ " $* " == *' skills add '* ]] && cat >/dev/null
  return 0
}

export -f curl npx
output="$(REGISTRY_SOURCE="$registry_source" \
  AGENT_SKILLS_REGISTRY_URL='https://example.test/sources.tsv' \
  bash "$repo_root/scripts/install-agent-skills.sh")"

adds="$(printf '%s\n' "$output" | rg -c '^--yes skills add ' || true)"
[[ "$adds" == 3 ]] || {
  printf 'expected all registry sources to be installed, got %s\n' "$adds" >&2
  exit 1
}
printf '%s\n' "$output" | rg -q 'https://github.com/juliusbrussee/caveman'
printf '%s\n' "$output" | rg -q 'https://github.com/mattpocock/skills'
printf '%s\n' "$output" | rg -q 'https://github.com/vercel-labs/skills'
printf '%s\n' "$output" | rg -q 'mattpocock/skills .*--skill grilling'
printf '%s\n' "$output" | rg -q 'mattpocock/skills .*--skill domain-modeling'
printf '%s\n' "$output" | rg -q 'mattpocock/skills .*--skill code-review'
printf '%s\n' "$output" | rg -q 'vercel-labs/skills .*--skill find-skills'
