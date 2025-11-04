# SSH Host Validation Functions
#
# All validations follow the same pattern:
# _ssh_host_validate_* "input_value"
# => Returns 0 if valid
# => Prints error message and returns 1 if invalid
#
# Examples:
# _ssh_host_validate_alias "server1"     => 0 (valid)
# _ssh_host_validate_alias "server 1"    => "Alias cannot contain spaces" + return 1
# _ssh_host_validate_hostname ".bad"     => "Hostname cannot start with a dot" + return 1
# _ssh_host_validate_port "99999"        => "Port must be less than 65536" + return 1

_ssh_host_validate_alias() {
    local alias="$1" exit_code=0

    [[ -n "$alias" ]] || \
        { echo  'Alias cannot be empty'; exit_code=1; }
    [[ "$alias" != *[[:space:]]* ]] || \
        { echo  'Alias cannot contain spaces'; exit_code=1; }
    [[ "$alias" =~ ^[a-zA-Z0-9._-]+$ ]] || \
        { echo  'Alias can only contain letters, numbers, dots, underscores, dashes'; exit_code=1; }
    [[ -n $(_ssh_host_aliases_list | grep -Fx "$alias") ]] && \
        { echo  'Alias already exists in SSH config'; exit_code=1; }

    return "$exit_code"
}

_ssh_host_validate_hostname() {
    local hostname="$1" exit_code=0

    [[ ${#hostname} -le 253 ]] || \
        { echo  'Hostname too long (max 253 characters)'; exit_code=1; }
    [[ -n "$hostname" ]] || \
        { echo  'Hostname cannot be empty'; exit_code=1; }
    [[ "$hostname" != .* ]] || \
        { echo  'Hostname cannot start with a dot'; exit_code=1; }
    [[ "$hostname" != *. ]] || \
        { echo  'Hostname cannot end with a dot'; exit_code=1; }
    [[ "$hostname" != *..* ]] || \
        { echo  'Hostname cannot contain consecutive dots'; exit_code=1; }
    [[ "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]] || \
        { echo  'Invalid hostname format'; exit_code=1; }

    return "$exit_code"
}

_ssh_host_validate_username() {
    local username="$1" exit_code=0

    [[ -n "$username" ]] || \
        { echo  'Username cannot be empty'; exit_code=1; }
    [[ ${#username} -le 32 ]] || \
        { echo  'Username too long (max 32 characters)'; exit_code=1; }
    [[ ${#username} -ge 1 ]] || \
        { echo  'Username too short'; exit_code=1; }
    [[ "$username" != .* ]] || \
        { echo  'Username cannot start with a dot'; exit_code=1; }
    [[ "$username" != *. ]] || \
        { echo  'Username cannot end with a dot'; exit_code=1; }
    [[ "$username" != -* ]] || \
        { echo  'Username cannot start with a dash'; exit_code=1; }
    [[ "$username" != *- ]] || \
        { echo  'Username cannot end with a dash'; exit_code=1; }
    [[ "$username" != *..* ]] || \
        { echo  'Username cannot contain consecutive dots'; exit_code=1; }
    [[ "$username" != *--* ]] || \
        { echo  'Username cannot contain consecutive dashes'; exit_code=1; }
    [[ "$username" =~ ^[a-zA-Z][a-zA-Z0-9._-]*$ ]] || \
        { echo  'Username must start with a letter and contain only letters, numbers, dots, underscores, and dashes'; exit_code=1; }

    return "$exit_code"
}

_ssh_host_validate_port() {
    local port="$1" exit_code=0
    
    [[ "$port" =~ ^[0-9]+$ ]] || \
        { echo  'Port must be a number'; exit_code=1; }
    [[ "$port" -ge 1 ]] || \
        { echo  'Port must be greater than 0'; exit_code=1; }
    [[ "$port" -le 65535 ]] || \
        { echo  'Port must be less than 65536'; exit_code=1; }

    return "$exit_code"
}

_ssh_host_validate_identity_file() {
    local identity_file="$1" exit_code=0
    [[ -z "$identity_file" ]] && \
        { echo  'Identity file path cannot be empty'; exit_code=1; }
    [[ -f "$identity_file" ]] || \
        { echo  'Identity file does not exist'; exit_code=1; }
    [[ -r "$identity_file" ]] || \
        { echo  'Identity file is not readable'; exit_code=1; }
    
    return "$exit_code"
}

_ssh_host_validate_key_type() {
    local key_type="$1" exit_code=0
    [[ "$key_type" == "ed25519" || "$key_type" == "rsa" ]] || \
        { echo  "Key type must be either ed25519 or rsa. not $key_type"; exit_code=1; }

    return "$exit_code"
}

_ssh_host_metadata_validate_value() {
    local value="$1" exit_code=0

    [[ "$value" == *$'\n'* ]] && \
        { echo 'Value must not contain newlines'; exit_code=1; }

    return "$exit_code"
}
