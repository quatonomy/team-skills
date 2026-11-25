#!/bin/bash
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/team-skills-test.XXXXXXXX")
trap 'rm -rf "$tmpdir"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

mkdir -p "$tmpdir/remote/skills/first" "$tmpdir/home & tester" "$tmpdir/bin"
printf '%s\n' 'first skill' > "$tmpdir/remote/skills/first/SKILL.md"
cp "$root/install.sh" "$root/auto-update.sh" "$tmpdir/remote/"
cat > "$tmpdir/bin/launchctl" <<'EOF'
#!/bin/bash
case "$1" in
  print) exit 1 ;;
  bootstrap) printf '%s\n' "$*" >> "$HOME/launchctl.log" ;;
  *) exit 1 ;;
esac
EOF
cat > "$tmpdir/bin/osascript" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$HOME/notifications.log"
EOF
chmod +x "$tmpdir/bin/launchctl" "$tmpdir/bin/osascript"
git -C "$tmpdir/remote" init -q
git -C "$tmpdir/remote" checkout -q -b main
git -C "$tmpdir/remote" config user.name "Installer Test"
git -C "$tmpdir/remote" config user.email "installer-test@example.com"
git -C "$tmpdir/remote" add skills install.sh auto-update.sh
git -C "$tmpdir/remote" commit -qm "Initial skills"

export HOME="$tmpdir/home & tester"
export PATH="$tmpdir/bin:$PATH"
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.file://$tmpdir/remote.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/quatonomy/team-skills.git"
repo="$HOME/.local/share/team-skills"
copilot="$HOME/.copilot/skills"
claude="$HOME/.claude/skills"
state="$HOME/.local/share/team-skills-state"
agent="$HOME/Library/LaunchAgents/com.quatonomy.team-skills-update.plist"

if bash "$root/install.sh" > /dev/null 2>&1; then
  fail "missing target was accepted"
fi
if bash "$root/install.sh" invalid > /dev/null 2>&1; then
  fail "invalid target was accepted"
fi
[ ! -e "$repo" ] || fail "missing target created a clone"

bash "$root/install.sh" copilot
[ -L "$copilot/first" ] || fail "Copilot skill not linked"
[ ! -e "$claude" ] || fail "Claude was installed without being selected"
[ "$(readlink "$copilot/first")" = "$repo/skills/first" ] || fail "incorrect link target"
[ -f "$agent" ] && [ -f "$HOME/launchctl.log" ] || fail "automatic updates not scheduled"
plutil -lint "$agent" > /dev/null || fail "invalid launch agent plist"
[ "$(/usr/libexec/PlistBuddy -c 'Print :EnvironmentVariables:HOME' "$agent")" = "$HOME" ] || fail "agent HOME incorrect"
[ "$(/usr/libexec/PlistBuddy -c 'Print :ProgramArguments:1' "$agent")" = "$repo/auto-update.sh" ] || fail "agent program incorrect"
[ "$(/usr/libexec/PlistBuddy -c 'Print :StartInterval' "$agent")" = 86400 ] || fail "agent interval incorrect"
[ -f "$state/copilot.last-update" ] && [ ! -e "$state/claude.last-update" ] || fail "wrong target recorded"

bash "$root/install.sh" claude
[ -L "$claude/first" ] || fail "Claude skill not linked"
bash "$root/install.sh" both

