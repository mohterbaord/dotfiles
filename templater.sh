#!/bin/zsh


USAGE_MSG='Usage: templater --src=<file-or-dir> --dest=<file-or-dir> [--dest-prefix=<partial-path-dir>] --values=<file>'

PATTERN_IDENTIFIER='[A-Za-z_][A-Za-z_0-9]*'
PATTERN_IDENTIFIER_ENV_VAR="$( printf '\$%s' "$PATTERN_IDENTIFIER" )"
PATTERN_IDENTIFIER_YAML_KEY="$( printf '\.?%s((\.%s)*)' "$PATTERN_IDENTIFIER" "$PATTERN_IDENTIFIER" )"

PATTERN_PLACEHOLDER_VALUES='%%\{\s*%s\s*\}'
PATTERN_PLACEHOLDER_VALUES_KEY="$( printf '(%s|%s)' "$PATTERN_IDENTIFIER_ENV_VAR" "$PATTERN_IDENTIFIER_YAML_KEY" )"

PATTERN_PLACEHOLDER_TEMPLATER='<%%\s*%s\s*%%>'
PATTERN_PLACEHOLDER_TEMPLATER_KEY="$( printf '((\.%s)+)' "$PATTERN_IDENTIFIER" )"


# Returns unique placeholder contents of passed value as a sequence that can be processed in while loop.
#
# Examples:
#   - '%{ $HOME }/.config/%{ .path.log_dir }/yet-again/%{ .path.log_dir }' -> '$HOME' '.path.log_dir'
#   - '#%{ black }' -> 'black'
#
function find_placeholder_contents_in_value() {
  local value="$1"

  local pattern_placeholder
  pattern_placeholder="$( printf "$PATTERN_PLACEHOLDER_VALUES" "$PATTERN_PLACEHOLDER_VALUES_KEY" )"

  local pattern_placeholder_content
  pattern_placeholder_content="$( printf "$PATTERN_PLACEHOLDER_VALUES" '(.*)' )"

  echo -n "$value" \
    | grep --color=never --only-matching --extended-regexp "$pattern_placeholder" \
    | sed --regexp-extended "s/$pattern_placeholder_content/\\1/" \
    | uniq
}

function get_placeholder_substitution() {
  local placeholder="$1"
  local yaml_file="$2"
  if [[ "$placeholder" == .* ]]; then
    echo -n "$( yq -r "$placeholder" "$yaml_file" )"
  elif [[ "$placeholder" == \$* ]]; then
    local variable_name
    variable_name="$( echo -n "$placeholder" | sed --regexp-extended 's/^\$(.*)/\1/' )"
    echo -n "$( printenv "$variable_name" )"
  else
    # TODO: same scope key
    echo
  fi
}

function escape_for_sed() {
  local value="$1"
  echo -n "$value" | sed --regexp-extended 's/([\\\/\^\$])/\\\1/g'
}

function substitute_placeholder_in_all_places() {
  local value="$1"
  local placeholder="$2"
  local yaml_file="$3"

  local placeholder_escaped
  placeholder_escaped="$( escape_for_sed "$placeholder" )"

  local pattern_placeholder_escaped
  pattern_placeholder_escaped="$( printf "$PATTERN_PLACEHOLDER_VALUES" "$placeholder_escaped" )"

  local final_value
  final_value="$( get_placeholder_substitution "$placeholder" "$yaml_file" )"

  local final_value_escaped
  final_value_escaped="$( escape_for_sed "$final_value" )"

  echo -n "$value" \
    | sed --regexp-extended "s/$pattern_placeholder_escaped/$final_value_escaped/g"
}


# Wrong usage examples:
#
#   * ```yaml
#
#     key: '%{ .key }'
#
#   ``` -> error (self reference)
#
#   * ```yaml
#
#     key_a: '%{ .key_b }'
#     key_b: '%{ .key_a }'
#
#   ``` -> error (cyclic reference)
#
function get_value_substituted() {
  local raw_value_orig="$1"
  local raw_value="$2"
  local yaml_file="$3"

  local yaml_placeholders
  yaml_placeholders="$( find_placeholder_contents_in_value "$raw_value" )"
  if [ -z "$yaml_placeholders" ]; then
    echo -n "$raw_value"
  else
    local raw_value_next
    local yaml_placeholder
    echo "$yaml_placeholders" | while read -r yaml_placeholder; do
      if [ -n "$yaml_placeholder" ]; then
        raw_value_next="$( substitute_placeholder_in_all_places "$raw_value" "$yaml_placeholder" "$yaml_file" )"
        if [ "$raw_value_next" = "$raw_value_orig" ]; then
          exit 1
        fi
      fi
    done
    get_value_substituted "$raw_value" "$raw_value_next" "$yaml_file"
  fi
}

function get_value_from_yaml() {
  local key="$1"
  local yaml_file="$2"

  local raw_value
  raw_value="$( yq -r "$key" "$yaml_file" )"

  get_value_substituted "$raw_value" "$raw_value" "$yaml_file"
}

function err_param_required {
  local param="$1"
  echo -e "Parameter $param should be specified\n\n  $USAGE_MSG\n"
}

function err_param_unknown {
  local param="$1"
  echo -e "Unknown parameter: $param\n\n  $USAGE_MSG\n"
}

function err_no_src_found {
  local not_found_src="$1"
  echo -e "Source file or directory was not found: $not_found_src\n\n  $USAGE_MSG\n"
}

function err_no_values_found {
  local not_found_values="$1"
  echo -e "Values file was not found: $not_found_values\n\n  $USAGE_MSG\n"
}

function concat_paths_and_clean {
  local one_path="$1"
  local another_path="$2"
  echo -n "$one_path/$another_path" | sed --regexp-extended 's|/+|/|g'
}

