#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

hook_input=$(cat)
command=$(printf '%s' "$hook_input" | jq -r '.tool_input.command // empty')
working_directory=$(printf '%s' "$hook_input" | jq -r '.cwd // "."')

pr_args=$(printf '%s\n' "$command" | awk -v command_pattern='gh +pr +(create|edit)' -f "$(dirname "$0")/lib/command-args.awk") || exit 0

pr_title=$(printf '%s\n' "$pr_args" | awk '
  previous_arg == "--title" || previous_arg == "-t" { print; exit }
  /^--title=/ { sub(/^--title=/, ""); print; exit }
  { previous_arg = $0 }
')
[ -z "$pr_title" ] && exit 0

if [ "$(git -C "$working_directory" config --type=bool claude.conventionalPrTitles 2>/dev/null)" = "false" ]; then
  repo_root=$(git -C "$working_directory" rev-parse --show-toplevel 2>/dev/null)
  [ -f "$repo_root/release-please-config.json" ] || [ -f "$repo_root/.release-please-manifest.json" ] \
    || ls "$repo_root"/.commitlintrc* "$repo_root"/commitlint.config.* >/dev/null 2>&1 \
    || grep -qsE 'googleapis/release-please-action|amannn/action-semantic-pull-request' "$repo_root"/.github/workflows/*.y*ml \
    || exit 0
fi

printf '%s\n' "$pr_title" | grep -qE '^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([^)]+\))?!?: [^ ]' && exit 0

echo "PR titles use Conventional Commits: type(scope): plain descriptive sentence, where type is one of build, chore, ci, docs, feat, fix, perf, refactor, revert, style or test. The scope is optional." >&2
exit 2
