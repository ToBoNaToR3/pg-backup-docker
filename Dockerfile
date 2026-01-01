FROM alpine:3.23

RUN apk add --no-cache \
  postgresql18-client \
  tzdata \
  dcron \
  bash

WORKDIR /app

COPY scripts/common.sh /app/common.sh
COPY scripts/backup.sh /app/backup.sh
COPY scripts/restore.sh /app/restore.sh
COPY scripts/entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/*.sh && \
  ln -s /app/backup.sh /usr/local/bin/backup && \
  ln -s /app/restore.sh /usr/local/bin/restore && \
  ln -s /app/common.sh /usr/local/bin/common.sh && \
  mkdir -p /backup && \
  touch /var/log/cron.log

ENTRYPOINT ["/app/entrypoint.sh"]
