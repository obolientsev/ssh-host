KV_STORE_PLUGIN_DIR="${0:A:h}"
source "${KV_STORE_PLUGIN_DIR}/utils/validation.zsh"

# Returns all key-value pairs from the store
# _kv_store_get_all "/path/to/store.db"
# => "namespace:key1=value1
#     namespace:key2=value2"
_kv_store_get_all() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    cat "$file"
}

# Initializes the KV store by creating directory and file with secure permissions
# _kv_store_init "/path/to/store.db"
# => Creates file with 600 permissions
# => Creates parent directory with 700 permissions
# => Returns 0 if already initialized or successfully created
_kv_store_init() {
    local file="$1"
    local file_dir

    [[ -f "$file" ]] && return 0

    file_dir="$(dirname "$file")"
    [[ -d "$file_dir" ]] || mkdir -p -m 700 "$file_dir" || {
        echo "Failed to create directory: $file_dir" >&2
        return 1
    }

    touch "$file" && chmod 600 "$file" || {
        echo "Failed to initialize kv store file" >&2
        return 1
    }
}

# Retrieves value for a given key from the store
# _kv_store_get "/path/to/store.db" "alias:key"
# => "production,webserver"
# _kv_store_get "/path/to/store.db" "missing:key"
# => Returns 0 (not found)
_kv_store_get() {
    local file="$1"
    local key="$2"
    local line value

    [[ -f "$file" ]] || return 0

    line=$(grep -F "${key}=" "$file" 2>/dev/null) || return 0
    value="${line#${key}=}"

    echo "$value"
}

# Stores a key-value pair in the store (creates or updates)
# _kv_store_set "/path/to/store.db" "alias:key" "production,webserver"
# => Stores alias:key=production,webserver
# _kv_store_set "/path/to/store.db" "alias:key" "staging"
# => Updates to alias:key=staging
# _kv_store_set "/path/to/store.db" "invalid key" "value"
# => Returns 1 (validation error)
_kv_store_set() {
    local file="$1"
    local key="$2"
    local value="$3"
    local temp_file="${file}.tmp"

    [[ -f "$file" ]] || _kv_store_init "$file"

    _kv_store_validate_key "$key" || return 1
    _kv_store_validate_value "$value" || return 1

    {
        [[ -f "$file" ]] && grep -v -F "${key}=" "$file"
        printf '%s=%s\n' "$key" "$value"
    } > "$temp_file"

    mv "$temp_file" "$file" && chmod 600 "$file"
}
