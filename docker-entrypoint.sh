#!/bin/bash
set -e

echo "Waiting for database..."
python manage.py wait_for_db

if [ "$1" == "--migrate" ]; then
    shift

    echo "Launching migrations..."
    python manage.py migrate
fi

echo "Starting ..."
exec "$@"
