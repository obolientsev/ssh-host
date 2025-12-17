source "${SSH_HOST_PLUGIN_DIR}/lib/sshcfg_store/sshcfg_store.zsh"

# Formats single host entry with colors for display
# _ssh_host_print_host_row "server1" "example.com" "john" "22"
# => "server1              → john@example.com:22                                            |"
# _ssh_host_print_host_row "server1" "example.com" "john" "22" "Production server"
# => "server1              → john@example.com:22                                            | Production server"
_ssh_host_print_host_row() {
    local host_alias="$1" hostname="$2" user="$3" port="$4" desc="$5" is_pinned="$6"

    local connection_info is_pinned_icon
    printf -v connection_info "${SSH_HOST_COLOR_CYAN}%s${SSH_HOST_COLOR_NC}@${SSH_HOST_COLOR_WHITE}%.20s${SSH_HOST_COLOR_NC}:${SSH_HOST_COLOR_GRAY}%s${SSH_HOST_COLOR_NC}" \
                              "$user" "$hostname" "$port"

    printf -v is_pinned_icon "%s" "$([[ $is_pinned == 1 ]] && echo '★' || echo ' ')"
    printf "${SSH_HOST_COLOR_BLUE}%-20s${SSH_HOST_COLOR_NC} %s → %-65s|" \
            "$host_alias" "$is_pinned_icon" "$connection_info"
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
# _ssh_host_alias_list
# => "server_alias_1"
# => "server_alias_2"
# _ssh_host_alias_list "/path/to/config"
_ssh_host_alias_list() {
    local conf_file="${1:-$SSH_HOST_BASE_CONFIG_FILE}"
    _sshcfg_store_alias_list "$conf_file"
}

# Resolves SSH config for host using native ssh -G command
# _ssh_host_config_by_alias "server1" "hostname|user|port"
# => "hostname example.com"
# => "user ubuntu"
# => "port 22"
_ssh_host_config_by_alias() {
    local host_alias="$1"
    local fields="${2:-$SSH_HOST_PREVIEW_FIELDS}"

    _sshcfg_store_get "$host_alias" "$fields"
}

# Adds SSH host configuration to config file
# _ssh_host_add_to_config "server1" "example.com" "ubuntu" "22" "path/to/key"
# => Creates backup before modification
# => Appends Host block to SSH config file
_ssh_host_add_to_config() {
    local config_file="$SSH_HOST_CONFIG_FILE"
    _sshcfg_store_add "$config_file" "$@"
}
