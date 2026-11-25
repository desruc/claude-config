#!/bin/sh
set -u

hooks_dir=$(cd "$(dirname "$0")/../hooks" && pwd)
fixtures_dir=$(mktemp -d)
trap 'rm -rf "$fixtures_dir"' EXIT

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
git init -q "$fixtures_dir/personal"
git init -q "$fixtures_dir/opted-out"
git -C "$fixtures_dir/opted-out" config claude.conventionalPrTitles false

case_count=0
failure_count=0

check() {
  expected_outcome=$1
  hook_name=$2
  command=$3
  repo_name=${4:-personal}
  hook_input=$(jq -n --arg command "$command" --arg cwd "$fixtures_dir/$repo_name" '{cwd: $cwd, tool_input: {command: $command}}')
  printf '%s' "$hook_input" | sh "$hooks_dir/$hook_name.sh" >/dev/null 2>&1
  exit_code=$?
  case $exit_code in
    0) actual_outcome=allow ;;
    2) actual_outcome=block ;;
    *) actual_outcome="exit $exit_code" ;;
  esac
  case_count=$((case_count + 1))
  if [ "$actual_outcome" != "$expected_outcome" ]; then
    failure_count=$((failure_count + 1))
    printf 'FAIL %s in %s: expected %s, got %s\n%s\n\n' "$hook_name" "$repo_name" "$expected_outcome" "$actual_outcome" "$command"
  fi
}

allow() { check allow "$@"; }
block() { check block "$@"; }

allow commit-subject-only 'git commit -m "Fix the user'\''s settings path"'
allow commit-subject-only "git add -A && git commit -am 'Tidy imports' && git push"
allow commit-subject-only "python3 - <<'EOF'
cases = ['cd repo; git commit -m a -m b']
EOF"
allow commit-subject-only 'git commit -m "Escape \n in log output"'
block commit-subject-only 'git commit -m "Subject" -m "Body"'
block commit-subject-only 'git commit -m "Subject" --trailer "Co-authored-by: A <a@example.com>"'
block commit-subject-only 'git commit -s -m "Subject"'
block commit-subject-only 'git commit -C HEAD~1'
block commit-subject-only 'git commit -m "Subject

Body"'
block commit-subject-only "git commit -m \$'Subject\n\nBody'"
block commit-subject-only 'git commit -m "$(printf "Subject\n\nBody")"'
block commit-subject-only "git commit -m \"\$(cat <<'EOF'
Subject
EOF
)\""
block commit-subject-only "git commit -F- <<'EOF'
Subject
EOF"
block commit-subject-only 'git commit -m "Subject" && git commit -m "Subject" -m "Body"'
block commit-subject-only 'if git diff --quiet; then :; else git commit -m "Subject" -m "Body"; fi'

allow draft-prs-only 'gh pr create --draft --title "feat: add login" --body "Body"'
allow draft-prs-only 'gh pr create -d --title "feat: add login" --body "Body"'
block draft-prs-only 'gh pr create --title "feat: add login" --body "Body"'
block draft-prs-only 'gh pr create --title "feat: add login" --body "Run it with --draft first"'
block draft-prs-only 'gh pr create --draft --title "feat: add login" && gh pr create --title "feat: add logout"'
allow draft-prs-only 'echo "Next: git push && gh pr create --title x"'

allow conventional-pr-titles 'gh pr create --draft --title "fix(auth)!: reject expired tokens" --body "Body"'
allow conventional-pr-titles 'gh pr create --draft --fill'
allow conventional-pr-titles 'gh pr create --draft --title "Add login page" --body "Body"' opted-out
block conventional-pr-titles 'gh pr create --draft --title "Add login page" --body "Body"'
block conventional-pr-titles 'gh pr edit 12 --title "Add login page"'

allow filtered-tests-only 'dotnet build && dotnet test --no-build --filter "FullyQualifiedName~Login"'
allow filtered-tests-only 'npx jest src/login.test.ts'
allow filtered-tests-only 'go test ./... -run TestLogin'
allow filtered-tests-only 'pytest -x -n 4 tests/test_login.py'
allow filtered-tests-only 'npx vitest run --reporter verbose src/login.test.ts'
allow filtered-tests-only 'npm install -D jest vitest'
block filtered-tests-only 'dotnet test'
block filtered-tests-only 'CI=true npm test'
block filtered-tests-only 'python3 -m pytest -x'
block filtered-tests-only 'go test ./...'
block filtered-tests-only 'npm test 2>&1 | tail -20'
block filtered-tests-only 'npx jest --ci --maxWorkers 2'
block filtered-tests-only 'pytest -n 4'
block filtered-tests-only 'npm run test:unit'

echo "$((case_count - failure_count))/$case_count passed"
[ "$failure_count" -eq 0 ]
