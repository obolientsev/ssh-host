# KV store Validation Utilities

# Validates key format
# _kv_store_validate_key "alias:test"
# => Returns 0 if valid, 1 if invalid
_kv_store_validate_key() {
    local key="$1" exit_code=0

    [[ -n "$key" ]] || \
        { echo  'Alias cannot be empty'; exit_code=1; }

    [[ "$key" == *:* ]] || \
        { echo 'Key must contain ":" separator (format: namespace:key)'; exit_code=1; }

    [[ "$key" =~ ^[A-Za-z0-9._:-]+$ ]] || \
        { echo 'Invalid key format (format: namespace:key)'; exit_code=1; }

    [[ "$key" != *"["* && "$key" != *"]"* ]] || \
        { echo "Key must not contain '[' or ']'"; exit_code=1; }

    [[ ! "$key" =~ [[:space:]] ]] || \
        { echo "Key must not contain spaces"; exit_code=1; }

    return "$exit_code"
}

# Validates value
# _kv_store_validate_value "production,webserver"
# => Returns 0 if valid, 1 if invalid
_kv_store_validate_value() {
    local value="$1"
    local exit_code=0

    [[ "$value" == *$'\n'* ]] && {
        echo 'Value must not contain newlines' >&2
        exit_code=1
    }

    return "$exit_code"
}