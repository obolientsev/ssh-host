source "${0:A:h:h}/lib/kv_store/kv_store.zsh"

_ssh_host_metadata_load() {
  [[ -f "$SSH_HOST_METADATA_FILE" ]] || return 0

  typeset -gA SSH_HOST_METADATA
  SSH_HOST_METADATA=()

  while IFS='=' read -r key value; do
    [[ -n $key ]] || continue
    SSH_HOST_METADATA[$key]="$value"
  done < <(_kv_store_get_all "$SSH_HOST_METADATA_FILE")
}