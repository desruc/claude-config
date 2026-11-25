# claude-config

My Claude Code setup: the rules I give Claude, my user settings, and a few hooks.

It's built around making the wrong thing hard to do. When I correct Claude, I try to turn the correction into a type, lint rule, test or hook first, and only add a line of prose when no check fits. The prose rules are short and absolute, which leaves an agent less room to argue its way around them.

## What's here

- `CLAUDE.md`: the rules Claude follows in every project.
- `settings.json`: model, permissions, plugins, and the wiring for the hooks below.

### Hooks

These live in `hooks/` and run before Claude's tool calls, blocking the ones that break a rule. Run `sh tests/hooks.sh` after changing one. It checks each hook against commands it should allow and block.

- `block-memory-writes.sh`: stops Claude writing memory files into `~/.claude/projects/*/memory/`. Auto memory is off because it saved corrections I never saw and made one-off fixes into blanket rules. The setting only stops memories loading, so this hook stops new ones being written.
- `commit-subject-only.sh`: blocks a `git commit` whose message has more than a subject line, whether through a second `-m`, a newline, a message file or a heredoc.
- `draft-prs-only.sh`: blocks `gh pr create` without `--draft`.
- `conventional-pr-titles.sh`: blocks a `gh pr create` or `gh pr edit` title without a Conventional Commits prefix, since the PR title becomes the commit on a squash merge. To opt a repo out, set `git config claude.conventionalPrTitles false`, or use an `includeIf` to set it for a group of repos.
- `filtered-tests-only.sh`: blocks commands that run a whole test suite, such as `dotnet test` without `--filter`, `go test ./...` without `-run`, or `npm test`, `jest`, `vitest` and `pytest` with no path or filter.
- `lib/command-args.awk`: splits a shell command into its arguments, so the hooks check real flags and not text inside a quoted message.

## Install

This moves any existing `CLAUDE.md` and `settings.json` aside, links the repo into `~/.claude`, then sets up the grilling skills.

```sh
git clone git@github.com:desruc/claude-config.git ~/dev/claude-config
mv -n ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.pre-claude-config.bak
mv -n ~/.claude/settings.json ~/.claude/settings.json.pre-claude-config.bak
ln -s ~/dev/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/dev/claude-config/hooks ~/.claude/hooks
ln -s ~/dev/claude-config/settings.json ~/.claude/settings.json
git clone https://github.com/mattpocock/skills.git ~/.local/share/mattpocock-skills
mkdir -p ~/.claude/skills
ln -s ~/.local/share/mattpocock-skills/skills/productivity/grilling ~/.claude/skills/grilling
ln -s ~/.local/share/mattpocock-skills/skills/productivity/grill-me ~/.claude/skills/grill-me
```

## Skills

These aren't in the repo because they're other people's work. I use them unchanged:

- `humanizer` from [blader/humanizer](https://github.com/blader/humanizer), which the writing rules in `CLAUDE.md` call. `settings.json` installs it as a plugin and keeps it up to date.
- `grilling` and `grill-me` from [mattpocock/skills](https://github.com/mattpocock/skills). The install clones the repo and links only these two, because the plugin would bring a dozen other skills that Claude could pick up on its own. Run `git -C ~/.local/share/mattpocock-skills pull` to update them.
