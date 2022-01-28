#!/bin/sh

function _resolve_template {
  local input_file=$1
  local output_file=$2
  cp "$input_file" "$output_file"
  for pair in ${*:3}; do
    local replace_template=$(echo "$pair" | sed --regexp-extended "s/^(\w+)=(.*)$/s|%\1%|\2|g/")
    sed --in-place --regexp-extended "$replace_template" "$output_file"
  done
}

CONFIG_DIR="$1"

for template_file in $(find "$CONFIG_DIR" -name '*.template.ini'); do
  resolved=$(echo "$template_file" | sed --regexp-extended "s|.template.ini$|.ini|")
  _resolve_template "$template_file" "$resolved" ${*:2}
done
