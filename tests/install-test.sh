#!/bin/bash
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/team-skills-test.XXXXXXXX")
trap 'rm -rf "$tmpdir"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

mkdir -p "$tmpdir/remote/skills/first" "$tmpdir/remote/skills/team-skills-test-driven-development" "$tmpdir/remote/instructions" "$tmpdir/home & tester" "$tmpdir/bin"
printf '%s\n' 'first skill' > "$tmpdir/remote/skills/first/SKILL.md"
printf '%s\n' 'old TDD skill' > "$tmpdir/remote/skills/team-skills-test-driven-development/SKILL.md"
printf '%s\n' 'first instruction' > "$tmpdir/remote/instructions/first.instructions.md"
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
git -C "$tmpdir/remote" add skills instructions install.sh auto-update.sh
git -C "$tmpdir/remote" commit -qm "Initial skills"

export HOME="$tmpdir/home & tester"
export PATH="$tmpdir/bin:$PATH"
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.file://$tmpdir/remote.insteadOf"
export GIT_CONFIG_VALUE_0="https://github.com/quatonomy/team-skills.git"
repo="$HOME/.local/share/team-skills"
copilot="$HOME/.copilot/skills"
claude="$HOME/.claude/skills"
copilot_instructions="$HOME/.copilot/instructions"
claude_instructions="$HOME/.claude/rules"
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
[ -L "$copilot/team-skills-test-driven-development" ] || fail "old TDD skill not linked"
[ -L "$copilot_instructions/first.instructions.md" ] || fail "Copilot instruction not linked"
[ "$(readlink "$copilot_instructions/first.instructions.md")" = "$repo/instructions/first.instructions.md" ] || fail "incorrect Copilot instruction link target"
[ ! -e "$claude" ] || fail "Claude was installed without being selected"
[ ! -e "$claude_instructions" ] || fail "Claude instructions were installed without being selected"
[ "$(readlink "$copilot/first")" = "$repo/skills/first" ] || fail "incorrect link target"
[ -f "$agent" ] && [ -f "$HOME/launchctl.log" ] || fail "automatic updates not scheduled"
plutil -lint "$agent" > /dev/null || fail "invalid launch agent plist"
[ "$(/usr/libexec/PlistBuddy -c 'Print :EnvironmentVariables:HOME' "$agent")" = "$HOME" ] || fail "agent HOME incorrect"
[ "$(/usr/libexec/PlistBuddy -c 'Print :ProgramArguments:1' "$agent")" = "$repo/auto-update.sh" ] || fail "agent program incorrect"
[ "$(/usr/libexec/PlistBuddy -c 'Print :StartInterval' "$agent")" = 86400 ] || fail "agent interval incorrect"
[ -f "$state/copilot.last-update" ] && [ ! -e "$state/claude.last-update" ] || fail "wrong target recorded"

bash "$root/install.sh" claude
[ -L "$claude/first" ] || fail "Claude skill not linked"
[ -L "$claude_instructions/first.instructions.md" ] || fail "Claude instruction not linked"
[ "$(cat "$claude_instructions/first.instructions.md")" = "first instruction" ] || fail "Claude instruction is not readable"
bash "$root/install.sh" both

mkdir -p "$copilot/personal" "$tmpdir/remote/skills/second"
printf '%s\n' 'personal skill' > "$copilot/personal/SKILL.md"
printf '%s\n' 'second skill' > "$tmpdir/remote/skills/second/SKILL.md"
printf '%s\n' 'personal instruction' > "$copilot_instructions/personal.instructions.md"
printf '%s\n' 'second instruction' > "$tmpdir/remote/instructions/second.instructions.md"
git -C "$tmpdir/remote" rm -qr skills/first
git -C "$tmpdir/remote" rm -qr skills/team-skills-test-driven-development
git -C "$tmpdir/remote" rm -q instructions/first.instructions.md
git -C "$tmpdir/remote" add skills instructions
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
[ ! -L "$copilot/team-skills-test-driven-development" ] && [ ! -L "$claude/team-skills-test-driven-development" ] || fail "old TDD skill links remain"
[ -f "$copilot/personal/SKILL.md" ] || fail "personal skill was modified"
[ -L "$copilot_instructions/second.instructions.md" ] && [ -L "$claude_instructions/second.instructions.md" ] || fail "new instruction not linked"
[ ! -L "$copilot_instructions/first.instructions.md" ] && [ ! -L "$claude_instructions/first.instructions.md" ] || fail "removed instruction links remain"
[ "$(cat "$copilot_instructions/personal.instructions.md")" = "personal instruction" ] || fail "personal instruction was modified"

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

printf '%s\n' 'new instruction' > "$tmpdir/remote/instructions/conflict.instructions.md"
printf '%s\n' 'personal instruction' > "$claude_instructions/conflict.instructions.md"
mkdir -p "$tmpdir/remote/skills/instruction-preflight"
printf '%s\n' 'skill' > "$tmpdir/remote/skills/instruction-preflight/SKILL.md"
git -C "$tmpdir/remote" add instructions skills/instruction-preflight
git -C "$tmpdir/remote" commit -qm "Add conflicting instruction"
if bash "$root/install.sh" both > /dev/null 2>&1; then
  fail "conflicting instruction was accepted"
fi
[ ! -e "$copilot/instruction-preflight" ] || fail "skill links changed despite instruction conflict"
[ ! -e "$copilot_instructions/conflict.instructions.md" ] || fail "instruction links changed despite conflict"
[ "$(cat "$claude_instructions/conflict.instructions.md")" = "personal instruction" ] || fail "conflicting instruction was overwritten"
rm "$claude_instructions/conflict.instructions.md"
bash "$root/install.sh" both
[ -L "$copilot_instructions/conflict.instructions.md" ] && [ -L "$claude_instructions/conflict.instructions.md" ] || fail "instruction conflict did not resolve on retry"

mkdir -p "$tmpdir/remote/skills/third"
printf '%s\n' 'third skill' > "$tmpdir/remote/skills/third/SKILL.md"
printf '%s\n' 'third instruction' > "$tmpdir/remote/instructions/third.instructions.md"
git -C "$tmpdir/remote" add skills/third instructions/third.instructions.md
git -C "$tmpdir/remote" commit -qm "Add third skill"
printf '%s\n' "$old" > "$state/copilot.last-update"
bash "$root/auto-update.sh"
[ -L "$copilot/third" ] || fail "due target was not updated"
[ ! -e "$claude/third" ] || fail "target was reconciled before it was due"
[ -L "$copilot_instructions/third.instructions.md" ] || fail "due instruction target was not updated"
[ ! -e "$claude_instructions/third.instructions.md" ] || fail "instruction target was reconciled before it was due"
printf '%s\n' "$old" > "$state/claude.last-update"
bash "$root/auto-update.sh"
[ -L "$claude/third" ] || fail "separately due target was not reconciled"
[ -L "$claude_instructions/third.instructions.md" ] || fail "separately due instruction target was not reconciled"

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
