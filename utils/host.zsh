# Generates formatted host list for fzf selection interface
# _ssh_host_print_hosts_list
# => "server1     → john@example.com:22"
# => "production  → admin@prod.com:2222"
_ssh_host_print_hosts_list() {
    [[ ! -f "$SSH_HOST_BASE_CONFIG_FILE" ]] && return 1
    local host_aliases=($(_ssh_host_aliases_list))

    for host_alias in "${host_aliases[@]}"; do
        local config=$(_ssh_host_config_by_alias "$host_alias" "hostname|user|port")
        read -r hostname user port <<< "$(awk '{print $2}' <<< "$config" | xargs)"
        [[ -z "$hostname" || -z "$user" || -z "$port" ]] && continue
        _ssh_host_print_host_row "$host_alias" "$hostname" "$user" "$port"
    done
}

# Formats single host entry with colors for display
# _ssh_host_print_host_row "server1" "example.com" "john" "22"
# => "server1     → john@example.com:22" (colorized)
_ssh_host_print_host_row() {
    local host_alias="$1" hostname="$2" user="$3" port="$4"

    printf "${SSH_HOST_COLOR_BLUE}%-20s${SSH_HOST_COLOR_NC} → ${SSH_HOST_COLOR_CYAN}%s${SSH_HOST_COLOR_NC}@${SSH_HOST_COLOR_WHITE}%s${SSH_HOST_COLOR_NC}:${SSH_HOST_COLOR_GRAY}%s${SSH_HOST_COLOR_NC}\n" \
           "$host_alias" "$user" "$hostname" "$port"
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
