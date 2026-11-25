# Team skills

Shared skills and instructions for developers using GitHub Copilot and Claude
Code on macOS. Install them once to make them available across your workspaces.

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
to reconcile both locations, including newly added or removed skills and
instructions. You can
inspect [install.sh](./install.sh) before running a command that downloads and
executes it.

### Automatic updates

Installation also registers a per-user macOS LaunchAgent. Once a day while you
are logged in, it checks whether 30 days have passed since each selected
installation's last successful update. If so, it updates the selected skills
and instructions;
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
and links skills and instructions into the selected tool's user directories:

| Target | Skills | Instructions |
| --- | --- | --- |
| Copilot | `~/.copilot/skills` | `~/.copilot/instructions` |
| Claude Code | `~/.claude/skills` | `~/.claude/rules` |

The links share the same checkout, so updates to existing files are visible to
both tools even when only one location is selected.

Your existing personal skills and instructions are left alone. If a file or
skill with the same name already exists and is not a link managed by this
installer, installation stops and reports the conflict; move or rename it
before retrying. Removed upstream files and skills have their installer-managed
links removed from the selected locations. The former TDD skill link is removed
when its selected target is reconciled.

Updates require a clean checkout on `main` with the original remote and only
fast-forward changes. If you have edited the checkout or changed its Git
configuration, resolve that before retrying. The checkout is updated before
checking for name conflicts, so its existing links may already reflect
the update if a conflict is reported.

After these changes are published, existing users should re-run their install
command to pick up the updated installer and reconcile instructions immediately.
When both targets were installed separately, use `both` to reconcile both.

## Instructions

- [Test-driven development](./instructions/team-skills-test-driven-development.instructions.md)
  describes the expected red, green, refactor workflow for behaviour changes.
  It applies to all files in Copilot and is a general user rule in Claude Code.
- [TypeScript standards](./instructions/team-skills-typescript.instructions.md)
  apply to TypeScript and TSX files, including `.mts` and `.cts`.

Copilot applies these instructions when working with matching files; Claude
loads the TDD rule generally and the TypeScript rule when working with matching
files. Discovery and application depend on the tool, harness, and settings;
instructions guide the agent rather than guaranteeing compliance. Start a new
session after installation and check the tool's customization or debug view to
confirm they are being loaded. These user-level instructions apply across
projects and may conflict with project-specific instructions; resolve any
conflicts rather than assuming a precedence order.

To run the installer tests from a checkout:

```bash
bash tests/install-test.sh
```

## How to use

In any workspace, in chat enter ````/team-skills```` and all skills will apear for use.

It is recommended to point to specific skills for more accurate results.

#### Example 1
Use the qa-sign-off skill to conduct full testing on a feature.

````/team-skills-qa-sign-off conduct testing on abc-9864 openspec change````

#### Example 2
Use the infra-as-code skill to build an AWS native resource.

````/team-skills-infra-as-code commit to the existing terraform code and build a new dynamodb table with a partition key of 'uuid' and a attribute named 'name', ask if you need more clarity, do not build until you have a clear understanding````

#### Example 3
Use the code-architecture skill to build a design pattern in code.

````/team-skills-code-architecture create the scaffolding of a repository pattern with a single service to access the users table, connect to the existing MySql connectors````