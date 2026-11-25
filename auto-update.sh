#!/bin/bash
set -eu

state="$HOME/.local/share/team-skills-state"
repo="$HOME/.local/share/team-skills"
interval=2592000

notify_failure() {
  echo "Automatic team skills update failed. Run the install command again; see $state/update-error.log." >&2
  if ! osascript -e 'display notification "Team skills could not update. Check the update error log or run the install command again." with title "Team skills update failed"'; then
    echo "Could not display the macOS notification; see the error log." >&2
  fi
}
trap notify_failure EXIT

now=$(date +%s)
due_copilot=0
due_claude=0
for target in copilot claude; do
  stamp="$state/$target.last-update"
  [ -f "$stamp" ] || continue
  last=$(cat "$stamp")
  case "$last" in
    ''|*[!0-9]*)
      echo "Error: invalid update timestamp in $stamp." >&2
      exit 1
      ;;
  esac
  if [ "$((now - last))" -ge "$interval" ]; then
    if [ "$target" = copilot ]; then
      due_copilot=1
    else
      due_claude=1
    fi
  fi
done

if [ "$due_copilot" -eq 1 ] && [ "$due_claude" -eq 1 ]; then
  target=both
elif [ "$due_copilot" -eq 1 ]; then
  target=copilot
elif [ "$due_claude" -eq 1 ]; then
  target=claude
else
  trap - EXIT
  exit 0
fi

echo "Checking team skills updates for $target at $(date)."
TEAM_SKILLS_AUTO_UPDATE=1 bash "$repo/install.sh" "$target"
echo "Team skills update completed."
trap - EXIT
