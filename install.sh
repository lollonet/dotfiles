#!/usr/bin/env bash
# install.sh — Symlink dotfiles from repo to home directory
#
# Usage: ./install.sh [--dry-run]
#
# Creates symlinks in ~ pointing to files in this repo.
# Existing regular files are backed up to ~/.claude-backups/dotfiles/<timestamp>/

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.claude-backups/dotfiles/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "[dry-run] No changes will be made."
fi

# Map: repo file -> home target
declare -A LINKS=(
    ["bash/bashrc"]="$HOME/.bashrc"
    ["bash/bashrc_common"]="$HOME/.bashrc_common"
    ["bash/bashrc_linux"]="$HOME/.bashrc_linux"
    ["bash/bashrc_macos"]="$HOME/.bashrc_macos"
)

backup_created=false

link_file() {
    local src="$REPO_DIR/$1"
    local dst="$2"

    if [[ ! -f "$src" ]]; then
        echo "SKIP  $1 (source not found)"
        return
    fi

    # Already correctly linked
    if [[ -L "$dst" ]] && [[ "$(readlink -f "$dst")" == "$src" ]]; then
        echo "OK    $dst -> $src"
        return
    fi

    # Backup existing regular file
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        if ! $backup_created; then
            if $DRY_RUN; then
                echo "[dry-run] Would create backup dir: $BACKUP_DIR"
            else
                mkdir -p "$BACKUP_DIR"
            fi
            backup_created=true
        fi
        local backup_name
        backup_name="$(basename "$dst")"
        if $DRY_RUN; then
            echo "[dry-run] Would backup $dst -> $BACKUP_DIR/$backup_name"
        else
            cp -p "$dst" "$BACKUP_DIR/$backup_name"
            echo "BACK  $dst -> $BACKUP_DIR/$backup_name"
        fi
    fi

    # Remove existing symlink or file, then create new symlink
    if $DRY_RUN; then
        echo "[dry-run] Would link $dst -> $src"
    else
        rm -f "$dst"
        ln -s "$src" "$dst"
        echo "LINK  $dst -> $src"
    fi
}

echo "=== Dotfiles Installer ==="
echo "Repo: $REPO_DIR"
echo ""

for key in "${!LINKS[@]}"; do
    link_file "$key" "${LINKS[$key]}"
done

echo ""
if $DRY_RUN; then
    echo "Done (dry-run). Re-run without --dry-run to apply."
else
    echo "Done. Run 'source ~/.bashrc' to reload."
fi
