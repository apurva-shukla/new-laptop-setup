# AeroSpace usage study

This is a five-day, local-only trace for deciding whether the four-workspace,
two-monitor AeroSpace setup matches real usage.

## What is recorded

- Timestamped AeroSpace focus, workspace, monitor, and binding events
- Application name and bundle identifier
- AeroSpace's numeric window identifier
- Workspace and monitor identifiers, visibility, and layout

The collector **never asks AeroSpace for window titles**. It does not record
URLs, typed text, screenshots, clipboard contents, document contents, or
message contents. The event data remains outside Git at:

`~/Library/Application Support/AeroSpace Usage Study/`

The implementation and launch-agent definition live here in the repository so
the collector is auditable. The launch agent automatically stops successfully
at the deadline stored in `study.json`.

## Files

- `study.json` — start/end times and the privacy contract
- `events.jsonl` — append-only events and periodic title-free state snapshots
- `collector.stdout.log` and `collector.stderr.log` — process diagnostics

## Stop early

```sh
launchctl bootout gui/$(id -u)/com.apurvashukla.aerospace-usage-study
```

## Check status

```sh
launchctl print gui/$(id -u)/com.apurvashukla.aerospace-usage-study
```
