#!/bin/bash
set -eu

usage() {
  echo "Usage: bash install.sh {copilot|claude|both}" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

case "$1" in
  copilot|claude|both) target=$1 ;;
  *) usage; exit 1 ;;
esac

if [ -z "${HOME:-}" ]; then
  echo "Error: HOME must be set." >&2
  exit 1
fi
if ! command -v git > /dev/null 2>&1; then
  echo "Error: Git is required. Install Apple's command line tools and try again." >&2
  exit 1
fi

remote="https://github.com/quatonomy/team-skills.git"
repo="$HOME/.local/share/team-skills"
copilot="$HOME/.copilot/skills"
claude="$HOME/.claude/skills"
copilot_instructions="$HOME/.copilot/instructions"
claude_instructions="$HOME/.claude/rules"
state="$HOME/.local/share/team-skills-state"
agent="$HOME/Library/LaunchAgents/com.quatonomy.team-skills-update.plist"
label="com.quatonomy.team-skills-update"

mkdir -p "$state"
if ! mkdir "$state/install.lock" 2>/dev/null; then
  echo "Error: another installation may be running, or $state/install.lock needs removing." >&2
  exit 1
fi
temp_plist=
cleanup() {
  if [ -n "$temp_plist" ]; then
    rm -f "$temp_plist"
  fi
  rmdir "$state/install.lock"
}
trap cleanup EXIT

setup_schedule() {
  if ! command -v launchctl > /dev/null 2>&1; then
    echo "Error: launchctl is required to schedule automatic updates on macOS." >&2
    return 1
  fi
  if [ ! -f "$repo/auto-update.sh" ]; then
    echo "Error: $repo/auto-update.sh is missing; automatic updates were not scheduled." >&2
    return 1
  fi
  mkdir -p "$(dirname "$agent")"
  temp_plist=$(mktemp "$state/launch-agent.XXXXXXXX")
  escaped_repo=$(printf '%s' "$repo" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  escaped_state=$(printf '%s' "$state" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  escaped_home=$(printf '%s' "$HOME" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
  cat > "$temp_plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$escaped_repo/auto-update.sh</string></array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>HOME</key><string>$escaped_home</string>
    <key>GIT_TERMINAL_PROMPT</key><string>0</string>
    <key>GIT_ASKPASS</key><string>/usr/bin/false</string>
  </dict>
  <key>StartInterval</key><integer>86400</integer>
  <key>StandardOutPath</key><string>$escaped_state/update.log</string>
  <key>StandardErrorPath</key><string>$escaped_state/update-error.log</string>
</dict>
</plist>
EOF
  if [ -e "$agent" ] || [ -L "$agent" ]; then
    if [ -L "$agent" ] || ! cmp -s "$temp_plist" "$agent"; then
      echo "Error: $agent already exists and differs from the expected launch agent; it was not changed." >&2
      return 1
    fi
  else
    mv "$temp_plist" "$agent"
    temp_plist=
  fi
  domain="gui/$(id -u)"
  if ! launchctl print "$domain/$label" > /dev/null 2>&1; then
    if ! launchctl bootstrap "$domain" "$agent"; then
      echo "Error: could not start the automatic update agent. Ensure you are logged in to macOS and retry." >&2
      return 1
    fi
  fi
  echo "Automatic update checks scheduled daily."
}

if [ -e "$repo" ] || [ -L "$repo" ]; then
  if [ ! -e "$repo/.git" ]; then
    echo "Error: $repo already exists and is not a Git checkout; it was not changed." >&2
    exit 1
  fi
  origin=$(git -C "$repo" config --get remote.origin.url) || {
    echo "Error: $repo has no origin remote." >&2
    exit 1
  }
  if [ "$origin" != "$remote" ]; then
    echo "Error: $repo has an unexpected origin ($origin); it was not changed." >&2
    exit 1
  fi
  branch=$(git -C "$repo" symbolic-ref --quiet --short HEAD) || {
    echo "Error: $repo is not on the main branch." >&2
    exit 1
  }
  if [ "$branch" != "main" ]; then
    echo "Error: $repo is on branch $branch, not main; it was not changed." >&2
    exit 1
  fi
  status=$(git -C "$repo" status --porcelain --untracked-files=normal) || {
    echo "Error: could not check for local changes in $repo." >&2
    exit 1
  }
  if [ -n "$status" ]; then
    echo "Error: $repo has local changes; resolve them before updating." >&2
    exit 1
  fi
  git -C "$repo" pull --ff-only origin main
else
  mkdir -p "$(dirname "$repo")"
  git clone --branch main --single-branch "$remote" "$repo"
fi

if [ ! -d "$repo/skills" ]; then
  echo "Error: $repo/skills is missing." >&2
  exit 1
fi

found=0
for skill in "$repo"/skills/*; do
  [ -f "$skill/SKILL.md" ] || continue
  found=1
done
if [ "$found" -eq 0 ]; then
  echo "Error: no skills with SKILL.md found in $repo/skills." >&2
  exit 1
fi
if [ ! -d "$repo/instructions" ]; then
  echo "Error: $repo/instructions is missing." >&2
  exit 1
fi

check_destination() {
  destination=$1
  if [ -e "$destination" ] && [ ! -d "$destination" ]; then
    echo "Error: $destination is not a directory." >&2
    return 1
  fi
  for skill in "$repo"/skills/*; do
    [ -f "$skill/SKILL.md" ] || continue
    name=${skill##*/}
    link="$destination/$name"
    if [ -e "$link" ] || [ -L "$link" ]; then
      if [ ! -L "$link" ] || [ "$(readlink "$link")" != "$skill" ]; then
        echo "Error: $link already exists and is not managed by this installer." >&2
        return 1
      fi
    fi
  done
}

install_destination() {
  destination=$1
  mkdir -p "$destination"
  for skill in "$repo"/skills/*; do
    [ -f "$skill/SKILL.md" ] || continue
    name=${skill##*/}
    link="$destination/$name"
    if [ ! -L "$link" ]; then
      ln -s "$skill" "$link"
    fi
  done
  for link in "$destination"/*; do
    [ -L "$link" ] || continue
    name=${link##*/}
    skill="$repo/skills/$name"
    if [ "$(readlink "$link")" = "$skill" ] && [ ! -f "$skill/SKILL.md" ]; then
      rm "$link"
    fi
  done
  echo "Skills installed in $destination"
}

