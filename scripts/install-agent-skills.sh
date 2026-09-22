#!/usr/bin/env bash
# Install the tracked community skills without checking out the dotfiles repo.
set -euo pipefail

REGISTRY_URL="${AGENT_SKILLS_REGISTRY_URL:-https://raw.githubusercontent.com/justmangoou/dotfiles/main/.agent-skills/sources.tsv}"
REGISTRY_FILE="$(mktemp)"
trap 'rm -f "$REGISTRY_FILE"' EXIT

die() {
  printf 'install-agent-skills: %s\n' "$*" >&2
  exit 1
}

trim_whitespace() {
  local value="$1"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s\n' "$value"
}

command -v curl >/dev/null 2>&1 || die 'curl is required.'
command -v npx >/dev/null 2>&1 || die 'npx is required; install Node.js first.'

curl -fsSL "$REGISTRY_URL" -o "$REGISTRY_FILE"

declare -a installed_skills=()
while IFS=$'\t' read -r source selection extra; do
  [[ -z "$source" || "$source" == \#* ]] && continue
  [[ -n "$selection" && -z "$extra" ]] || die "invalid registry entry for $source"

  IFS=',' read -r -a skills <<<"$selection"
  command=(npx --yes skills add "$source" --global --copy --agent cline --agent claude-code --yes)
  for skill in "${skills[@]}"; do
    skill="$(trim_whitespace "$skill")"
    [[ -n "$skill" && "$skill" != '*' ]] || die "standalone installation requires named skills, not '$selection'."
    command+=(--skill "$skill")
    installed_skills+=("$skill")
  done

  printf 'Installing %s\n' "$source"
  DISABLE_TELEMETRY=1 "${command[@]}" </dev/null
done < "$REGISTRY_FILE"

(( ${#installed_skills[@]} > 0 )) || die 'no skills found in registry.'
printf 'Updating tracked skills\n'
DISABLE_TELEMETRY=1 npx --yes skills update --global --yes "${installed_skills[@]}" </dev/null

printf 'Installed and updated %d skill(s).\n' "${#installed_skills[@]}"
