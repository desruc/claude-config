function emit_arg() {
  if (has_arg) {
    gsub(/\n/, "\\n", arg)
    print arg
  }
  arg = ""
  has_arg = 0
}

BEGIN { RS = "\001" }

!found && match($0, "(^|[ \t\n;&|(])" command_pattern "([ \t\n;&|)]|$)") {
  found = 1
  matched = substr($0, RSTART, RLENGTH)
  rest = ""
  if (matched ~ /[ \t\n;&|)]$/) rest = substr($0, RSTART + RLENGTH - 1)
  quote = ""
  for (i = 1; i <= length(rest); i++) {
    c = substr(rest, i, 1)
    next_c = substr(rest, i + 1, 1)
    if (quote == "'") {
      if (c == "'") quote = ""
      else arg = arg c
      continue
    }
    if (c == "\\") {
      i++
      if (next_c == "\n") continue
      if (quote == "\"" && index("$`\"\\", next_c) == 0) arg = arg c
      arg = arg next_c
      has_arg = 1
      continue
    }
    if (quote == "\"") {
      if (c == "\"") quote = ""
      else arg = arg c
      continue
    }
    if (c == "'" || c == "\"") { quote = c; has_arg = 1; continue }
    if (c == " " || c == "\t") { emit_arg(); continue }
    if (index("\n;&|)", c)) break
    arg = arg c
    has_arg = 1
  }
  emit_arg()
}

END { if (!found) exit 1 }
