#!/bin/sh

case "$1" in
  --toggle)
    bluepoop toggle
    ;;
  *)
    bluepoop status
    ;;
esac
