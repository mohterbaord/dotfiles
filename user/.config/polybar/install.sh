#!/bin/sh -e

FG_RED='\033[0;31m'
FG_GREEN='\033[0;32m'
FG_ORANGE='\033[0;33m'
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

function _log_warning() {
  _log "${FG_ORANGE}WARN: $1"
}

function _log_error() {
  _log "${FG_RED}ERROR: $1"
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

function _install_bundle_files() {
  _log_info "Installing bundle files..."
  if [ -d "$BUNDLE_DIR" ]; then
    _log_info "Removing old bundle directory"
    rm -rf "$BUNDLE_DIR"
  fi
  _log_info "Installing config files..."
  for ini in $(find "config" -not -name '*.template.ini' -name '*.ini'); do
    install -D "$ini" "$BUNDLE_DIR/$ini"
    _log_info "Installed \"$ini\" -> \"$BUNDLE_DIR/$ini\""
  done
  _log_info "Installing bin files..."
  cp --recursive "bin" "$BUNDLE_DIR"
  for script in $(find "$BUNDLE_DIR/bin" -name '*.sh'); do
    chmod +x "$script"
  done
  _log_success "Polybar bundle complete"
}

function _compile_bundle() {
  _generate_polybar_config
  _install_bundle_files
}

#

_log_info "Installing polybar configs to \"$POLYBAR_HOME\"..."
if [ -d "$POLYBAR_HOME" ]; then
  _log_warning "Polybar home \"$POLYBAR_HOME\" already exist, removing"
  rm -rf "$POLYBAR_HOME"
else
  _log_info "No previous polybar home found"
fi
_compile_bundle
install -d "$POLYBAR_HOME"
cp -r "$BUNDLE_DIR"/* "$POLYBAR_HOME"
_log_success "Polybar successfully installed"
