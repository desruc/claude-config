#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')

case "$path" in
  */.claude/projects/*/memory/*)
    echo "Auto memory is off. Don't write memory files; propose a CLAUDE.md line or a check instead." >&2
    exit 2
    ;;
esac
exit 0
