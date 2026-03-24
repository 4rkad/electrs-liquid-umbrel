#!/bin/sh
set -e

# Ensure data directory is owned by electrs user
# Umbrel creates volumes as root, but electrs runs as uid 1000
if [ "$(stat -c %u /data)" != "1000" ]; then
    chown -R electrs:electrs /data
fi

# --- Fix empty --cookie password ---
# If exports.sh couldn't get the password (Elements not running yet),
# try the persisted file from a previous successful start.
PASS_FILE="/data/.elements_rpc_pass"

if [ -z "$ELEMENTS_RPC_PASSWORD" ] && [ -f "$PASS_FILE" ] && [ -s "$PASS_FILE" ]; then
    ELEMENTS_RPC_PASSWORD="$(cat "$PASS_FILE")"
    echo "[entrypoint] Loaded password from $PASS_FILE"
fi

# Rewrite --cookie arg if password was empty but we found it
if [ -n "$ELEMENTS_RPC_PASSWORD" ]; then
    ARGS=""
    SKIP_NEXT=0
    for arg in "$@"; do
        if [ "$SKIP_NEXT" = "1" ]; then
            SKIP_NEXT=0
            # Replace the cookie value
            ARGS="$ARGS \"elements:${ELEMENTS_RPC_PASSWORD}\""
        elif [ "$arg" = "--cookie" ]; then
            ARGS="$ARGS --cookie"
            SKIP_NEXT=1
        else
            ARGS="$ARGS \"$arg\""
        fi
    done
    eval set -- $ARGS
fi

# Drop privileges and run electrs
exec gosu electrs electrs "$@"
