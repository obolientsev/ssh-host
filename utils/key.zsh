# Generates SSH key pair for a host alias
# _ssh_host_generate_key "server1" "ed25519"
# => "/path/to/keys/server1/id_ed25519" (returns private key path)
# Creates directory structure, archives existing keys, sets proper permissions
_ssh_host_generate_key() {
    local host_alias="$1"
    local key_type="${2:-ed25519}"
    local key_dir="$SSH_HOST_KEYS_DIR/$host_alias"
    local key_file="$key_dir/id_$key_type"

    _ssh_host_validate_alias "$host_alias" || return 1
    _ssh_host_validate_key_type "$key_type" || return 1

    _ssh_host_archive_path "$key_dir" || return 1
    mkdir -p -m 700 "$key_dir" || { echo "Failed to create $key_dir directory"; return 1; }

    case "$key_type" in
        "ed25519")
            ssh-keygen -t ed25519 -f "$key_file" -N "" -C "$host_alias@$(hostname)" -q || \
                { echo "Failed to generate ed25519 key"; return 1; }
            ;;
        "rsa")
            ssh-keygen -t rsa -b 4096 -f "$key_file" -N "" -C "$host_alias@$(hostname)" -q || \
                { echo "Failed to generate RSA key"; return 1; }
            ;;
        *)
            { echo "Unsupported key type: $key_type"; return 1; }
            ;;
    esac

    chmod 600 "$key_file" || { echo "Failed to set permissions on private key"; return 1; }
    chmod 644 "${key_file}.pub" || { echo "Failed to set permissions on public key"; return 1; }

    echo "$key_file" >&2
}


