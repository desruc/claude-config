#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

command=$(jq -r '.tool_input.command // empty')
pr_create_args=$(printf '%s\n' "$command" | awk -v command_pattern='gh +pr +create' -f "$(dirname "$0")/lib/command-args.awk") || exit 0

printf '%s\n' "$pr_create_args" | grep -qE '^(-d|--draft(=true)?)$' && exit 0

echo "PRs are always created as drafts. Rerun gh pr create with --draft." >&2
exit 2
