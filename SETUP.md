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

## Manual Install Apps (not available via Homebrew)

- **DaVinci Resolve** - https://www.blackmagicdesign.com/products/davinciresolve
- **Affinity Suite** - https://affinity.serif.com
- **Cold Turkey Blocker** - https://getcoldturkey.com
- **Jabra Direct** - https://www.jabra.com/software-and-services/jabra-direct
