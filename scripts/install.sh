#!/usr/bin/env bash
# Install this repository as a bare Git repository whose work tree is $HOME.
set -euo pipefail

DEFAULT_REPOSITORY='git@github.com:justmangoou/dotfiles.git'
REPOSITORY="$DEFAULT_REPOSITORY"
GIT_DIRECTORY="${DOTFILES_GIT_DIR:-$HOME/.dotfiles}"
WORK_TREE="${DOTFILES_WORK_TREE:-$HOME}"
SKIP_SKILLS=0

usage() {
  cat <<EOF
Usage: scripts/install.sh [options]

Clone this dotfiles repository as a bare repository and check it out into the
selected work tree. The Fish function .config/fish/functions/dotfiles.fish then
provides: dotfiles add <path>, dotfiles status, dotfiles commit, and all other
Git commands.

Options:
  --repo <url>       Repository URL (default: $DEFAULT_REPOSITORY)
  --git-dir <path>   Bare repository location (default: ~/.dotfiles)
  --work-tree <path> Checkout location (default: ~)
  --skip-skills      Do not install the skills in .agent-skills/sources.tsv
  --help             Show this help

The script refuses to overwrite existing files. Move conflicting files first,
then run it again.
EOF
}

die() {
  printf 'install: %s\n' "$*" >&2
  exit 1
}

while (( $# > 0 )); do
  case "$1" in
    --repo)
      (( $# >= 2 )) || die '--repo requires a URL.'
      REPOSITORY="$2"
      shift 2
      ;;
    --git-dir)
      (( $# >= 2 )) || die '--git-dir requires a path.'
      GIT_DIRECTORY="$2"
      shift 2
      ;;
    --work-tree)
      (( $# >= 2 )) || die '--work-tree requires a path.'
      WORK_TREE="$2"
      shift 2
      ;;
    --skip-skills)
      SKIP_SKILLS=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

command -v git >/dev/null 2>&1 || die 'git is required.'
[[ -d "$WORK_TREE" ]] || die "work tree does not exist: $WORK_TREE"

if [[ -e "$GIT_DIRECTORY" ]]; then
  git --git-dir="$GIT_DIRECTORY" rev-parse --is-bare-repository >/dev/null 2>&1 || die "not a bare Git repository: $GIT_DIRECTORY"
else
  git clone --bare "$REPOSITORY" "$GIT_DIRECTORY"
fi

conflicts=0
while IFS= read -r path; do
  destination="$WORK_TREE/$path"
  if [[ -e "$destination" || -L "$destination" ]]; then
    printf 'Conflict: %s\n' "$destination" >&2
    conflicts=1
  fi
done < <(git --git-dir="$GIT_DIRECTORY" ls-tree -r --name-only HEAD)

(( conflicts == 0 )) || die 'move the conflicting files, then rerun setup.'

git --git-dir="$GIT_DIRECTORY" --work-tree="$WORK_TREE" checkout
git --git-dir="$GIT_DIRECTORY" --work-tree="$WORK_TREE" config status.showUntrackedFiles no

if (( SKIP_SKILLS == 0 )); then
  SKILLS_INSTALLER="$WORK_TREE/scripts/agent-skills"
  [[ -x "$SKILLS_INSTALLER" ]] || die "missing executable skill installer: $SKILLS_INSTALLER"
  "$SKILLS_INSTALLER" install
fi

printf 'Installed dotfiles. Start a new Fish shell, then run: dotfiles status\n'
