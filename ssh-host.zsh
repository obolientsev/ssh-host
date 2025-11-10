#!/usr/bin/env zsh

# SSH-Host Zsh Plugin
# https://github.com/obolientsev/ssh-host
# Description: Manage and quickly connect to SSH hosts.
#
# License: MIT
# Copyright (c) 2025 obolientsev

SSH_HOST_PLUGIN_DIR="${0:A:h}"

ssh-host() {
  _ssh_host_check_dependencies && "${SSH_HOST_PLUGIN_DIR}/src/_ssh_host_main" "$@"
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
