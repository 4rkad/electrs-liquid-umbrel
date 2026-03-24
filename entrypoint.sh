#!/bin/sh
set -e

# Ensure data directory is owned by electrs user
# Umbrel creates volumes as root, but electrs runs as uid 1000
# Only chown if ownership is wrong (avoid slow chown -R on large databases)
if [ "$(stat -c %u /data)" != "1000" ]; then
    chown -R electrs:electrs /data
fi

# Drop privileges and run electrs
exec gosu electrs electrs "$@"
