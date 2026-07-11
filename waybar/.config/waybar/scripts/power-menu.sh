#!/bin/bash
# Power menu confirmation script for waybar

case "$1" in
  lock)
    hyprlock
    ;;
  logout)
    zenity --question --text="Log out of Hyprland?" --title="Logout" \
      --ok-label="Logout" --cancel-label="Cancel" \
      && hyprctl dispatch exit
    ;;
  reboot)
    zenity --question --text="Reboot now?" --title="Reboot" \
      --ok-label="Reboot" --cancel-label="Cancel" \
      && systemctl reboot
    ;;
  suspend)
    systemctl suspend || loginctl suspend
    ;;
  shutdown|"")
    zenity --question --text="Shutdown now?" --title="Shutdown" \
      --ok-label="Shutdown" --cancel-label="Cancel" \
      && shutdown now
    ;;
  *)
    echo "Usage: $0 {lock|logout|reboot|suspend|shutdown}"
    exit 1
    ;;
esac
