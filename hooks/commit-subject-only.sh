#!/bin/sh
# PreToolUse hook. Exit 2 blocks the tool call and shows Claude the stderr.

. "$(dirname "$0")/lib/command-args.sh"

block() {
  echo "Commit messages are a subject line only: no body, no trailers, no second paragraph. $1 Rerun as: git commit -m \"<subject>\"" >&2
  exit 2
}

check_commit() {
  commit_problem=$(printf '%s\n' "$invocation_args" | awk '
    value_option != "" { apply(value_option, $0); value_option = ""; next }
    options_ended { next }
    $0 == "--" { options_ended = 1; next }
    /^--/ {
      option = substr($0, 3)
      equals_position = index(option, "=")
      if (equals_position) apply(substr(option, 1, equals_position - 1), substr(option, equals_position + 1))
      else if (option ~ /^(message|file|reuse-message|reedit-message|template|trailer|author|date|cleanup|fixup|squash|pathspec-from-file)$/) value_option = option
      else apply(option, "")
      next
    }
    /^-./ {
      for (flag_index = 2; flag_index <= length($0); flag_index++) {
        flag = substr($0, flag_index, 1)
        if (flag ~ /[mFCct]/) {
          if (flag_index < length($0)) apply(flag, substr($0, flag_index + 1))
          else value_option = flag
          next
        }
        if (flag ~ /[uS]/) next
        apply(flag, "")
      }
    }
    END {
      if (problem == "" && message_count > 1) problem = "Found more than one -m."
      print problem
    }

    function apply(option, value) {
      if (option == "m" || option == "message") {
        message_count++
        if (index(value, "\036") || ((index(value, "$(") || index(value, "`")) && index(value, "\\n"))) note("Found a newline in the message.")
      }
      else if (option == "F" || option == "file") note("Found a message from a file or heredoc.")
      else if (option ~ /^(C|c|reuse-message|reedit-message)$/) note("Found a message reused from another commit.")
      else if (option == "t" || option == "template") note("Found a commit message template.")
      else if (option ~ /^(s|signoff|trailer)$/) note("Found a trailer or sign-off.")
    }

    function note(found_problem) {
      if (problem == "") problem = found_problem
    }
  ')
  [ -n "$commit_problem" ] && block "$commit_problem"
}

each_invocation "$(jq -r '.tool_input.command // empty')" 'git( +-[Cc] +[^ ]+)* +commit' check_commit
exit 0
