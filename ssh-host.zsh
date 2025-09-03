#!/usr/bin/env zsh

SSH_HOST_PLUGIN_DIR="${0:A:h}"
source "${SSH_HOST_PLUGIN_DIR}/ssh-host.plugin.conf"
source "${0:A:h}/src/_ssh_host_main"

ssh-host() {
  _ssh_host_main "$@"
}
