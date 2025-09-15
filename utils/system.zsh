# Archives existing path by adding timestamp suffix
# _ssh_host_archive_path "/path/to/directory"
# => Moves to "/path/to/directory.20251215_143022"
# => Returns 0 if path doesn't exist (no action needed)
_ssh_host_archive_path() {
    local f_path="$1"
    [[ -e "$f_path" ]] || return 0

    mv "$f_path" "$f_path.$(date +%Y%m%d_%H%M%S)" 2>/dev/null \
        || { echo "Failed to archive $f_path" >&2; return 1; }
}

# Creates timestamped backup copy of a file
# _ssh_host_backup_file "/path/file.txt" "/backup/dir"
# => Copies to "/backup/dir/file.txt.20251215_143022"
# => Returns 0 if file doesn't exist (no action needed)
_ssh_host_backup_file() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    local backup_dir="${2:-"$(dirname "$file")"}"
    local backup_file="$backup_dir/$(basename "$file").$(date +%Y%m%d_%H%M%S)"

    [[ -d "$backup_dir" ]] || mkdir -p -m 700 "$backup_dir" || { echo "Failed to create $backup_dir directory"; return 1; }
    cp "$file" "$backup_file" || { echo "Failed to create backup of $file"; return 1; }
}
