#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

. "$(dirname "$0")/lib/command-args.sh"

require_draft() {
  printf '%s\n' "$invocation_args" | grep -qE '^(-d|--draft(=true)?)$' && return
  echo "PRs are always created as drafts. Rerun gh pr create with --draft." >&2
  exit 2
}

each_invocation "$(jq -r '.tool_input.command // empty')" 'gh +pr +create' require_draft
exit 0
