export APP_ELECTRS_LIQUID_NODE_PORT="60601"

# Tor onion address
local rpc_hidden_service_file="${EXPORTS_TOR_DATA_DIR}/app-${EXPORTS_APP_ID}/main/hostname"
export APP_ELECTRS_LIQUID_RPC_HIDDEN_SERVICE="$(cat "${rpc_hidden_service_file}" 2>/dev/null || echo "")"

# Elements RPC password — get from running container or persisted file
local pass_file="${EXPORTS_APP_DIR}/data/electrs/.elements_rpc_pass"
local elements_container="$(docker ps --filter "name=elements" --format '{{.Names}}' 2>/dev/null | head -1)"

if [ -n "$elements_container" ]; then
    local pass="$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$elements_container" 2>/dev/null | grep '^APP_PASSWORD=' | cut -d= -f2-)"
    if [ -n "$pass" ]; then
        echo "$pass" > "$pass_file" 2>/dev/null || true
    fi
fi

# Fallback to persisted file
if [ -z "$pass" ] && [ -f "$pass_file" ]; then
    local pass="$(cat "$pass_file" 2>/dev/null)"
fi

export APP_ELEMENTS_RPC_PASSWORD="${pass:-}"
