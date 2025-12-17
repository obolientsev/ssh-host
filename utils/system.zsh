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
