#!/bin/bash

set -e

# Source common functions and colors
source "$(dirname "$0")/common.sh"

# Validate required environment variables
if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
  error "Missing required environment variables: POSTGRES_HOST, POSTGRES_USER, POSTGRES_PASSWORD"
  exit 1
fi

# Test database connection
log "Testing database connection to $POSTGRES_HOST..."
export PGPASSWORD="$POSTGRES_PASSWORD"

MAX_RETRIES=5
RETRY_DELAY=2
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d postgres -c "SELECT 1" > /dev/null 2>&1; then
    log "${GREEN}✓${NC} ${WHITE}Database connection successful${NC}"
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      log "Connection attempt $RETRY_COUNT/$MAX_RETRIES failed, retrying in ${RETRY_DELAY}s..."
      sleep $RETRY_DELAY
    else
      error "Failed to connect to database after $MAX_RETRIES attempts"
      unset PGPASSWORD
      exit 1
    fi
  fi
done

unset PGPASSWORD

# Check if BACKUP_ONCE is enabled
if [ "${BACKUP_ONCE:-false}" = "true" ]; then
  log "BACKUP_ONCE enabled - running single backup and exiting"
  /app/backup.sh
  exit $?
fi

# Setup cron schedule
SCHEDULE="${BACKUP_SCHEDULE:-0 3 * * *}"
log "Configuring backup schedule: $SCHEDULE"

# Create crontab entry
echo "$SCHEDULE /app/backup.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

log "Backup container initialized"
log "Available commands:"
log "  backup  - Run manual backup"
log "  restore - Restore from backup"
echo ""
log "Scheduled backups: $SCHEDULE"
log "Logs: /var/log/cron.log"
echo ""

# Start crond in background without setting process group
crond -b

# Execute the command passed to the container or keep running
if [ "$#" -eq 0 ]; then
  # Keep container alive by tailing the log file
  tail -f /var/log/cron.log
else
  exec "$@"
fi