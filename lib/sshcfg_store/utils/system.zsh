# Creates timestamped backup copy of a file
# _sshcfg_store_backup_file "/path/file.txt" "/backup/dir"
# => Copies to "/backup/dir/file.txt.20251215_143022"
# => Returns 0 if file doesn't exist (no action needed)
_sshcfg_store_backup_file() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    local backup_dir="${2:-"$(dirname "$file")"}"
    local backup_file="$backup_dir/$(basename "$file").$(date +%Y%m%d_%H%M%S)"

    [[ -d "$backup_dir" ]] || mkdir -p -m 700 "$backup_dir" || { echo "Failed to create $backup_dir directory"; return 1; }
    cp "$file" "$backup_file" || { echo "Failed to create backup of $file"; return 1; }
}

# Ensures base SSH config includes plugin config file
_sshcfg_store_ensure_include_directive() {
    local config_file="$1" base_config_file="${2:-$HOME/.ssh/config}"
    local tmp_file

    mkdir -p "$(dirname "$base_config_file")" || return 1
    [[ -f "$base_config_file" ]] || touch "$base_config_file"
    [[ -f "$config_file" ]] || touch "$config_file"

    grep -Fq "Include ${config_file}" "$base_config_file" && return 0
    grep -Fq "Include ${config_file/#$HOME/~}" "$base_config_file" && return 0
    tmp_file=$(mktemp "${base_config_file}.XXXXXX") || return 1

    {
        printf "Include %s\n\n" "$config_file"
        cat "$base_config_file"
    } > "$tmp_file" && mv "$tmp_file" "$base_config_file"
}
