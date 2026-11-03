# New Laptop Setup

## Order of Operations

1. **Run Sumble dev setup script**
   ```bash
   source <(curl -fsSL https://setup.sumble.com)
   ```
   This installs: pyenv, nvm, gcloud, sumble CLI, and work dependencies.

2. **Clone this repo**
   ```bash
   cd ~/code/personal/new-laptop-setup
   ```

3. **Run idempotent bootstrap**
   ```bash
   chmod +x ./bootstrap.sh
   ./bootstrap.sh
   ```
   - Re-running this is safe.
   - Use `./bootstrap.sh --skip-brew` to avoid package installs.
   - Use `./bootstrap.sh --skip-services` to avoid starting services.

4. **Add local secrets (one-time)**
   ```bash
   # bootstrap creates these files if missing
   $EDITOR raycast/config.json
   $EDITOR bettertouchtool/bettertouchtool.bttlicense
   ```
   Then fill in your real values locally. These files are ignored by git.

5. **Apply macOS defaults (optional, review before running)**
   ```bash
   chmod +x ./macos-defaults.sh
   ./macos-defaults.sh --allow-insecure
   ```

6. **Read secret rotation checklist if migrating from old repo state**
   - `SECURITY-ROTATION.md`

## Moving from an old Mac

**On the old Mac, before wiping it:**
1. Commit and push every repo in `~/code` (look for uncommitted files and local commits that were never pushed).
2. Copy these to a USB drive or send them by AirDrop. Never put them in git: `~/.ssh/`, `~/.modal.toml`, `~/.snowsql/config`, `~/code/modal/modal-etl/rsa_key.p8`.
3. `defaults export com.apple.dock ~/Desktop/dock.plist` saves the Dock layout. Optional.

**On the new Mac, after step 3 above (bootstrap):**
1. Clone repos to the same paths (`~/code/modal/...`).
2. Log in again: `claude` → `/login`, Codex, `gh auth login`, `gcloud auth login`, `modal token new` (or restore `~/.modal.toml`), 1Password, Raycast, Slack.
3. App Store and IT-managed apps don't come from Homebrew: Keynote, Pages, Numbers, GarageBand, iMovie, Okta Verify, Falcon, Iru Self Service.

## Manual Install Apps (not available via Homebrew)

- **DaVinci Resolve** - https://www.blackmagicdesign.com/products/davinciresolve
- **Affinity Suite** - https://affinity.serif.com
- **Cold Turkey Blocker** - https://getcoldturkey.com
- **Jabra Direct** - https://www.jabra.com/software-and-services/jabra-direct
