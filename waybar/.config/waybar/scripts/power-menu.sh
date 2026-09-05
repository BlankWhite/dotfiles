#!/bin/bash
# Power menu confirmation script for waybar

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
THEME_DIR="$SCRIPT_DIR/zenity-theme"

zenity_confirm() {
  XDG_CONFIG_HOME="$THEME_DIR" zenity "$@"
}

case "$1" in
  lock)
    hyprlock
    ;;
  logout)
    zenity_confirm --question --text="Log out of Hyprland?" --title="Logout" \
      --ok-label="Logout" --cancel-label="Cancel" \
      && hyprctl dispatch exit
    ;;
  reboot)
    zenity_confirm --question --text="Reboot now?" --title="Reboot" \
      --ok-label="Reboot" --cancel-label="Cancel" \
      && systemctl reboot
    ;;
  suspend)
    zenity_confirm --question --text="Suspend now?" --title="Suspend" \
      --ok-label="Suspend" --cancel-label="Cancel" \
      && { systemctl suspend || loginctl suspend; }
    ;;
  shutdown|"")
    zenity_confirm --question --text="Shutdown now?" --title="Shutdown" \
      --ok-label="Shutdown" --cancel-label="Cancel" \
      && shutdown now
    ;;
  *)
    echo "Usage: $0 {lock|logout|reboot|suspend|shutdown}"
    exit 1
    ;;
esac
