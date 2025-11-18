#!/usr/bin/env bats

load '../test_helper'
source "${KV_STORE_PLUGIN_DIR}/utils/validation.zsh"

setup() {
    load_bats_dep
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: accepts valid namespace:key format" {
    run _kv_store_validate_key "alias:server1"
    assert_success
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: accepts key with dots" {
    run _kv_store_validate_key "host:prod.server.01"
    assert_success
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: accepts key with dashes" {
    run _kv_store_validate_key "env:prod-web-01"
    assert_success
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: accepts key with underscores" {
    run _kv_store_validate_key "server:web_app_01"
    assert_success
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: accepts key with multiple colons" {
    run _kv_store_validate_key "app:db:primary:01"
    assert_success
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: accepts key with numbers" {
    run _kv_store_validate_key "server123:host456"
    assert_success
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: accepts key with mixed valid characters" {
    run _kv_store_validate_key "My-App_1.0:prod-db.host-01"
    assert_success
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects empty key" {
    run _kv_store_validate_key ""
    assert_failure 1
    assert_output --partial 'Alias cannot be empty'
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects key without colon separator" {
    run _kv_store_validate_key "nocolon"
    assert_failure 1
    assert_output --partial 'Key must be in format namespace:key and contain ":" separator (both sides required)'
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects key with spaces" {
    run _kv_store_validate_key "alias:my server"
    assert_failure 1
    assert_output --partial 'Key must not contain spaces'
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects key with bracket" {
    run _kv_store_validate_key "alias:server[1]"
    assert_failure 1
    assert_output --partial 'Key must not contain "[" or "]"'
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: rejects key with special characters (@)" {
    run _kv_store_validate_key "user@host:value"
    assert_failure 1
    assert_output --partial 'Invalid key format (format: namespace:key)'
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: rejects key with special characters (#)" {
    run _kv_store_validate_key "alias:#tag"
    assert_failure 1
    assert_output --partial 'Invalid key format (format: namespace:key)'
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: rejects key with special characters ($)" {
    # shellcheck disable=SC2016
    run _kv_store_validate_key 'var:$value'
    assert_failure 1
    assert_output --partial 'Invalid key format (format: namespace:key)'
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: rejects key with forward slash" {
    run _kv_store_validate_key "path:/home/user"
    assert_failure 1
    assert_output --partial 'Invalid key format (format: namespace:key)'
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: rejects key with exclamation mark" {
    run _kv_store_validate_key "alert:server!"
    assert_failure 1
    assert_output --partial 'Invalid key format (format: namespace:key)'
}

# bats test_tags=_kv_store_validate_key
@test "_kv_store_validate_key: accepts minimal valid key" {
    run _kv_store_validate_key "a:b"
    assert_success
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects key with only colon" {
    run _kv_store_validate_key ":"
    assert_failure 1
    assert_output --partial 'Key must be in format namespace:key and contain ":" separator (both sides required)'
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects key with leading colon only" {
    run _kv_store_validate_key ":value"
    assert_failure 1
    assert_output --partial 'Key must be in format namespace:key and contain ":" separator (both sides required)'
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects key with trailing colon only" {
    run _kv_store_validate_key "namespace:"
    assert_failure 1
    assert_output --partial 'Key must be in format namespace:key and contain ":" separator (both sides required)'
}

# bats test_tags=_kv_store_validate_key,critical
@test "_kv_store_validate_key: rejects key with tab character" {
    run _kv_store_validate_key "$(printf 'alias:\tserver')"
    assert_failure 1
    assert_output --partial 'Key must not contain spaces'
}

#_kv_store_validate_value

# bats test_tags=_kv_store_validate_value,critical
@test "_kv_store_validate_value: accepts simple string value" {
    run _kv_store_validate_value "production"
    assert_success
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: accepts value with spaces" {
    run _kv_store_validate_value "web server 01"
    assert_success
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: accepts value with commas" {
    run _kv_store_validate_value "prod,staging,dev"
    assert_success
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: accepts value with special characters" {
    run _kv_store_validate_value "server@prod!#$%^&*()"
    assert_success
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: accepts empty value" {
    run _kv_store_validate_value ""
    assert_success
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: accepts value with numbers" {
    run _kv_store_validate_value "192.168.1.1:8080"
    assert_success
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: accepts value with brackets" {
    run _kv_store_validate_value "array[0]"
    assert_success
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: accepts value with colons" {
    run _kv_store_validate_value "host:port:path"
    assert_success
}

# bats test_tags=_kv_store_validate_value,critical
@test "_kv_store_validate_value: rejects value with newline character" {
    run _kv_store_validate_value "$(printf 'line1\nline2')"
    assert_failure 1
    assert_output --partial 'Value must not contain newlines'
}

# bats test_tags=_kv_store_validate_value,critical
@test "_kv_store_validate_value: rejects value with single quote" {
    run _kv_store_validate_value "it's a value"
    assert_failure 1
    assert_output --partial 'Value must not contain quotes'
}

# bats test_tags=_kv_store_validate_value,critical
@test "_kv_store_validate_value: rejects value with double quote" {
    run _kv_store_validate_value 'say "hello"'
    assert_failure 1
    assert_output --partial 'Value must not contain quotes'
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: rejects value with both quote types" {
    run _kv_store_validate_value "it's \"quoted\""
    assert_failure 1
    assert_output --partial 'Value must not contain quotes'
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: rejects value with only single quote" {
    run _kv_store_validate_value "'"
    assert_failure 1
    assert_output --partial 'Value must not contain quotes'
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: rejects value with only double quote" {
    run _kv_store_validate_value '"'
    assert_failure 1
    assert_output --partial 'Value must not contain quotes'
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: rejects value with multiple newlines" {
    run _kv_store_validate_value "$(printf 'line1\nline2\nline3')"
    assert_failure 1
    assert_output --partial 'Value must not contain newlines'
}

# bats test_tags=_kv_store_validate_value
@test "_kv_store_validate_value: rejects value with carriage return" {
    run _kv_store_validate_value "$(printf 'line1\r\nline2')"
    assert_failure 1
    assert_output --partial 'Value must not contain newlines'
}
