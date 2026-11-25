BEGIN {
  RS = "\001"
  word_separator = "\037"
  gsub(/ /, word_separator, command_pattern)
}

{
  text = without_heredoc_bodies($0)
  for (i = 1; i <= length(text); i++) {
    c = substr(text, i, 1)
    next_c = substr(text, i + 1, 1)
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
    if (c == "#" && !has_arg) {
      comment_length = index(substr(text, i), "\n")
      if (comment_length == 0) break
      i += comment_length - 2
      continue
    }
    if (c == " " || c == "\t") { end_word(); continue }
    if (c == "<" || c == ">") {
      if (arg ~ /^[0-9]+$/) { arg = ""; has_arg = 0 } else end_word()
      while (substr(text, i + 1, 1) ~ /[<>&]/) i++
      if (substr(text, i, 1) == "<" && substr(text, i + 1, 1) == "-") i++
      skip_next_word = 1
      continue
    }
    if (index("\n;&|()", c)) { end_simple_command(); continue }
    arg = arg c
    has_arg = 1
  }
  end_simple_command()
}

END { if (!invocation_found) exit 1 }

function end_word() {
  if (has_arg) {
    if (skip_next_word) skip_next_word = 0
    else words[++word_count] = arg
  }
  arg = ""
  has_arg = 0
}

function end_simple_command(    last_word, first_word, joined, word_index, command_prefix, command_word_count, argument) {
  end_word()
  skip_next_word = 0
  last_word = word_count
  word_count = 0
  first_word = 1
  while (first_word <= last_word && words[first_word] ~ /^([A-Za-z_][A-Za-z0-9_]*=.*|if|then|else|elif|while|until|do|time|!|\{)$/) first_word++
  joined = ""
  for (word_index = first_word; word_index <= last_word; word_index++) {
    joined = joined (word_index > first_word ? word_separator : "") words[word_index]
  }
  if (!match(joined, "^(" command_pattern ")(" word_separator "|$)")) return
  if (++invocation_count != invocation_number) return
  invocation_found = 1
  command_prefix = substr(joined, 1, RLENGTH)
  if (command_prefix ~ word_separator "$") command_word_count = gsub(word_separator, "", command_prefix)
  else command_word_count = last_word - first_word + 1
  for (word_index = first_word + command_word_count; word_index <= last_word; word_index++) {
    argument = words[word_index]
    gsub(/\n/, "\036", argument)
    print argument
  }
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
