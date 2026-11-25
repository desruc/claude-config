#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

command=$(jq -r '.tool_input.command // empty')
case "$command" in *test*|*jest*) ;; *) exit 0 ;; esac

command_args() {
  printf '%s\n' "$command" | awk -v command_pattern="$1" -f "$(dirname "$0")/lib/command-args.awk"
}

block() {
  echo "Don't run a whole test suite or project; CI runs it. Filter to the tests your change affects, for example dotnet test --filter, jest or vitest with a path or -t, pytest with a path or -k, go test ./pkg -run." >&2
  exit 2
}

if dotnet_test_args=$(command_args 'dotnet +test'); then
  printf '%s\n' "$dotnet_test_args" | grep -qE '^--filter(=.*)?$' || block
fi

if go_test_args=$(command_args 'go +test'); then
  if printf '%s\n' "$go_test_args" | grep -qE '\.\.\.$'; then
    printf '%s\n' "$go_test_args" | grep -qE '^-run(=.*)?$' || block
  fi
fi

for runner_pattern in \
  '(npm|pnpm|yarn|bun)( +run)? +test' \
  '((npx|bunx|yarn|pnpm( +exec)?) +)?jest' \
  '((npx|bunx|yarn|pnpm( +exec)?) +)?vitest( +run)?' \
  '((python3? +-m|uv +run|poetry +run) +)?pytest'
do
  if runner_args=$(command_args "$runner_pattern"); then
    printf '%s\n' "$runner_args" | grep -qE '^[^-]|^--(testNamePattern|testPathPattern|grep|filter)=' || block
  fi
done

exit 0
