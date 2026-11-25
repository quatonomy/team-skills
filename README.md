# Team skills

Shared skills for developers using GitHub Copilot and Claude Code on macOS.
Install them once to make them available across your workspaces.

## Install or update

You need Git and curl (available through Apple's command line tools). Choose
one command:

**GitHub Copilot**

```bash
curl -fsSL https://raw.githubusercontent.com/quatonomy/team-skills/main/install.sh | bash -s -- copilot
```

**Claude Code**

```bash
curl -fsSL https://raw.githubusercontent.com/quatonomy/team-skills/main/install.sh | bash -s -- claude
```

**Both**

```bash
curl -fsSL https://raw.githubusercontent.com/quatonomy/team-skills/main/install.sh | bash -s -- both
```

Re-run your chosen command to update. If you have installed both, use `both`
to reconcile both locations, including newly added or removed skills. You can
inspect [install.sh](./install.sh) before running a command that downloads and
executes it.

### Automatic updates

Installation also registers a per-user macOS LaunchAgent. Once a day while you
are logged in, it checks whether 30 days have passed since each selected
installation's last successful update. If so, it updates the selected skills;
when you install Copilot and Claude separately, both are tracked. A missed check
can run after your Mac wakes. The check does not force an update before skills
are used and cannot update while your Mac is off or you are logged out.

On failure, the agent retries at its next daily check and attempts to show a
macOS notification. Notifications depend on your macOS notification settings.
Details are recorded in `~/.local/share/team-skills-state/update-error.log`;
normal output is in `~/.local/share/team-skills-state/update.log`. You can also
re-run the install command to see errors immediately.

The LaunchAgent needs an active macOS user session when installed. If setup
fails, the installer reports an error; re-run the command while logged in.
To disable automatic updates, run:

```bash
launchctl bootout "gui/$(id -u)" ~/Library/LaunchAgents/com.quatonomy.team-skills-update.plist
rm ~/Library/LaunchAgents/com.quatonomy.team-skills-update.plist
```

Running an install command again re-enables them. If a stopped or interrupted
installer reports a leftover lock, verify no installer is running and remove
the empty `~/.local/share/team-skills-state/install.lock` directory before
retrying.

The installer clones the public repository to `~/.local/share/team-skills`
and links each skill into `~/.copilot/skills`, `~/.claude/skills`, or both.
The links share the same checkout, so updates to existing skills are visible
to both tools even when only one location is selected.

Your existing personal skills are left alone. If a skill with the same name
already exists and is not a link managed by this installer, installation stops
and reports the conflict; move or rename it before retrying. Removed upstream
skills have their installer-managed links removed from the selected locations.

Updates require a clean checkout on `main` with the original remote and only
fast-forward changes. If you have edited the checkout or changed its Git
configuration, resolve that before retrying. The checkout is updated before
checking for skill-name conflicts, so its existing links may already reflect
the update if a conflict is reported.

The repository currently distributes skills only; shared instructions may be
added later.

To run the installer tests from a checkout:

```bash
bash tests/install-test.sh
```
