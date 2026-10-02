# Bootstrap sync for shared just recipes — copy this file into your repo root, do NOT import it.
# It must stay self-contained (no imports) so `just sync-just` works before `.shared-just-recipes/` exists.
#
# Config: `.configs/.just-recipes.json`:
#   {"repo": "homelab/just-recipes", "ref": "v0.1.0", "dir": ".shared-just-recipes"}
# Resolution: `just sync-just [ref]` > JUST_RECIPES_REF env > config `ref` > `main`.
#
# Required in consumer `.gitignore`:
#   .shared-just-recipes/
#
# After sync, import shared files with:
#   import? '.shared-just-recipes/src/auth/auth.just'

just_config := ".configs/.just-recipes.json"
just_repo := "homelab/just-recipes"
just_default_ref := "main"
just_dir := ".shared-just-recipes"
just_clone_url := "ssh://git@ssh-git.prod.home.mombesoft.com/" + just_repo + ".git"

# Fetch/pin shared just recipes into .shared-just-recipes/ (gitignored).
# Usage: just sync-just [ref]  — ref is tag/branch/SHA, defaults to .configs/.just-recipes.json `ref`.
sync-just ref='':
    #!/usr/bin/env bash
    set -euo pipefail
    WANT="{{ref}}"
    if [ -z "$WANT" ] && [ -n "${JUST_RECIPES_REF:-}" ]; then WANT="$JUST_RECIPES_REF"; fi
    if [ -z "$WANT" ] && [ -f "{{just_config}}" ]; then WANT="$(jq -r .ref "{{just_config}}" 2>/dev/null || echo "")"; fi
    if [ -z "$WANT" ] || [ "$WANT" = "null" ]; then WANT="{{just_default_ref}}"; fi
    DEST="{{just_dir}}"
    URL="{{just_clone_url}}"
    echo "Syncing $URL@$WANT -> ./$DEST ..."
    rm -rf "$DEST"
    if git clone --depth 1 --branch "$WANT" "$URL" "$DEST" 2>/dev/null; then
        echo "Cloned branch/tag $WANT"
    else
        echo "Branch clone failed, trying full clone + checkout $WANT (SHA?)..."
        git clone --filter=blob:none --no-checkout "$URL" "$DEST"
        git -C "$DEST" checkout "$WANT"
    fi
    echo "Pinned: $WANT"
    echo "$WANT" > "$DEST/.pinned-ref"
    just --list --justfile "$DEST/justfile" >/dev/null && echo "Shared recipes OK"

# Show pinned ref and config
sync-just-info:
    @echo "config: {{just_config}}"
    @cat "{{just_config}}" 2>/dev/null || echo "(no {{just_config}}, using {{just_default_ref}})"
    @echo "dir: {{just_dir}}"
    @cat "{{just_dir}}/.pinned-ref" 2>/dev/null || echo "(not synced — run just sync-just)"
