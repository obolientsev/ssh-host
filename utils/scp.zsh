# Executes scp with automatic recursive flag for directories
# _ssh_host_scp_execute "/local/file.txt" "host:/remote/"
# => "scp /local/file.txt host:/remote/"
# => Returns scp exit status (0 on success)
# _ssh_host_scp_execute "/local/dir" "host:/remote/"
# => "scp -r /local/dir host:/remote/"
# => Auto-detects directories and adds -r flag
_ssh_host_scp_execute() {
    local source="$1" destination="$2" recursive_flag=""

    if [[ "$source" != *:* ]]; then
        [[ -d "$source" ]] && recursive_flag="-r"
    else
        local remote_host="${source%%:*}"
        local remote_path="${source#*:}"
        ssh -o ConnectTimeout=5 "$remote_host" "[[ -d \"$remote_path\" ]]" 2>/dev/null && recursive_flag="-r"
    fi

    echo "scp ${recursive_flag} $source $destination"
    scp ${recursive_flag} "$source" "$destination"
}