function substitute_in_place {
  local template_file="$1"
  local values_file="$2"

  if [ ! -f "$values_file" ]; then
    err_no_values_found "$values_file"
    exit 1
  fi

  local pattern_placeholder
  pattern_placeholder="$( printf "$PATTERN_PLACEHOLDER_TEMPLATER" "$PATTERN_PLACEHOLDER_TEMPLATER_KEY" )"

  local pattern_placeholder_content
  pattern_placeholder_content="$( printf "$PATTERN_PLACEHOLDER_TEMPLATER" '(.*)' )"

  local value_occurrences
  value_occurrences="$( grep --color=never --only-matching --extended-regexp "$pattern_placeholder" "$template_file" \
    | sed --regexp-extended "s/$pattern_placeholder_content/\\1/" \
    | uniq )"
  local value_occurrence
  local pattern_placeholder_content_occurrence
  local value
  local value_escaped
  echo "$value_occurrences" | while read -r value_occurrence; do
    if [ -n "$value_occurrence" ]; then
      pattern_placeholder_content_occurrence="$( printf "$PATTERN_PLACEHOLDER_TEMPLATER" "$value_occurrence" )"
      value="$( get_value_from_yaml "$value_occurrence" "$values_file" )"
      value_escaped="$( escape_for_sed "$value" )"
      sed --in-place --regexp-extended "s/$pattern_placeholder_content_occurrence/$value_escaped/g" "$template_file"
    fi
  done
}

function resolve_template_from_file_to_dir {
  local src_file="$1"
  local dest_dir="$2"
  local values="$3"

  mkdir --verbose --parents "$dest_dir"
  cp "$src_file" "$dest_dir"
  local filename
  filename="$( basename "$src_file" )"
  local bundle_copy
  bundle_copy="$( concat_paths_and_clean "$dest_dir" "$filename" )"
  substitute_in_place "$bundle_copy" "$values"
}

function resolve_template_from_file_to_file {
  local src_file="$1"
  local dest_file="$2"
  local values="$3"

  local parents
  parents="$( dirname "$dest_file" )"
  mkdir --verbose --parents "$parents"
  cp --no-target-directory "$src_file" "$dest_file"
  substitute_in_place "$dest_file" "$values"
}

function resolve_template_from_dir_to_dir {
  local src_dir
  src_dir="$( concat_paths_and_clean "$1" '' )"
  local dest_dir
  dest_dir="$( concat_paths_and_clean "$2" '' )"
  local values="$3"

  # create bundle dirs
  local template_dir
  local unprefixed_src_dir
  local dest_subdir
  find "$src_dir" -type d | sed --regexp-extended 's#(.*)#\1/#' | while read -r template_dir; do
    unprefixed_src_dir="$( echo -n "$template_dir" | sed --regexp-extended "s#^$src_dir(.*)#\1#" )"
    dest_subdir="$( concat_paths_and_clean "$dest_dir" "$unprefixed_src_dir" )"
    mkdir --verbose --parents "$dest_subdir"
  done

  # create bundle files resolved
  local template_file
  local unprefixed_src_file
  local dest_file
  find "$src_dir" -type f | while read -r template_file; do
    unprefixed_src_file="$( echo -n "$template_file" | sed --regexp-extended "s#^$src_dir(.*)#\1#" )"
    dest_file="$( concat_paths_and_clean "$dest_dir" "$unprefixed_src_file" )"
    resolve_template_from_file_to_file "$template_file" "$dest_file" "$values"
  done
}

function resolve_template {
  local src_file="$1"
  local dest_file_or_dir="$2"
  local values="$3"
  local dest_prefix="$4"

  if [ -n "$dest_prefix" ]; then
    local dest_dir
    dest_dir="$( concat_paths_and_clean "$dest_file_or_dir" "$dest_prefix" )"
    resolve_template_from_file_to_dir "$src_file" "$dest_dir" "$values"
  elif [[ "$dest_file_or_dir" == */ ]]; then
    local dest_dir
    dest_dir="$( concat_paths_and_clean "$dest_file_or_dir" '' )"
    resolve_template_from_file_to_dir "$src_file" "$dest_dir" "$values"
  else
    resolve_template_from_file_to_file "$src_file" "$dest_file_or_dir" "$values"
  fi
}

function compile_bundle_from_template {
  local src="$1"
  local dest="$2"
  local values="$3"
  local dest_prefix="$4"

  if [ -d "$src" ]; then
    local dest_dir
    dest_dir="$( concat_paths_and_clean "$dest" "$dest_prefix" )"
    resolve_template_from_dir_to_dir "$src" "$dest_dir" "$values"
  elif [ -f "$src" ]; then
    resolve_template "$src" "$dest" "$values" "$dest_prefix"
  else
    err_no_src_found "$src"
    exit 1
  fi
}

main() {
  for arg in "$@"; do
    case $arg in
      --src=*)
        SRC="${arg#*=}"
        shift
        ;;
      --dest=*)
        DEST="${arg#*=}"
        shift
        ;;
      --values=*)
        VALUES="${arg#*=}"
        shift
        ;;
      --dest-prefix=*)
        DEST_PREFIX="${arg#*=}"
        shift
        ;;
      *)
        err_param_unknown "$arg"
        exit 1
        ;;
    esac
  done
  unset arg

  if [ -z "$SRC" ]; then
    err_param_required '--src'
    exit 1
  fi

  if [ -z "$DEST" ]; then
    err_param_required '--dest'
    exit 1
  fi

  if [ -z "$VALUES" ]; then
    err_param_required '--values'
    exit 1
  fi

  compile_bundle_from_template "$SRC" "$DEST" "$VALUES" "$DEST_PREFIX"
}

main "$@"
