#!/bin/sh -e

FG_GREEN='\033[0;32m'
FG_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

POLYBAR_HOME="$HOME/.config/polybar"
BUNDLE_DIR="dist"

function _log() {
  echo -e "$1$COLOR_RESET"
}

function _log_success() {
  _log "${FG_GREEN}SUCCESS: $1"
}

function _log_info() {
  _log "${FG_BLUE}INFO: $1"
}

#

function _generate_polybar_config() {
  _log_info "Generating Polybar configs from templates..."
  ./resolve-template.sh \
    ./config \
    "PB_BIN_PATH=$POLYBAR_HOME/bin" \
    "PB_CONFIG_INCLUDE_PATH=$POLYBAR_HOME/config/include"
  _log_success "Polybar config generated"
}

_generate_polybar_config
