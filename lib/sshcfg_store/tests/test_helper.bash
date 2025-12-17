#!/usr/bin/env bash

SSHCFG_STORE_PLUGIN_DIR="${BATS_TEST_DIRNAME%/tests*}"

load_bats_dep() {
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file
}
