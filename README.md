# claude-config

My Claude Code setup: the rules I give Claude, my user settings, and a few hooks.

It's built around making the wrong thing hard to do. When I correct Claude, I try to turn the correction into a type, lint rule, test or hook first, and only add a line of prose when no check fits. The prose rules are short and absolute, which leaves an agent less room to argue its way around them.

## What's here

- `CLAUDE.md`: the rules Claude follows in every project.
- `settings.json`: my user settings.
- `hooks/block-memory-writes.sh`: stops Claude's file tools writing into a memory folder (`~/.claude/projects/*/memory/`).
- `hooks/commit-subject-only.sh`: blocks a `git commit` whose message has more than a subject line (a second `-m`, a newline, or a message file or heredoc).
- `hooks/draft-prs-only.sh`: blocks `gh pr create` without `--draft`.
- `hooks/conventional-pr-titles.sh`: blocks a `gh pr create` or `gh pr edit` title without a Conventional Commits prefix, since the PR title is what lands in history on a squash merge. A repo opts out with `git config claude.conventionalPrTitles false` (or an `includeIf` that sets it for a group of repos), unless it uses release-please, commitlint or a semantic PR title check, which all expect the convention.
- `hooks/filtered-tests-only.sh`: blocks running a whole test suite or project (`dotnet test` without `--filter`, bare `npm test`, `jest`, `vitest`, `pytest` or `go test ./...`).
- `hooks/lib/command-args.awk`: splits a shell command into its arguments, so the hooks check real flags and not text inside a quoted message.
- `tests/hooks.sh`: runs each hook against commands it should allow and block. Run `sh tests/hooks.sh` after changing a hook.

Auto memory is off. It saved corrections as files I never saw, and it tended to turn a one-off correction into a blanket rule. Anything worth keeping goes in `CLAUDE.md` or becomes a check. The setting stops Claude loading memories, and the hook blocks Claude's file tools from writing new ones.

Commit and PR attribution is off in `settings.json`, so Claude Code doesn't ask for `Co-Authored-By` or "Generated with Claude Code" lines in the first place.

## Install

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

Claude Code writes to `settings.json` itself, for example when you allow a command or change something in `/config`. With the symlink, those changes show up as a diff here, so you can keep or discard them.

## Skills

These aren't in the repo because they're other people's work. I use them unchanged:

- `humanizer` from [blader/humanizer](https://github.com/blader/humanizer). The writing rules in `CLAUDE.md` call it. `settings.json` enables it as a plugin with auto-update on, so Claude Code installs and updates it.
- `grilling` and `grill-me` from [mattpocock/skills](https://github.com/mattpocock/skills). The install links just these two from a clone, because the plugin brings a dozen other skills that Claude would pick up on its own. `git -C ~/.local/share/mattpocock-skills pull` updates them.
