#!/bin/sh

PB_BIN_PATH="$POLYBAR_HOME/bin"
PB_CONFIG_PATH="$POLYBAR_HOME/config"
PB_CONFIG_INCLUDE_PATH="$PB_CONFIG_PATH/include"

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar
echo "---" | tee -a /tmp/polybar.log

polybar --config="$PB_CONFIG_PATH/config.ini" status-bar 2>&1 \
  | tee -a /tmp/polybar.log & disown

echo "Polybar launched..."
