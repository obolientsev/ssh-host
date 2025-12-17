_ssh_host_metadata_validate_value() {
    local value="$1" exit_code=0

    [[ "$value" == *$'\n'* ]] && \
        { echo 'Value must not contain newlines'; exit_code=1; }

    return "$exit_code"
}
