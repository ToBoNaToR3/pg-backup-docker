#!/bin/bash

set -e
set -o pipefail

# Source common functions and colors
source "$(dirname "$0")/common.sh"

BACKUP_FILE="/backup/postgres_backup.sql.gz"
BACKUP_TMP="/backup/postgres_backup.tmp.sql.gz"

log "Starting PostgreSQL backup..."
log "Target: $POSTGRES_HOST"

# Set password for pg_dumpall
export PGPASSWORD="$POSTGRES_PASSWORD"

# Perform backup and compress with gzip
if pg_dumpall -h "$POSTGRES_HOST" -U "$POSTGRES_USER" 2>&1 | gzip > "$BACKUP_TMP"; then
  # Move temp file to final location (atomic operation)
  mv "$BACKUP_TMP" "$BACKUP_FILE"

  BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
  log "${GREEN}✓${NC} ${WHITE}Backup completed successfully${NC}"
  log "${WHITE}  File: $BACKUP_FILE${NC}"
  log "${WHITE}  Size: $BACKUP_SIZE (compressed)${NC}"

  # Verify backup file
  if [ -s "$BACKUP_FILE" ]; then
    log "${GREEN}✓${NC} ${WHITE}Backup file verified (non-empty)${NC}"
  else
    error "Backup file is empty!"
    rm -f "$BACKUP_FILE"
    exit 1
  fi
else
  error "Backup failed"
  echo ""
  rm -f "$BACKUP_TMP"
  exit 1
fi

# Unset password
unset PGPASSWORD

log "Backup process completed"
echo ""
exit 0