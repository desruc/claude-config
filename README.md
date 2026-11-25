# claude-config

My Claude Code setup: the rules I give Claude, my user settings, and a few hooks.

It's built around making the wrong thing hard to do. When I correct Claude, I try to turn the correction into a type, lint rule, test or hook first, and only add a line of prose when no check fits. The prose rules are short and absolute, which leaves an agent less room to argue its way around them.

## What's here

- `CLAUDE.md`: the rules Claude follows in every project.
- `settings.json`: my user settings.
- `hooks/block-memory-writes.sh`: stops Claude's file tools writing into a memory folder (`~/.claude/projects/*/memory/`).
- `hooks/commit-subject-only.sh`: blocks a `git commit` whose message has more than a subject line (a second `-m`, a newline, or a message file or heredoc).
- `hooks/lib/command-args.awk`: splits a shell command into its arguments, so the hooks check real flags and not text inside a quoted message.

Auto memory is off. It saved corrections as files I never saw, and it tended to turn a one-off correction into a blanket rule. Anything worth keeping goes in `CLAUDE.md` or becomes a check. The setting stops Claude loading memories, and the hook blocks Claude's file tools from writing new ones.

Commit and PR attribution is off in `settings.json`, so Claude Code doesn't ask for `Co-Authored-By` or "Generated with Claude Code" lines in the first place.

## Install

```sh
git clone git@github.com:desruc/claude-config.git ~/dev/claude-config
mkdir -p ~/.claude/hooks
mv -n ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.pre-claude-config.bak
mv -n ~/.claude/settings.json ~/.claude/settings.json.pre-claude-config.bak
ln -s ~/dev/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/dev/claude-config/settings.json ~/.claude/settings.json
ln -s ~/dev/claude-config/hooks/block-memory-writes.sh ~/.claude/hooks/block-memory-writes.sh
ln -s ~/dev/claude-config/hooks/commit-subject-only.sh ~/.claude/hooks/commit-subject-only.sh
ln -s ~/dev/claude-config/hooks/lib ~/.claude/hooks/lib
```

Claude Code writes to `settings.json` itself, for example when you allow a command or change something in `/config`. With the symlink, those changes show up as a diff here, so you can keep or discard them.

## Skills

These aren't in the repo because they're other people's work. I use them unchanged:

- `humanizer` from [blader/humanizer](https://github.com/blader/humanizer). The writing rules in `CLAUDE.md` call it.
- `grilling` and `grill-me` from [mattpocock/skills](https://github.com/mattpocock/skills).
