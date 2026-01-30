#!/bin/bash
# Key codes: 4=21, 5=23, 6=22
case $1 in
  4) keycode=21 ;;
  5) keycode=23 ;;
  6) keycode=22 ;;
esac
osascript -e "tell application \"System Events\" to key code $keycode using option down"
