#!/bin/bash
# Backup arr app databases to git-tracked backups/ directory

MEDIASTACK_DIR="$HOME/mediastack"
BACKUP_DIR="$MEDIASTACK_DIR/backups"
DATE=$(date +%Y-%m-%d)

mkdir -p "$BACKUP_DIR"

echo "Backing up databases..."

cp "$MEDIASTACK_DIR/radarr/config/radarr.db" "$BACKUP_DIR/radarr.db"
cp "$MEDIASTACK_DIR/sonarr/config/sonarr.db" "$BACKUP_DIR/sonarr.db"
cp "$MEDIASTACK_DIR/lidarr/config/lidarr.db" "$BACKUP_DIR/lidarr.db"
cp "$MEDIASTACK_DIR/prowlarr/config/prowlarr.db" "$BACKUP_DIR/prowlarr.db"
cp "$MEDIASTACK_DIR/mylar/config/mylar/mylar.db" "$BACKUP_DIR/mylar.db"

echo "Committing to git..."
cd "$MEDIASTACK_DIR"
git add backups/
git commit -m "db backup $DATE"
git push origin master
git push gitea master

echo "Done."
