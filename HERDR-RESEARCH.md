# Herdr research and installation recommendation

Research date: 2026-08-09

## Conclusion

The project is **Herdr** (no second `e`), from [`herdrdev/herdr`](https://github.com/herdrdev/herdr). It is a standalone terminal multiplexer with a persistent background server and an agent-status sidebar. It runs *inside* an existing terminal emulator such as Ghostty; it is not a Ghostty extension and not a tmux plugin. The current stable release is [`v0.8.0`](https://github.com/herdrdev/herdr/releases/tag/v0.8.0), published 2026-08-03 under Apache-2.0.

For this Mac, the recommended setup is:

1. Install the stable Homebrew formula with `brew install herdr`.
2. Start `herdr` directly in Ghostty for agent-oriented terminal windows, rather than putting tmux between Ghostty and Herdr.
3. Run `codex` in a Herdr pane. Status detection works out of the box.
4. Initially skip `herdr integration install codex`. Add it only if native Codex conversation restore after a full Herdr server restart is valuable, because it edits Codex configuration.
5. Keep tmux installed and its configuration intact as a fallback for non-agent workflows.

This recommendation matches the repository's existing Homebrew-based machine setup and avoids `curl | sh`. The official [Homebrew formula](https://formulae.brew.sh/formula/herdr) currently packages stable `0.8.0`; its [formula source](https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/h/herdr.rb) pins and verifies the `v0.8.0` source archive by SHA-256.

## What Herdr provides

- A real terminal multiplexer with workspaces, tabs, panes, mouse support, and tmux-style prefix keys.
- A sidebar that rolls agent state up from pane to tab to workspace and shows `working`, `blocked`, `done`, or `idle`.
- A background server: detaching or closing the terminal client leaves pane processes running; `herdr` attaches again later.
- Native recognition of Codex, Claude Code, OpenCode, Pi, Cursor Agent CLI, and many other agent CLIs.
- Local CLI/socket automation for inspecting panes, sending prompts, reading output, and waiting for agent state.

Sources: [official README](https://github.com/herdrdev/herdr#readme), [quick start](https://herdr.dev/docs/quick-start/), [agent support and status model](https://herdr.dev/docs/agents/), and [socket API](https://herdr.dev/docs/socket-api/).

## Compatibility with this setup

### macOS and Apple silicon

Stable Herdr supports macOS on both Apple silicon and Intel. The `v0.8.0` release publishes `herdr-macos-aarch64` and `herdr-macos-x86_64` binaries, and the Homebrew formula has a stable `0.8.0` package. This machine is Darwin `arm64`, so it is a first-class supported target. See the [install matrix](https://herdr.dev/docs/install/#download-manually) and [v0.8.0 release assets](https://github.com/herdrdev/herdr/releases/tag/v0.8.0).

### Ghostty

Ghostty remains the outer terminal emulator. Herdr is a TUI/binary launched inside it, and the official project explicitly lists Ghostty among the outer terminals it is designed to run in. Herdr also uses a vendored `libghostty-vt` terminal engine internally, but that is separate from the Ghostty app. No Ghostty plugin is required. See the [official project page](https://herdr.dev/) and [keyboard compatibility notes](https://herdr.dev/docs/keyboard/).

The clean topology is:

```text
Ghostty -> Herdr -> shell/Codex
```

### tmux

Herdr is a tmux alternative for this workflow, not an add-on to tmux. The supported nesting rules matter:

- `Ghostty -> tmux -> Herdr -> Codex` can work; Herdr's docs say it can run with tmux as the outer terminal environment.
- `Ghostty -> Herdr -> tmux -> Codex` loses agent detection because Herdr sees `tmux` as the foreground pane process and does not inspect the nested tmux session.

For the lowest-friction sidebar and key handling, launch Herdr directly from Ghostty. The existing tmux setup uses `Ctrl+Space`, while Herdr defaults to `Ctrl+B`, so a temporary outer-tmux trial does not have the usual identical-prefix collision, but it is still nested multiplexing. Source: [Herdr agent detection and tmux nesting](https://herdr.dev/docs/agents/#detection-manifests).

### Codex

Codex is officially supported. Herdr detects its foreground process and classifies status from the live bottom of the pane using its Codex screen manifest. This works without installing an integration. Blocked detection is intentionally strict: if a future/unusual Codex prompt does not match a known rule, it may appear `idle` rather than `blocked` until Herdr's detection rules are updated. Herdr can update known-agent manifests in the background. Source: [supported agents, status authority, and blocked-state behavior](https://herdr.dev/docs/agents/).

The optional Codex integration is a **session identity** hook, not the source of status. It enables native conversation restore after a Herdr server restart. `herdr integration install codex`:

- writes `~/.codex/herdr-agent-state.sh` (or under `CODEX_HOME`),
- updates `~/.codex/hooks.json`,
- ensures `[features] hooks = true` in `~/.codex/config.toml`, and
- removes the deprecated top-level `codex_hooks` flag if present.

Uninstall removes the Herdr hook entry/script but deliberately leaves the `config.toml` feature setting in place. The current native-restore minimum is Herdr Codex integration version `5`; check with `herdr integration status`. Source: [official Codex integration documentation](https://herdr.dev/docs/integrations/#codex) and [session restore matrix](https://herdr.dev/docs/session-state/#native-agent-session-restore).

## Installation and first use

Preferred installation:

```bash
brew install herdr
herdr --version
```

Start it in a project directory:

```bash
cd /path/to/project
herdr
```

Then launch Codex normally inside the pane:

```bash
codex
```

Useful defaults:

| Action | Default |
| --- | --- |
| Detach while agents continue | `Ctrl+B`, then `q` |
| Reattach | `herdr` |
| Split right | `Ctrl+B`, then `v` |
| Split down | `Ctrl+B`, then `-` |
| New tab | `Ctrl+B`, then `c` |
| Workspace/agent navigation | `Ctrl+B`, then `w` |
| All active keybindings | `Ctrl+B`, then `?` |
| Stop server and pane processes | `herdr server stop` |

The first run shows onboarding, then writes configuration under `~/.config/herdr/`. Herdr works without a hand-written config. Source: [quick start](https://herdr.dev/docs/quick-start/) and [configuration](https://herdr.dev/docs/configuration/).

For Homebrew installs, update with:

```bash
brew upgrade herdr
```

Do not use `herdr update` for a Homebrew-managed install. A compatible already-running Herdr server may remain on the old version until restarted; `herdr status` shows its version. Stopping a server exits its pane processes, so do that only after work is safe. Source: [official update instructions](https://herdr.dev/docs/install/#update).

`brew services start herdr` is optional. It is not required for normal persistence: invoking `herdr` starts or attaches to its background session server. A login service is useful only if the server must start before the first Ghostty/Herdr client opens.

## Security and privacy notes

1. **Prefer Homebrew over piping a network script into a shell.** The official direct installer does verify the downloaded binary against a SHA-256 value in Herdr's release manifest, but the script and manifest come from the same project-controlled domain. Homebrew pins a source archive hash and is already part of this machine's setup. Sources: [Herdr installer source](https://github.com/herdrdev/herdr/blob/v0.8.0/website/install.sh) and [Homebrew formula source](https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/h/herdr.rb).

2. **The local control API is powerful.** It can read terminal output, send input, run commands, and control panes. Unix socket files are created owner-only (`0600`), but code running as the same user—including an agent inside Herdr—can potentially use this control surface. Treat code running under the account as trusted relative to the session. Sources: [socket API capabilities](https://herdr.dev/docs/socket-api/) and [socket permission implementation](https://github.com/herdrdev/herdr/blob/v0.8.0/src/api/server.rs#L25-L28).

3. **Do not install unreviewed plugins.** Herdr plugins are ordinary executable code, not sandboxed extensions. Their build/runtime commands run as the user with the user's environment and the Herdr control surface. The official marketplace is discovery over public GitHub repositories, not a reviewed catalog. Inspect the manifest/source and pin `--ref` when installing any plugin. Sources: [plugin trust and security](https://herdr.dev/docs/plugins/#trust-and-security) and [marketplace caveat](https://herdr.dev/docs/marketplace/).

4. **Pane-history persistence is off by default for a reason.** Enabling `[experimental] pane_history = true` stores recent pane contents in `session-history.json`; those contents can include secrets, tokens, prompts, and command output. Leave it disabled unless the restore benefit outweighs that exposure. Source: [pane screen-history security note](https://herdr.dev/docs/session-state/#pane-screen-history-replay).

5. **Agent detection may contact herdr.dev.** Herdr checks for remote rule updates for agents it already recognizes and stores valid manifests in its state directory. To prohibit this background manifest check, set `[update] manifest_check = false`. Source: [detection manifest behavior](https://herdr.dev/docs/agents/#detection-manifests).

6. **A full server stop is different from detaching.** Detaching preserves live processes. A server restart restores layout, but arbitrary shell processes do not survive; supported agent conversations resume only when a current official integration has reported a valid native session reference. Source: [session-state matrix](https://herdr.dev/docs/session-state/).

## Recommendation for the install pass

Install the Homebrew stable package, verify `herdr --version` reports `0.8.0`, and make Ghostty start `/opt/homebrew/bin/herdr` only if the user wants Herdr to replace the current auto-started tmux workflow. Preserve the tmux config. Do not install plugins, enable pane history, start a login service, or modify Codex hooks as part of the initial trial.

After opening Ghostty, verify with a real Codex pane that sidebar transitions appear during a prompt and after completion. If status is useful and full-restart conversation restore is desired, separately review/diff the Codex config and then run `herdr integration install codex`.
