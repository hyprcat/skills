---
name: relaunch
description: Kill stale copies, rebuild, reinstall and relaunch a Mac app, CLI, dev server or helper so what's running is provably the fresh build, then show it working with a screenshot. Use whenever Affan says relaunch, restart, reinstall, rebuild, kill the stale processes, run it and show me, show me, demo it, "did you restart the app", "stale build"; after any change to an app that's running; and before verifying anything on a running app.
---

# Relaunch

"Kill all the stale processes and current active ones and reinstall and relaunch" and "run it and show me" are two
of his most typed requests (399 prompts in 32 projects, and 448 in 48). The job ends when the fresh build is running
and he can see the change.

## Rules

- Kill by PID or full path, never by bare name: `pkill Alma` hits processes that aren't yours. Leave other people's
  processes, other VMs and the person's own windows alone.
- Launch an app from its bundle with `open`, never by running its binary in a terminal: the TCC grants (screen
  recording, accessibility, microphone) would go to the terminal.
- Sign dev builds with a stable self-signed identity (`security find-identity -v -p codesigning` lists them, e.g.
  "Almanac Dev"), not ad hoc. An ad-hoc signature changes every build, macOS sees a new app, and the permission
  prompts come back every time.
- Use the repo's own build and install scripts (`scripts/build-app.sh`, `install.sh`, the CLAUDE.md commands)
  before inventing steps.

## A Mac app

1. Build with the repo's script.
2. Install if the repo installs: `ditto` to `/Applications` and clear quarantine, as its install script does.
3. `bash ~/.claude/skills/relaunch/scripts/fresh-app.sh /Applications/Name.app`. It quits every running copy of
   that app, from any build folder, matched by the bundle's own executable path. Then it opens this copy and fails
   unless the new process started after the binary was built.
4. Helpers: `launchctl kickstart -k gui/$(id -u)/<label>` restarts a launchd job. An MCP server restarts with the
   client that spawned it.

## A dev server or daemon

- Free the port by PID: `lsof -ti tcp:<port>`, check `ps -o pid,command -p <pid>` is yours, then `kill <pid>`.
- Start it in the background with its output going to a file. Wait for it to answer (poll the URL until it
  responds, never a fixed sleep), then read the file's first lines for errors.

## Show it

- Mac: `screencapture -x shot.png` (whole screen), `-l <windowid>` (one window), or `-V 15 demo.mov` (15 s of video).
  Look at the image yourself before describing it.
- Web: open the page with ego-browser and screenshot it, at desktop and phone width when it's UI.
- iPhone: the iphone-use skill.
- Show the change that was asked for, on the screen where it lives, not the app's start screen.

Then run verify for the logs and the report.
