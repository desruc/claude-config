command_args_program="$(dirname "$0")/lib/command-args.awk"

each_invocation() {
  invocation_number=1
  while invocation_args=$(printf '%s\n' "$1" | awk -v command_pattern="$2" -v invocation_number="$invocation_number" -f "$command_args_program"); do
    "$3"
    invocation_number=$((invocation_number + 1))
  done
}
