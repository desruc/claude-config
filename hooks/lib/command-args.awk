function emit_arg() {
  if (has_arg) {
    gsub(/\n/, "\\n", arg)
    print arg
  }
  arg = ""
  has_arg = 0
}

function without_heredoc_bodies(text,    lines, line_count, line_index, cleaned, delimiter, strip_tabs, candidate, marker) {
  line_count = split(text, lines, "\n")
  cleaned = ""
  delimiter = ""
  for (line_index = 1; line_index <= line_count; line_index++) {
    if (delimiter != "") {
      candidate = lines[line_index]
      if (strip_tabs) sub(/^\t+/, "", candidate)
      if (candidate == delimiter) {
        delimiter = ""
        cleaned = cleaned lines[line_index] "\n"
      } else {
        cleaned = cleaned "\n"
      }
      continue
    }
    cleaned = cleaned lines[line_index] "\n"
    if (match(lines[line_index], /<<-?[ \t]*['"]?[A-Za-z_][A-Za-z0-9_]*/) && substr(lines[line_index], RSTART - 1, 1) != "<") {
      marker = substr(lines[line_index], RSTART, RLENGTH)
      strip_tabs = (marker ~ /^<<-/)
      gsub(/[<'" \t-]/, "", marker)
      delimiter = marker
    }
  }
  return cleaned
}

BEGIN { RS = "\001" }

!found && match(text = without_heredoc_bodies($0), "(^|[\n;&|(])[ \t]*([A-Za-z_][A-Za-z0-9_]*=[^ \t]*[ \t]+)*" command_pattern "([ \t\n;&|)]|$)") {
  found = 1
  matched = substr(text, RSTART, RLENGTH)
  rest = ""
  if (matched ~ /[ \t\n;&|)]$/) rest = substr(text, RSTART + RLENGTH - 1)
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
