#!/bin/zsh

USAGE_MSG='Usage: templater --src=<file-or-dir> --dest=<file-or-dir> [--dest-prefix=<partial-path-dir>] --values=<file>'

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

  local value_occurrences
  value_occurrences=$(grep --color=never --only-matching --extended-regexp \
    '<%\s*([A-Za-z0-9_\.]+)\s*%>' "$template_file" \
    | sed --regexp-extended 's/<%\s*(.*)\s*%>/\1/' \
    | uniq)
  local value_occurrence
  echo "$value_occurrences" | while read -r value_occurrence; do
    if [ -n "$value_occurrence" ]; then
      local value
      value=$(yq -r "$value_occurrence" "$values_file" | sed --regexp-extended 's#/#\\/#g')
      sed --in-place --regexp-extended "s/<%\\s*${value_occurrence}\\s*%>/$value/g" "$template_file"
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
  filename=$(basename "$src_file")
  local bundle_copy
  bundle_copy=$(concat_paths_and_clean "$dest_dir" "$filename")
  substitute_in_place "$bundle_copy" "$values"
}

function resolve_template_from_file_to_file {
  local src_file="$1"
  local dest_file="$2"
  local values="$3"

  local parents
  parents=$(dirname "$dest_file")
  mkdir --verbose --parents "$parents"
  cp --no-target-directory "$src_file" "$dest_file"
  substitute_in_place "$dest_file" "$values"
}

function resolve_template_from_dir_to_dir {
  local src_dir
  src_dir=$(concat_paths_and_clean "$1" '')
  local dest_dir
  dest_dir=$(concat_paths_and_clean "$2" '')
  local values="$3"

  # create bundle dirs
  local template_dir
  for template_dir in $(find "$src_dir" -type d | sed --regexp-extended 's#(.*)#\1/#'); do
    local unprefixed_src_dir
    unprefixed_src_dir=$(echo -n "$template_dir" | sed --regexp-extended "s#^$src_dir(.*)#\1#")
    local dest_subdir
    dest_subdir=$(concat_paths_and_clean "$dest_dir" "$unprefixed_src_dir")
    mkdir --verbose --parents "$dest_subdir"
  done

  # create bundle files resolved
  local template_file
  for template_file in $(find "$src_dir" -type f); do
    local unprefixed_src_file
    unprefixed_src_file=$(echo -n "$template_file" | sed --regexp-extended "s#^$src_dir(.*)#\1#")
    local dest_file
    dest_file=$(concat_paths_and_clean "$dest_dir" "$unprefixed_src_file")
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
    dest_dir=$(concat_paths_and_clean "$dest_file_or_dir" "$dest_prefix")
    resolve_template_from_file_to_dir "$src_file" "$dest_dir" "$values"
  elif [[ "$dest_file_or_dir" == */ ]]; then
    local dest_dir
    dest_dir=$(concat_paths_and_clean "$dest_file_or_dir" '')
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
    dest_dir=$(concat_paths_and_clean "$dest" "$dest_prefix")
    resolve_template_from_dir_to_dir "$src" "$dest_dir" "$values"
  elif [ -f "$src" ]; then
    resolve_template "$src" "$dest" "$values" "$dest_prefix"
  else
    err_no_src_found "$src"
    exit 1
  fi
}

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
