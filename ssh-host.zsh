#!/usr/bin/env zsh

SSH_HOST_PLUGIN_DIR="${0:A:h}"
source "${SSH_HOST_PLUGIN_DIR}/ssh-host.plugin.conf"
source "${0:A:h}/src/_ssh_host_main"

ssh-host() {
  _ssh_host_check_dependencies && _ssh_host_main "$@"
}

_ssh_host_check_dependencies() {
    local missing_deps=()
    local deps=(fzf ssh-keygen ssh)

    for dep in "${deps[@]}"; do
       command -v "$dep" >/dev/null || missing_deps+=("$dep")
    done

    [[ ${#missing_deps[@]} -eq 0 ]] && return 0

    echo "Missing required dependencies:"
    printf '  - %s\n' "${missing_deps[@]}"
    return 1
}
