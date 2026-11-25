#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

. "$(dirname "$0")/lib/command-args.sh"

hook_input=$(cat)
working_directory=$(printf '%s' "$hook_input" | jq -r '.cwd // "."')

check_pr_title() {
  pr_title=$(printf '%s\n' "$invocation_args" | awk '
    previous_arg == "--title" || previous_arg == "-t" { print; exit }
    /^--title=/ { sub(/^--title=/, ""); print; exit }
    { previous_arg = $0 }
  ')
  [ -z "$pr_title" ] && ! printf '%s\n' "$invocation_args" | grep -qE '^(-f|--fill(-first|-verbose)?)$' && return

  [ "$(git -C "$working_directory" config --type=bool claude.conventionalPrTitles 2>/dev/null)" = "false" ] && return

  printf '%s\n' "$pr_title" | grep -qE '^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([^)]+\))?!?: [^ ]' && return

  echo "PR titles use Conventional Commits: type(scope): plain descriptive sentence, where type is one of build, chore, ci, docs, feat, fix, perf, refactor, revert, style or test. The scope is optional. With --fill, pass --title too, since a filled title comes from a commit subject." >&2
  exit 2
}

each_invocation "$(printf '%s' "$hook_input" | jq -r '.tool_input.command // empty')" 'gh +pr +(create|edit)' check_pr_title
exit 0
