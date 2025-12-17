#!/usr/bin/env bats

load '../test_helper'
source "${SSHCFG_STORE_PLUGIN_DIR}/utils/validation.zsh"

setup() {
    load_bats_dep
}

# Mock _sshcfg_store_alias_list for testing (since it's not yet fully integrated)
_sshcfg_store_alias_list() {
    printf "existing-server\n"
    printf "prod-db\n"
    printf "staging-web\n"
}

# ============================================================================
# _sshcfg_store_validate_alias
# ============================================================================

# bats test_tags=_sshcfg_store_validate_alias,critical
@test "_sshcfg_store_validate_alias: accepts valid simple alias" {
    run _sshcfg_store_validate_alias "server1"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: accepts alias with numbers" {
    run _sshcfg_store_validate_alias "web01"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: accepts alias with dots" {
    run _sshcfg_store_validate_alias "prod.server.01"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: accepts alias with underscores" {
    run _sshcfg_store_validate_alias "web_server_01"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: accepts alias with dashes" {
    run _sshcfg_store_validate_alias "prod-web-01"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: accepts alias with mixed valid characters" {
    run _sshcfg_store_validate_alias "My-Server_1.0"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: accepts single character alias" {
    run _sshcfg_store_validate_alias "a"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_alias,critical
@test "_sshcfg_store_validate_alias: rejects empty alias" {
    run _sshcfg_store_validate_alias ""
    assert_failure 1
    assert_output --partial 'Alias cannot be empty'
}

# bats test_tags=_sshcfg_store_validate_alias,critical
@test "_sshcfg_store_validate_alias: rejects alias with spaces" {
    run _sshcfg_store_validate_alias "my server"
    assert_failure 1
    assert_output --partial 'Alias cannot contain spaces'
}

# bats test_tags=_sshcfg_store_validate_alias,critical
@test "_sshcfg_store_validate_alias: rejects alias with tab character" {
    run _sshcfg_store_validate_alias "$(printf 'my\tserver')"
    assert_failure 1
    assert_output --partial 'Alias cannot contain spaces'
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: rejects alias with @ symbol" {
    run _sshcfg_store_validate_alias "user@server"
    assert_failure 1
    assert_output --partial 'Alias can only contain letters, numbers, dots, underscores, dashes'
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: rejects alias with slash" {
    run _sshcfg_store_validate_alias "server/prod"
    assert_failure 1
    assert_output --partial 'Alias can only contain letters, numbers, dots, underscores, dashes'
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: rejects alias with asterisk" {
    run _sshcfg_store_validate_alias "server*"
    assert_failure 1
    assert_output --partial 'Alias can only contain letters, numbers, dots, underscores, dashes'
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: rejects alias with question mark" {
    run _sshcfg_store_validate_alias "server?"
    assert_failure 1
    assert_output --partial 'Alias can only contain letters, numbers, dots, underscores, dashes'
}

# bats test_tags=_sshcfg_store_validate_alias,critical
@test "_sshcfg_store_validate_alias: rejects existing alias" {
    run _sshcfg_store_validate_alias "existing-server"
    assert_failure 1
    assert_output --partial 'Alias already exists in SSH config'
}

# bats test_tags=_sshcfg_store_validate_alias
@test "_sshcfg_store_validate_alias: rejects alias with special characters" {
    run _sshcfg_store_validate_alias "server#1"
    assert_failure 1
    assert_output --partial 'Alias can only contain letters, numbers, dots, underscores, dashes'
}

# bats test_tags=_sshcfg_store_validate_alias,critical
@test "_sshcfg_store_validate_alias: rejects alias starting with non-letter" {
    run _sshcfg_store_validate_alias "_server"
    assert_failure 1
    assert_output --partial 'Alias must start with a letter'
}

# ============================================================================
# _sshcfg_store_validate_hostname
# ============================================================================

# bats test_tags=_sshcfg_store_validate_hostname,critical
@test "_sshcfg_store_validate_hostname: accepts valid domain name" {
    run _sshcfg_store_validate_hostname "example.com"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts subdomain" {
    run _sshcfg_store_validate_hostname "api.example.com"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts deep subdomain" {
    run _sshcfg_store_validate_hostname "prod.api.example.com"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts IPv4 address" {
    run _sshcfg_store_validate_hostname "192.168.1.1"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts hostname with numbers" {
    run _sshcfg_store_validate_hostname "server01.example.com"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts hostname with dashes" {
    run _sshcfg_store_validate_hostname "web-server.example.com"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts single character hostname" {
    run _sshcfg_store_validate_hostname "a"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts localhost" {
    run _sshcfg_store_validate_hostname "localhost"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_hostname,critical
@test "_sshcfg_store_validate_hostname: rejects empty hostname" {
    run _sshcfg_store_validate_hostname ""
    assert_failure 1
    assert_output --partial 'Hostname cannot be empty'
}

# bats test_tags=_sshcfg_store_validate_hostname,critical
@test "_sshcfg_store_validate_hostname: rejects hostname starting with dot" {
    run _sshcfg_store_validate_hostname ".example.com"
    assert_failure 1
    assert_output --partial 'Hostname cannot start with a dot'
}

# bats test_tags=_sshcfg_store_validate_hostname,critical
@test "_sshcfg_store_validate_hostname: rejects hostname ending with dot" {
    run _sshcfg_store_validate_hostname "example.com."
    assert_failure 1
    assert_output --partial 'Hostname cannot end with a dot'
}

# bats test_tags=_sshcfg_store_validate_hostname,critical
@test "_sshcfg_store_validate_hostname: rejects hostname with consecutive dots" {
    run _sshcfg_store_validate_hostname "example..com"
    assert_failure 1
    assert_output --partial 'Hostname cannot contain consecutive dots'
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: rejects hostname with spaces" {
    run _sshcfg_store_validate_hostname "example .com"
    assert_failure 1
    assert_output --partial 'Invalid hostname format'
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: rejects hostname with underscore" {
    run _sshcfg_store_validate_hostname "example_host.com"
    assert_failure 1
    assert_output --partial 'Invalid hostname format'
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: rejects hostname starting with dash" {
    run _sshcfg_store_validate_hostname "-example.com"
    assert_failure 1
    assert_output --partial 'Invalid hostname format'
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: rejects hostname ending with dash" {
    run _sshcfg_store_validate_hostname "example.com-"
    assert_failure 1
    assert_output --partial 'Invalid hostname format'
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: rejects too long hostname" {
    local long_hostname=$(printf 'a%.0s' {1..254})
    run _sshcfg_store_validate_hostname "$long_hostname"
    assert_failure 1
    assert_output --partial 'Hostname too long (max 253 characters)'
}

# bats test_tags=_sshcfg_store_validate_hostname
@test "_sshcfg_store_validate_hostname: accepts exactly 253 character hostname" {
    local max_hostname=$(printf 'a%.0s' {1..253})
    run _sshcfg_store_validate_hostname "$max_hostname"
    assert_success
}

# ============================================================================
# _sshcfg_store_validate_username
# ============================================================================

# bats test_tags=_sshcfg_store_validate_username,critical
@test "_sshcfg_store_validate_username: accepts valid simple username" {
    run _sshcfg_store_validate_username "ubuntu"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: accepts username with numbers" {
    run _sshcfg_store_validate_username "user123"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: accepts username with underscore" {
    run _sshcfg_store_validate_username "web_user"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: accepts username with dash" {
    run _sshcfg_store_validate_username "app-user"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: accepts username with dot" {
    run _sshcfg_store_validate_username "john.doe"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: accepts mixed valid characters" {
    run _sshcfg_store_validate_username "user.name-123"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: accepts single letter username" {
    run _sshcfg_store_validate_username "a"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: accepts 32 character username" {
    run _sshcfg_store_validate_username "a$(printf 'b%.0s' {1..31})"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_username,critical
@test "_sshcfg_store_validate_username: rejects empty username" {
    run _sshcfg_store_validate_username ""
    assert_failure 1
    assert_output --partial 'Username cannot be empty'
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: rejects too long username" {
    run _sshcfg_store_validate_username "a$(printf 'b%.0s' {1..32})"
    assert_failure 1
    assert_output --partial 'Username too long (max 32 characters)'
}

# bats test_tags=_sshcfg_store_validate_username,critical
@test "_sshcfg_store_validate_username: rejects username starting with dot" {
    run _sshcfg_store_validate_username ".user"
    assert_failure 1
    assert_output --partial 'Username cannot start with a dot'
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: rejects username ending with dot" {
    run _sshcfg_store_validate_username "user."
    assert_failure 1
    assert_output --partial 'Username cannot end with a dot'
}

# bats test_tags=_sshcfg_store_validate_username,critical
@test "_sshcfg_store_validate_username: rejects username starting with dash" {
    run _sshcfg_store_validate_username "-user"
    assert_failure 1
    assert_output --partial 'Username cannot start with a dash'
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: rejects username ending with dash" {
    run _sshcfg_store_validate_username "user-"
    assert_failure 1
    assert_output --partial 'Username cannot end with a dash'
}

# bats test_tags=_sshcfg_store_validate_username,critical
@test "_sshcfg_store_validate_username: rejects username with consecutive dots" {
    run _sshcfg_store_validate_username "user..name"
    assert_failure 1
    assert_output --partial 'Username cannot contain consecutive dots'
}

# bats test_tags=_sshcfg_store_validate_username,critical
@test "_sshcfg_store_validate_username: rejects username with consecutive dashes" {
    run _sshcfg_store_validate_username "user--name"
    assert_failure 1
    assert_output --partial 'Username cannot contain consecutive dashes'
}

# bats test_tags=_sshcfg_store_validate_username,critical
@test "_sshcfg_store_validate_username: rejects username starting with number" {
    run _sshcfg_store_validate_username "123user"
    assert_failure 1
    assert_output --partial 'Username must start with a letter'
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: rejects username with spaces" {
    run _sshcfg_store_validate_username "my user"
    assert_failure 1
    assert_output --partial 'Username must start with a letter'
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: rejects username with @ symbol" {
    run _sshcfg_store_validate_username "user@host"
    assert_failure 1
    assert_output --partial 'Username must start with a letter'
}

# bats test_tags=_sshcfg_store_validate_username
@test "_sshcfg_store_validate_username: rejects username with special characters" {
    run _sshcfg_store_validate_username "user#123"
    assert_failure 1
    assert_output --partial 'Username must start with a letter'
}

# ============================================================================
# _sshcfg_store_validate_port
# ============================================================================

# bats test_tags=_sshcfg_store_validate_port,critical
@test "_sshcfg_store_validate_port: accepts standard SSH port 22" {
    run _sshcfg_store_validate_port "22"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: accepts port 1" {
    run _sshcfg_store_validate_port "1"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: accepts port 65535" {
    run _sshcfg_store_validate_port "65535"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: accepts common alternate SSH port 2222" {
    run _sshcfg_store_validate_port "2222"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: accepts HTTP port 80" {
    run _sshcfg_store_validate_port "80"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: accepts HTTPS port 443" {
    run _sshcfg_store_validate_port "443"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: accepts high port 8080" {
    run _sshcfg_store_validate_port "8080"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_port,critical
@test "_sshcfg_store_validate_port: rejects port 0" {
    run _sshcfg_store_validate_port "0"
    assert_failure 1
    assert_output --partial 'Port must be greater than 0'
}

# bats test_tags=_sshcfg_store_validate_port,critical
@test "_sshcfg_store_validate_port: rejects port 65536" {
    run _sshcfg_store_validate_port "65536"
    assert_failure 1
    assert_output --partial 'Port must be less than 65536'
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: rejects port 99999" {
    run _sshcfg_store_validate_port "99999"
    assert_failure 1
    assert_output --partial 'Port must be less than 65536'
}

# bats test_tags=_sshcfg_store_validate_port,critical
@test "_sshcfg_store_validate_port: rejects negative port" {
    run _sshcfg_store_validate_port "-1"
    assert_failure 1
    assert_output --partial 'Port must be a number'
}

# bats test_tags=_sshcfg_store_validate_port,critical
@test "_sshcfg_store_validate_port: rejects non-numeric port" {
    run _sshcfg_store_validate_port "abc"
    assert_failure 1
    assert_output --partial 'Port must be a number'
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: rejects port with spaces" {
    run _sshcfg_store_validate_port "22 22"
    assert_failure 1
    assert_output --partial 'Port must be a number'
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: rejects port with decimal" {
    run _sshcfg_store_validate_port "22.5"
    assert_failure 1
    assert_output --partial 'Port must be a number'
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: rejects empty port" {
    run _sshcfg_store_validate_port ""
    assert_failure 1
    assert_output --partial 'Port must be a number'
}

# bats test_tags=_sshcfg_store_validate_port
@test "_sshcfg_store_validate_port: accepts port with leading zero" {
    run _sshcfg_store_validate_port "022"
    assert_success
}

# ============================================================================
# _sshcfg_store_validate_identity_file
# ============================================================================

# bats test_tags=_sshcfg_store_validate_identity_file,critical
@test "_sshcfg_store_validate_identity_file: accepts existing readable file" {
    local temp_file=$(mktemp)
    run _sshcfg_store_validate_identity_file "$temp_file"
    rm "$temp_file"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_identity_file,critical
@test "_sshcfg_store_validate_identity_file: rejects empty path" {
    run _sshcfg_store_validate_identity_file ""
    assert_failure 1
    assert_output --partial 'Identity file path cannot be empty'
}

# bats test_tags=_sshcfg_store_validate_identity_file,critical
@test "_sshcfg_store_validate_identity_file: rejects non-existent file" {
    run _sshcfg_store_validate_identity_file "/tmp/nonexistent_key_file_12345"
    assert_failure 1
    assert_output --partial 'Identity file does not exist'
}

# bats test_tags=_sshcfg_store_validate_identity_file
@test "_sshcfg_store_validate_identity_file: rejects directory path" {
    run _sshcfg_store_validate_identity_file "/tmp"
    assert_failure 1
    assert_output --partial 'Identity file does not exist'
}

# ============================================================================
# _sshcfg_store_validate_key_type
# ============================================================================

# bats test_tags=_sshcfg_store_validate_key_type,critical
@test "_sshcfg_store_validate_key_type: accepts ed25519" {
    run _sshcfg_store_validate_key_type "ed25519"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_key_type,critical
@test "_sshcfg_store_validate_key_type: accepts rsa" {
    run _sshcfg_store_validate_key_type "rsa"
    assert_success
}

# bats test_tags=_sshcfg_store_validate_key_type,critical
@test "_sshcfg_store_validate_key_type: rejects dsa" {
    run _sshcfg_store_validate_key_type "dsa"
    assert_failure 1
    assert_output --partial 'Key type must be either ed25519 or rsa'
}

# bats test_tags=_sshcfg_store_validate_key_type
@test "_sshcfg_store_validate_key_type: rejects ecdsa" {
    run _sshcfg_store_validate_key_type "ecdsa"
    assert_failure 1
    assert_output --partial 'Key type must be either ed25519 or rsa'
}

# bats test_tags=_sshcfg_store_validate_key_type,critical
@test "_sshcfg_store_validate_key_type: rejects empty key type" {
    run _sshcfg_store_validate_key_type ""
    assert_failure 1
    assert_output --partial 'Key type must be either ed25519 or rsa'
}

# bats test_tags=_sshcfg_store_validate_key_type
@test "_sshcfg_store_validate_key_type: rejects invalid key type" {
    run _sshcfg_store_validate_key_type "invalid"
    assert_failure 1
    assert_output --partial 'Key type must be either ed25519 or rsa'
}

# bats test_tags=_sshcfg_store_validate_key_type
@test "_sshcfg_store_validate_key_type: rejects uppercase ED25519" {
    run _sshcfg_store_validate_key_type "ED25519"
    assert_failure 1
    assert_output --partial 'Key type must be either ed25519 or rsa'
}

# bats test_tags=_sshcfg_store_validate_key_type
@test "_sshcfg_store_validate_key_type: rejects uppercase RSA" {
    run _sshcfg_store_validate_key_type "RSA"
    assert_failure 1
    assert_output --partial 'Key type must be either ed25519 or rsa'
}
