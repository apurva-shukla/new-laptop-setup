# Security Rotation Checklist

Use this checklist if secrets were ever committed in this repo.

## 1) Rotate Raycast token

1. Open Raycast account/token settings.
2. Revoke the previously committed token.
3. Create a new token.
4. Save the new token locally in `raycast/config.json` (ignored by git).

## 2) Rotate BetterTouchTool license artifacts

1. Treat the old `bettertouchtool.bttlicense` data as exposed.
2. If needed, contact BetterTouchTool support for reissue guidance.
3. Store your active license only in `bettertouchtool/bettertouchtool.bttlicense` (ignored by git).

## 3) Verify working tree is clean of secrets

Run:

```bash
git grep -nE 'rca_[A-Za-z0-9]+'
```

Expected: no matches outside local ignored files.

## 4) Optional: scrub secret history

If this repo is shared/public and historical commits include secrets, rewrite history with `git filter-repo` and force-push safely.

Do this only if you understand the impact on collaborators.
