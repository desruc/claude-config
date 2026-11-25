#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

command=$(jq -r '.tool_input.command // empty')
commit_args=$(printf '%s\n' "$command" | awk -v command_pattern='git( +-[Cc] +[^ ]+)* +commit' -f "$(dirname "$0")/lib/command-args.awk") || exit 0

block() {
  echo "Commit messages are a subject line only: no body, no trailers, no second paragraph. $1 Rerun as: git commit -m \"<subject>\"" >&2
  exit 2
}

message_flag_count=$(printf '%s\n' "$commit_args" | grep -cE '^(-[a-zA-Z]*m|-m.+|--message(=.*)?)$')
[ "$message_flag_count" -gt 1 ] && block "Found more than one -m."
printf '%s\n' "$commit_args" | grep -qE '^(-[a-zA-Z]*F.*|--file(=.*)?)$' && block "Don't pass the message from a file or heredoc."
printf '%s\n' "$commit_args" | grep -qF '\n' && block "Found a newline in the message."

exit 0
