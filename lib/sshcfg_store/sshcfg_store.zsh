SSHCFG_STORE_PLUGIN_DIR="${SSHCFG_STORE_PLUGIN_DIR:-${${(%):-%x}:A:h}}"
source "${SSHCFG_STORE_PLUGIN_DIR}/utils/validation.zsh"
source "${SSHCFG_STORE_PLUGIN_DIR}/utils/system.zsh"

# Extracts all host aliases from SSH config with Include support
# _sshcfg_store_alias_list
# => "server_alias_1"
# => "server_alias_2"
# _sshcfg_store_alias_list "/path/to/config"
_sshcfg_store_alias_list() {
    local conf_file="${1:-"$HOME/.ssh/config"}"
    local aliases=()
    local includes=()

    while read -r type rest; do
        case "$type" in
            Host)
                set -f
                for alias in $rest; do
                    [[ "$alias" != "*" && "$alias" != *"?"* ]] && aliases+=("$alias")
                done
                set +f
                ;;
            Include)
                includes+=("$rest")
                ;;
        esac
    done < <(_sshcfg_store_parse_fields "Host|Include" < "$conf_file")

    for inc in "${includes[@]}"; do
      for expanded_path in ${inc/#\~/$HOME}; do
        [[ -f "$expanded_path" ]] && aliases+=( $(_sshcfg_store_alias_list "$expanded_path") )
      done
    done
    printf "%s\n" "${aliases[@]}"
}

# Resolves SSH config for host using native ssh -G command
# _sshcfg_store_get "server1" "hostname|user|port"
# => "hostname example.com"
# => "user ubuntu"
# => "port 22"
_sshcfg_store_get() {
    local host_alias="$1"
    local fields="$2"
    local conf_file="${SSHCFG_STORE_CONF_FILE:-$HOME/.ssh/config}"
    local config

    grep -Fxq "$host_alias" <<< "$(_sshcfg_store_alias_list "$conf_file")" || return 1

    config=$(ssh -G -F "$conf_file" "$host_alias" 2>/dev/null)
    [[ -n "$config" ]] || return 1
    _sshcfg_store_parse_fields "$fields" <<< "$config"
}

# Adds SSH host configuration to config file
# _sshcfg_store_add "server1" "example.com" "ubuntu" "22" "path/to/key"
# => Creates backup before modification
# => Appends Host block to SSH config file
_sshcfg_store_add() {
    local config_file="$1" host_alias="$2" hostname="$3" user="$4" port="$5" identity_file="$6"
    _sshcfg_store_ensure_include_directive "$config_file" || return 1

    _sshcfg_store_validate_alias "$host_alias" || return 1
    _sshcfg_store_validate_hostname "$hostname" || return 1
    _sshcfg_store_validate_username "$user" || return 1
    _sshcfg_store_validate_port "$port" || return 1

    _sshcfg_store_backup_file "$config_file"

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
    return 0
}

# Parses SSH config extracting matching field types, strips inline comments
# _sshcfg_store_parse_fields "Host|Include" < config_file
# => "Host server1 server2"
# => "Include /path/to/other/config"
# _sshcfg_store_parse_fields "hostname|port" <<< "$ssh_config"
# => "hostname example.com"
# => "port 2222"
_sshcfg_store_parse_fields() {
    local fields="$1"

    awk -v pat="$fields" '$0 ~ "^[[:space:]]*(" pat ")[[:space:]]+" {
           sub(/#.*/, "")
           print $1, substr($0, index($0,$2))
       }'
}