mkdir -p "$copilot/personal" "$tmpdir/remote/skills/second"
printf '%s\n' 'personal skill' > "$copilot/personal/SKILL.md"
printf '%s\n' 'second skill' > "$tmpdir/remote/skills/second/SKILL.md"
git -C "$tmpdir/remote" rm -qr skills/first
git -C "$tmpdir/remote" add skills
git -C "$tmpdir/remote" commit -qm "Update skills"
old=$(( $(date +%s) - 2591900 ))
printf '%s\n' "$old" > "$state/copilot.last-update"
printf '%s\n' "$old" > "$state/claude.last-update"
bash "$root/auto-update.sh"
[ ! -e "$copilot/second" ] || fail "updated before the 30-day threshold"
old=$(( $(date +%s) - 2592001 ))
printf '%s\n' "$old" > "$state/copilot.last-update"
printf '%s\n' "$old" > "$state/claude.last-update"
bash "$root/auto-update.sh"
[ -L "$copilot/second" ] && [ -L "$claude/second" ] || fail "new skill not linked"
[ "$(cat "$copilot/second/SKILL.md")" = "second skill" ] || fail "linked skill is not readable"
[ ! -L "$copilot/first" ] && [ ! -L "$claude/first" ] || fail "removed skill links remain"
[ -f "$copilot/personal/SKILL.md" ] || fail "personal skill was modified"

mkdir -p "$tmpdir/remote/skills/conflict" "$claude/conflict"
printf '%s\n' 'new skill' > "$tmpdir/remote/skills/conflict/SKILL.md"
printf '%s\n' 'personal skill' > "$claude/conflict/SKILL.md"
git -C "$tmpdir/remote" add skills
git -C "$tmpdir/remote" commit -qm "Add conflicting skill"
printf '%s\n' "$old" > "$state/copilot.last-update"
printf '%s\n' "$old" > "$state/claude.last-update"
if bash "$root/auto-update.sh" > /dev/null 2>&1; then
  fail "conflicting skill was accepted"
fi
[ -f "$HOME/notifications.log" ] || fail "failed automatic update did not notify"
[ "$(cat "$state/copilot.last-update")" = "$old" ] || fail "failed update changed timestamp"
[ ! -e "$copilot/conflict" ] || fail "links changed despite conflict"
[ "$(cat "$claude/conflict/SKILL.md")" = "personal skill" ] || fail "conflict was overwritten"

rm "$claude/conflict/SKILL.md"
rmdir "$claude/conflict"
bash "$root/auto-update.sh"
[ -L "$copilot/conflict" ] && [ -L "$claude/conflict" ] || fail "failed update did not retry"
[ "$(cat "$state/copilot.last-update")" != "$old" ] || fail "successful retry did not record timestamp"

mkdir -p "$tmpdir/remote/skills/third"
printf '%s\n' 'third skill' > "$tmpdir/remote/skills/third/SKILL.md"
git -C "$tmpdir/remote" add skills/third
git -C "$tmpdir/remote" commit -qm "Add third skill"
printf '%s\n' "$old" > "$state/copilot.last-update"
bash "$root/auto-update.sh"
[ -L "$copilot/third" ] || fail "due target was not updated"
[ ! -e "$claude/third" ] || fail "target was reconciled before it was due"
printf '%s\n' "$old" > "$state/claude.last-update"
bash "$root/auto-update.sh"
[ -L "$claude/third" ] || fail "separately due target was not reconciled"

printf '%s\n' 'local edit' >> "$repo/skills/second/SKILL.md"
if bash "$root/install.sh" copilot > /dev/null 2>&1; then
  fail "dirty clone was updated"
fi
grep -q 'local edit' "$repo/skills/second/SKILL.md" || fail "local edit was lost"

git -C "$repo" restore skills/second/SKILL.md
git -C "$repo" config remote.origin.url "https://example.com/unrelated.git"
if bash "$root/install.sh" copilot > /dev/null 2>&1; then
  fail "unexpected origin was accepted"
fi
git -C "$repo" config remote.origin.url "https://github.com/quatonomy/team-skills.git"
git -C "$repo" checkout -qb other-branch
if bash "$root/install.sh" copilot > /dev/null 2>&1; then
  fail "unexpected branch was accepted"
fi

printf '%s\n' "invalid" > "$state/copilot.last-update"
if bash "$root/auto-update.sh" > /dev/null 2>&1; then
  fail "invalid timestamp was accepted"
fi

echo "Installer tests passed."
