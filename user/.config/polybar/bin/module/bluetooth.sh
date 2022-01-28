#!/bin/sh

case "$1" in
  --toggle)
    bluetooth toggle
    ;;
  *)
    bluetooth status
    ;;
esac
