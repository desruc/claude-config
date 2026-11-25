#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

. "$(dirname "$0")/lib/command-args.sh"

block() {
  echo "Commit messages are a subject line only: no body, no trailers, no second paragraph. $1 Rerun as: git commit -m \"<subject>\"" >&2
  exit 2
}

check_commit() {
  message_flag_count=$(printf '%s\n' "$invocation_args" | grep -cE '^(-[a-zA-Z]*m|-m.+|--message(=.*)?)$')
  [ "$message_flag_count" -gt 1 ] && block "Found more than one -m."
  printf '%s\n' "$invocation_args" | grep -qE '^(-[a-zA-Z]*F.*|--file(=.*)?)$' && block "Don't pass the message from a file or heredoc."
  printf '%s\n' "$invocation_args" | grep -qF '\n' && block "Found a newline in the message."
}

each_invocation "$(jq -r '.tool_input.command // empty')" 'git( +-[Cc] +[^ ]+)* +commit' check_commit
exit 0
