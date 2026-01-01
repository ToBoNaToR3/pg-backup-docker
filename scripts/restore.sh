#!/bin/bash

set -e

# Source common functions and colors
source "$(dirname "$0")/common.sh"

BACKUP_FILE="/backup/postgres_backup.sql.gz"

# Check if backup exists
if [ ! -f "$BACKUP_FILE" ]; then
  error "No backup file found at $BACKUP_FILE"
  exit 1
fi

# Check if backup is not empty
if [ ! -s "$BACKUP_FILE" ]; then
  error "Backup file is empty"
  exit 1
fi

BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
BACKUP_DATE=$(date -r "$BACKUP_FILE" +'%Y-%m-%d %H:%M:%S')

log "Starting PostgreSQL restore..."
log "Target: $POSTGRES_HOST"
log "Backup file: $BACKUP_FILE"
log "  Size: $BACKUP_SIZE (compressed)"
log "  Date: $BACKUP_DATE"
echo ""
warn "⚠️  WARNING: This will restore ALL databases from the backup!"
warn "⚠️  WARNING: Existing data will be overwritten!"
echo ""

# Ask for confirmation
read -r -p "Do you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  log "Restore cancelled by user"
  exit 0
fi

echo ""
log "Proceeding with restore..."

# Set password for psql
export PGPASSWORD="$POSTGRES_PASSWORD"

# Perform restore (decompress and restore)
log "Executing restore..."
if gunzip -c "$BACKUP_FILE" | psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d postgres 2>&1; then
  log "${GREEN}✓${NC} ${WHITE}Restore completed successfully${NC}"
else
  error "Restore failed"
  echo ""
  unset PGPASSWORD
  exit 1
fi

# Unset password
unset PGPASSWORD

log "Restore process completed"
echo ""
exit 0