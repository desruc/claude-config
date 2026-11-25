#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

. "$(dirname "$0")/lib/command-args.sh"

command=$(jq -r '.tool_input.command // empty')
case "$command" in *test*|*jest*) ;; *) exit 0 ;; esac

block() {
  echo "Don't run a whole test suite or project. Filter to the tests your change affects, for example dotnet test --filter, jest or vitest with a path or -t, pytest with a path or -k, go test ./pkg -run." >&2
  exit 2
}

require_dotnet_filter() {
  printf '%s\n' "$invocation_args" | grep -qE '^--filter(=.*)?$' || block
}

require_go_run_for_all_packages() {
  printf '%s\n' "$invocation_args" | grep -qE '\.\.\.$' || return 0
  printf '%s\n' "$invocation_args" | grep -qE '^-run(=.*)?$' || block
}

require_runner_filter() {
  printf '%s\n' "$invocation_args" | grep -qE '^[^-]|^--(testNamePattern|testPathPattern|grep|filter)=' || block
}

each_invocation "$command" 'dotnet +test' require_dotnet_filter
each_invocation "$command" 'go +test' require_go_run_for_all_packages
for runner_pattern in \
  '(npm|pnpm|yarn|bun)( +run)? +test' \
  '((npx|bunx|yarn|pnpm( +exec)?) +)?jest' \
  '((npx|bunx|yarn|pnpm( +exec)?) +)?vitest( +run)?' \
  '((python3? +-m|uv +run|poetry +run) +)?pytest'
do
  each_invocation "$command" "$runner_pattern" require_runner_filter
done
exit 0
