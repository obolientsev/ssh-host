#!/usr/bin/env bats

load 'test_helper'
source "${KV_STORE_PLUGIN_DIR}/kv_store.zsh"
TEST_KV_DIR="${BATS_TEST_TMPDIR}/test/kv_store"
TEST_KV_FILE="${TEST_KV_DIR}/test_data_store"

setup() {
    load_bats_dep
    mkdir -p "$TEST_KV_DIR"
}

teardown() {
    rm -f "$TEST_KV_FILE" 2>/dev/null || true
    rm -rf "$TEST_KV_DIR" 2>/dev/null || true
}

# _kv_store_init tests

# bats test_tags=_kv_store_init,critical
@test "_kv_store_init: initializes store with secure permissions" {
    run _kv_store_init "$TEST_KV_FILE"
    assert_success

    #file created correctly
    [[ -f "$TEST_KV_FILE" ]]
    local perms
    perms=$(stat -f "%Op" "$TEST_KV_FILE" 2>/dev/null || stat -c "%a" "$TEST_KV_FILE" 2>/dev/null)
    [[ "$perms" == *"600" ]]

    #nothing happen if file already was initialized
    run _kv_store_init "$TEST_KV_FILE"
    assert_success
}

# _kv_store_get_all tests

# bats test_tags=_kv_store_get_all
@test "_kv_store_get_all: returns empty when file does not exist" {
    run _kv_store_get_all "$TEST_KV_FILE"
    assert_success
    assert_output ""
}

# bats test_tags=_kv_store_get_all,critical
@test "_kv_store_get_all: returns all entries from store" {
    echo "alias:server1=production" > "$TEST_KV_FILE"
    echo "alias:server2=staging" >> "$TEST_KV_FILE"
    echo "host:web01=192.168.1.10" >> "$TEST_KV_FILE"

    run _kv_store_get_all "$TEST_KV_FILE"
    assert_success
    assert_output "alias:server1=production
alias:server2=staging
host:web01=192.168.1.10"
}

# bats test_tags=_kv_store_get_all
@test "_kv_store_get_all: returns single entry" {
    echo "alias:server1=production" > "$TEST_KV_FILE"

    run _kv_store_get_all "$TEST_KV_FILE"
    assert_success
    assert_output "alias:server1=production"
}

# bats test_tags=_kv_store_get_all
@test "_kv_store_get_all: handles empty file" {
    touch "$TEST_KV_FILE"

    run _kv_store_get_all "$TEST_KV_FILE"
    assert_success
    assert_output ""
}

# bats test_tags=_kv_store_get_all
@test "_kv_store_get_all: preserves order of entries" {
    echo "key:first=1" > "$TEST_KV_FILE"
    echo "key:second=2" >> "$TEST_KV_FILE"
    echo "key:third=3" >> "$TEST_KV_FILE"

    run _kv_store_get_all "$TEST_KV_FILE"
    assert_success
    assert_line -n 0 "key:first=1"
    assert_line -n 1 "key:second=2"
    assert_line -n 2 "key:third=3"
}

# _kv_store_get tests

# bats test_tags=_kv_store_get,critical
@test "_kv_store_get: returns value for existing key" {
    echo "alias:server1=production" > "$TEST_KV_FILE"

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_success
    assert_output "production"
}

# bats test_tags=_kv_store_get
@test "_kv_store_get: returns empty for missing key or file" {
    echo "alias:server1=production" > "$TEST_KV_FILE"

    run _kv_store_get "$TEST_KV_FILE" "alias:missing"
    assert_success
    assert_output ""

    run _kv_store_get "${TEST_KV_FILE}.nonexistent" "alias:server1"
    assert_success
    assert_output ""
}

# bats test_tags=_kv_store_get,critical
@test "_kv_store_get: handles special characters in values" {
    echo "alias:server1=production web server" > "$TEST_KV_FILE"
    echo "alias:server2=prod@host#1:8080" >> "$TEST_KV_FILE"
    echo "alias:server3=key=value" >> "$TEST_KV_FILE"

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_success
    assert_output "production web server"

    run _kv_store_get "$TEST_KV_FILE" "alias:server2"
    assert_success
    assert_output "prod@host#1:8080"

    run _kv_store_get "$TEST_KV_FILE" "alias:server3"
    assert_success
    assert_output "key=value"
}

# bats test_tags=_kv_store_get
@test "_kv_store_get: handles empty value" {
    echo "alias:server1=" > "$TEST_KV_FILE"

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_success
    assert_output ""
}

