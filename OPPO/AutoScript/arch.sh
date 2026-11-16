#!/usr/bin/env bash
set -euo pipefail

# Optional: specify your GPG key ID or email, or leave blank for default key
GPG_KEY="aceofsnakesmain@gmail.com"
OUT_DIR="./release_artifacts"
mkdir -p "$OUT_DIR"
INNER_DIR="AutoScript"

for dir in */; do
    folder_name="${dir%/}"
    [[ "$folder_name" == "release_artifacts" ]] && continue

    archive="$PWD/${folder_name}.zip"

    stage_dir=$(mktemp -d)
    mkdir -p "$stage_dir/$INNER_DIR"
    cp -r "$folder_name"/. "$stage_dir/$INNER_DIR/"

    tree $stage_dir

    echo "Zipping $folder_name into $INNER_DIR/$folder_name inside $archive..."
    (unix2dos $stage_dir/$INNER_DIR/$INNER_DIR*)
    (chmod -x $stage_dir/$INNER_DIR/$INNER_DIR*)
    (cd "$stage_dir" && zip -rq "$archive" "$INNER_DIR")
    rm -rf "$stage_dir"
    
    echo "Signing $archive..."
    gpg --batch --yes --armor --detach-sign \
        --local-user "$GPG_KEY" \
        --output "${archive}.asc" \
        "$archive"
done
