# dotfiles

## Setup

This repository uses Git's bare-repository pattern. `scripts/install.sh` clones the
repository into `~/.dotfiles` and checks the tracked files out into `$HOME`.
The installed Fish function lets you manage it with ordinary Git commands:

```fish
dotfiles add .config/fish/config.fish
dotfiles status
dotfiles commit -m 'feat(fish): add configuration'
```

Run it directly on a new machine:

```bash
curl -fsSL https://raw.githubusercontent.com/justmangoou/dotfiles/main/scripts/install.sh | bash
```

To use a fork, download the script and run `scripts/install.sh --repo <url>`.
It installs the skills from `.agent-skills/sources.tsv` after checkout; pass
`--skip-skills` to skip that network step. The installer refuses to overwrite
existing files.

To install only the tracked community skills on a host without this repository:

```bash
curl -fsSL https://raw.githubusercontent.com/justmangoou/dotfiles/main/scripts/install-agent-skills.sh | bash
```

## Agent skills

`scripts/agent-skills` manages skills shared by tools that read
`~/.agents/skills` and Claude Code (`~/.claude/skills`). Community sources are
tracked in `.agent-skills/sources.tsv`; skills you write live directly in
`.agent-skills/<skill-name>/`.

```bash
# Add a skills.sh/Git source and selected skills (quote names with spaces).
scripts/agent-skills add vercel-labs/agent-skills --skill frontend-design --skill skill-creator

# Remove the skills selected from a tracked source.
scripts/agent-skills remove vercel-labs/agent-skills

# Add every skill supplied by a skills.sh pack.
scripts/agent-skills add https://skills.sh/p/<pack-id>

# On another device, after cloning or pulling this repository.
scripts/agent-skills install

# Refresh community skills only when you decide to.
scripts/agent-skills update

# Copy only the custom skills in this repository.
scripts/agent-skills sync-custom
```

For example, put a custom skill in `.agent-skills/my-skill/SKILL.md`, with any
supporting files inside that directory. `sources.tsv` is ignored by custom-skill
syncing.

`add` and custom-skill edits change files in this repository. Commit and push
those changes before moving to another device. The script uses the official
`skills` CLI with copying enabled and disables its optional telemetry.

For safety, `remove` only removes sources that were added with explicit skill
names. A source added without names means “all skills”; use `npx skills remove
-g` to choose those removals, then delete its registry line.
