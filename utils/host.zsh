# Formats single host entry with colors for display
# _ssh_host_print_host_row "server1" "example.com" "john" "22"
# => "server1              → john@example.com:22                                            |"
# _ssh_host_print_host_row "server1" "example.com" "john" "22" "Production server"
# => "server1              → john@example.com:22                                            | Production server"
_ssh_host_print_host_row() {
    local host_alias="$1" hostname="$2" user="$3" port="$4" desc="$5"

    local connection_info
    printf -v connection_info "${SSH_HOST_COLOR_CYAN}%s${SSH_HOST_COLOR_NC}@${SSH_HOST_COLOR_WHITE}%.20s${SSH_HOST_COLOR_NC}:${SSH_HOST_COLOR_GRAY}%s${SSH_HOST_COLOR_NC}" \
                              "$user" "$hostname" "$port"

    printf "${SSH_HOST_COLOR_BLUE}%-20s${SSH_HOST_COLOR_NC} → %-65s|" "$host_alias" "$connection_info"
    [[ -n "$desc" ]] && printf " ${SSH_HOST_COLOR_NC}%s${SSH_HOST_COLOR_NC}" "$desc"
    printf "\n"
}

# Displays formatted SSH host configuration details
# _ssh_host_print_host_config "server1" "hostname example.com\nuser ubuntu\nport 22"
# => "Host alias: server1"
# => "--------------------------------"
# => "  hostname:                    example.com"
# => "  user:                        ubuntu"
# => "  port:                        22"
_ssh_host_print_host_config() {
    local host_alias="$1" config="$2"

    printf "${SSH_HOST_COLOR_NC}Host alias:${SSH_HOST_COLOR_BLUE} %s\n" "$host_alias"
    printf "${SSH_HOST_COLOR_GRAY}%*s\n" "$(tput cols)" '' | tr ' ' '-'
    awk -v c1="$SSH_HOST_COLOR_CYAN" -v nc="$SSH_HOST_COLOR_NC" \
        '{printf "  %s%-32s%s %s\n", nc, $1 ":", c1, $2}' <<< "$config"
}

# Extracts all host aliases from SSH config with Include support
# _ssh_host_aliases_list
# => "server_alias_1"
# => "server_alias_2"
# _ssh_host_aliases_list "/path/to/config"
_ssh_host_aliases_list() {
    local conf_file="${1:-$SSH_HOST_BASE_CONFIG_FILE}"
    local aliases=()
    local includes=()

    while read -r type rest; do
        case "$type" in
            Host)
                for alias in $rest; do
                    [[ "$alias" != "*" && "$alias" != *"?"* ]] && aliases+=("$alias")
                done
                ;;
            Include)
                includes+=("$rest")
                ;;
        esac
    done < <(_ssh_host_parse_config_lines "Host|Include" < "$conf_file")

    for inc in "${includes[@]}"; do
      for expanded_path in ${inc/#\~/$HOME}; do
        [[ -f "$expanded_path" ]] && aliases+=( $(_ssh_host_aliases_list "$expanded_path") )
      done
    done
    printf "%s\n" "${aliases[@]}"
}

# Parses SSH config lines matching field patterns, strips comments
# _ssh_host_parse_config_lines "Host|Include" < ~/.ssh/config
# => "Host server1 server2"
# _ssh_host_parse_config_lines "hostname|user" <<< "$ssh_output"
# => "hostname example.com"
# => "user ubuntu"
_ssh_host_parse_config_lines() {
    local fields="$1"

    awk -v pat="$fields" '$0 ~ "^[[:space:]]*(" pat ")[[:space:]]+" {
           sub(/#.*/, "")
           print $1, substr($0, index($0,$2))
       }'
}

# Resolves SSH config for host using native ssh -G command
# _ssh_host_config_by_alias "server1" "hostname|user|port"
# => "hostname example.com"
# => "user ubuntu"
# => "port 22"
_ssh_host_config_by_alias() {
    local host_alias="$1"
    local fields="$2"
    local config

    config=$(ssh -G "$host_alias" 2>/dev/null)
    [[ -z "$config" ]] && return 1

    _ssh_host_parse_config_lines "$fields" <<< "$config"
}

# Adds SSH host configuration to config file
# _ssh_host_add_to_config "server1" "example.com" "ubuntu" "22" "path/to/key"
# => Creates backup before modification
# => Appends Host block to SSH config file
_ssh_host_add_to_config() {
    local host_alias="$1" hostname="$2" user="$3" port="$4" identity_file="$5"
    local config_file="$SSH_HOST_CONFIG_FILE"

    _ssh_host_validate_alias "$host_alias" || return 1
    _ssh_host_validate_hostname "$hostname" || return 1
    _ssh_host_validate_username "$user" || return 1
    _ssh_host_validate_port "$port" || return 1

    _ssh_host_backup_file "$config_file" "$SSH_HOST_BACKUPS_DIR"

    cat >> "$config_file" << EOF

Host $host_alias
    HostName $hostname
    User $user
    Port $port
EOF

    [[ -n "$identity_file" ]] && cat >> "$config_file" << EOF
    IdentityFile $identity_file
    IdentitiesOnly yes
EOF
}