# bats test_tags=_kv_store_get,critical
@test "_kv_store_get: does not match partial keys" {
    echo "alias:server1=production" > "$TEST_KV_FILE"
    echo "alias:server10=staging" >> "$TEST_KV_FILE"

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_success
    assert_output "production"
}

# bats test_tags=_kv_store_get
@test "_kv_store_get: handles multiple entries and returns correct one" {
    echo "alias:server1=production" > "$TEST_KV_FILE"
    echo "alias:server2=staging" >> "$TEST_KV_FILE"
    echo "host:web01=192.168.1.10" >> "$TEST_KV_FILE"

    run _kv_store_get "$TEST_KV_FILE" "alias:server2"
    assert_success
    assert_output "staging"
}

# bats test_tags=_kv_store_get
@test "_kv_store_get: handles keys with multiple colons" {
    echo "app:db:primary:01=postgres-prod" > "$TEST_KV_FILE"

    run _kv_store_get "$TEST_KV_FILE" "app:db:primary:01"
    assert_success
    assert_output "postgres-prod"
}

# _kv_store_set tests

# bats test_tags=_kv_store_set,critical
@test "_kv_store_set: creates and updates entries" {
    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "production"
    assert_success
    [[ -f "$TEST_KV_FILE" ]]

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_output "production"

    run _kv_store_set "$TEST_KV_FILE" "alias:server2" "staging"
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "alias:server2"
    assert_output "staging"

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_output "production"

    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "development"
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_output "development"
}

# bats test_tags=_kv_store_set,critical
@test "_kv_store_set: updates entry without duplicating" {
    echo "alias:server1=production" > "$TEST_KV_FILE"
    echo "alias:server2=staging" >> "$TEST_KV_FILE"

    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "development"
    assert_success

    run _kv_store_get_all "$TEST_KV_FILE"
    assert_output "alias:server2=staging
alias:server1=development"

    local count
    count=$(grep -c "alias:server1=" "$TEST_KV_FILE")
    [[ "$count" == "1" ]]
}

# bats test_tags=_kv_store_set,critical
@test "_kv_store_set: maintains file permissions after update" {
    _kv_store_init "$TEST_KV_FILE"

    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "production"
    assert_success

    local perms
    perms=$(stat -f "%Op" "$TEST_KV_FILE" 2>/dev/null || stat -c "%a" "$TEST_KV_FILE" 2>/dev/null)
    [[ "$perms" == *"600" ]]
}

# bats test_tags=_kv_store_set
@test "_kv_store_set: handles various valid value formats" {
    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "production web server"
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_output "production web server"

    run _kv_store_set "$TEST_KV_FILE" "alias:server2" "prod@host#1:8080"
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "alias:server2"
    assert_output "prod@host#1:8080"

    run _kv_store_set "$TEST_KV_FILE" "alias:server3" ""
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "alias:server3"
    assert_output ""
}

# bats test_tags=_kv_store_set,critical
@test "_kv_store_set: rejects invalid key formats" {
    run _kv_store_set "$TEST_KV_FILE" "invalid key" "value"
    assert_failure 1

    run _kv_store_set "$TEST_KV_FILE" "alias:my server" "value"
    assert_failure 1
}

# bats test_tags=_kv_store_set,critical
@test "_kv_store_set: rejects invalid value formats" {
    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "it's a value"
    assert_failure 1

    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "$(printf 'line1\nline2')"
    assert_failure 1
}

# bats test_tags=_kv_store_set
@test "_kv_store_set: handles multiple rapid updates" {
    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "value1"
    assert_success

    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "value2"
    assert_success

    run _kv_store_set "$TEST_KV_FILE" "alias:server1" "value3"
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_output "value3"
}

# bats test_tags=_kv_store_set
@test "_kv_store_set: handles keys with multiple colons" {
    run _kv_store_set "$TEST_KV_FILE" "app:db:primary:01" "postgres-prod"
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "app:db:primary:01"
    assert_output "postgres-prod"
}

# bats test_tags=_kv_store_set,critical
@test "_kv_store_set: preserves other entries when updating" {
    echo "alias:server1=production" > "$TEST_KV_FILE"
    echo "alias:server2=staging" >> "$TEST_KV_FILE"
    echo "host:web01=192.168.1.10" >> "$TEST_KV_FILE"

    run _kv_store_set "$TEST_KV_FILE" "alias:server2" "development"
    assert_success

    run _kv_store_get "$TEST_KV_FILE" "alias:server1"
    assert_output "production"

    run _kv_store_get "$TEST_KV_FILE" "host:web01"
    assert_output "192.168.1.10"

    run _kv_store_get "$TEST_KV_FILE" "alias:server2"
    assert_output "development"
}