check_instruction_destination() {
  destination=$1
  if [ -e "$destination" ] && [ ! -d "$destination" ]; then
    echo "Error: $destination is not a directory." >&2
    return 1
  fi
  for instruction in "$repo"/instructions/*.instructions.md; do
    [ -f "$instruction" ] || continue
    name=${instruction##*/}
    link="$destination/$name"
    if [ -e "$link" ] || [ -L "$link" ]; then
      if [ ! -L "$link" ] || [ "$(readlink "$link")" != "$instruction" ]; then
        echo "Error: $link already exists and is not managed by this installer." >&2
        return 1
      fi
    fi
  done
}

install_instruction_destination() {
  destination=$1
  mkdir -p "$destination"
  for instruction in "$repo"/instructions/*.instructions.md; do
    [ -f "$instruction" ] || continue
    name=${instruction##*/}
    link="$destination/$name"
    if [ ! -L "$link" ]; then
      ln -s "$instruction" "$link"
    fi
  done
  for link in "$destination"/*.instructions.md; do
    [ -L "$link" ] || continue
    name=${link##*/}
    instruction="$repo/instructions/$name"
    if [ "$(readlink "$link")" = "$instruction" ] && [ ! -f "$instruction" ]; then
      rm "$link"
    fi
  done
  echo "Instructions installed in $destination"
}

if [ "$target" = copilot ] || [ "$target" = both ]; then
  check_destination "$copilot"
  check_instruction_destination "$copilot_instructions"
fi
if [ "$target" = claude ] || [ "$target" = both ]; then
  check_destination "$claude"
  check_instruction_destination "$claude_instructions"
fi
if [ "$target" = copilot ] || [ "$target" = both ]; then
  install_destination "$copilot"
  install_instruction_destination "$copilot_instructions"
fi
if [ "$target" = claude ] || [ "$target" = both ]; then
  install_destination "$claude"
  install_instruction_destination "$claude_instructions"
fi

now=$(date +%s)
if [ "$target" = copilot ] || [ "$target" = both ]; then
  printf '%s\n' "$now" > "$state/copilot.last-update"
fi
if [ "$target" = claude ] || [ "$target" = both ]; then
  printf '%s\n' "$now" > "$state/claude.last-update"
fi
if [ "${TEAM_SKILLS_AUTO_UPDATE:-0}" != 1 ]; then
  setup_schedule
fi
