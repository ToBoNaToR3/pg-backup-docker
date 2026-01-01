# postgres-backup-docker

A simple Docker container for backing up and restoring PostgreSQL databases using `pg_dump` on a cron schedule.

## Environment Variables

| Environment Variable | Description                                                      | Default Value               |
| -------------------- | ---------------------------------------------------------------- | --------------------------- |
| `POSTGRES_HOST`      | The hostname of the PostgreSQL server to back up.                | ""                          |
| `POSTGRES_USER`      | The username to connect to the PostgreSQL server.                | ""                          |
| `POSTGRES_PASSWORD`  | The password for the PostgreSQL user.                            | ""                          |
| `BACKUP_SCHEDULE`    | The cron schedule for backups.                                   | `0 2 * * *` (daily at 2 AM) |
| `BACKUP_ONCE`        | If set to `true`, performs a single backup on startup and exits. | `false`                     |
