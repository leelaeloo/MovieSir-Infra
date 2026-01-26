#!/bin/bash

source /etc/backup-db.env

BACKUP_DIR="/var/backups/postgresql"
DB_NAME="moviesir"
DB_USER="movigation"
DATE=$(date +%Y%m%d_%H%M%S)

PGPASSWORD=$DB_PASSWORD pg_dump -h localhost -U $DB_USER $DB_NAME > $BACKUP_DIR/moviesir_$DATE.sql

find $BACKUP_DIR -name "*.sql" -mtime +7 -delete

echo "[$DATE] Backup completed"
