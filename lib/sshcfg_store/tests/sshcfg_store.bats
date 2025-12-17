#!/usr/bin/env bats

load 'test_helper'
source "${SSHCFG_STORE_PLUGIN_DIR}/sshcfg_store.zsh"

setup() {
    load_bats_dep
    TEST_DIR="$BATS_TEST_TMPDIR/sshcfg_test"
    mkdir -p "$TEST_DIR"
    TEST_CONFIG="${TEST_DIR}/config"
    INCLUDE_CONFIG="${TEST_DIR}/include_config"

    touch "$TEST_CONFIG"
    export SSHCFG_STORE_CONF_FILE="$TEST_CONFIG"
}

teardown() {
    unset SSHCFG_STORE_CONF_FILE
    [[ -n "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}

# ============================================================================
# _sshcfg_store_parse_fields
# ============================================================================

# bats test_tags=_sshcfg_store_parse_fields,critical
@test "_sshcfg_store_parse_fields: extracts single field" {
    local input="Host server1
    HostName example.com
    User ubuntu"

    run _sshcfg_store_parse_fields "Host" <<< "$input"

    assert_success
    assert_output "Host server1"
}

# bats test_tags=_sshcfg_store_parse_fields,critical
@test "_sshcfg_store_parse_fields: extracts multiple fields with pipe delimiter" {
    local input="Host server1
    HostName example.com
    User ubuntu
    Port 22"

    run _sshcfg_store_parse_fields "HostName|User|Port" <<< "$input"

    assert_success
    assert_line -n 0 "HostName example.com"
    assert_line -n 1 "User ubuntu"
    assert_line -n 2 "Port 22"
}

# bats test_tags=_sshcfg_store_parse_fields,critical
@test "_sshcfg_store_parse_fields: strips inline comments" {
    local input="Host server1  # production server
    HostName example.com  # main domain"

    run _sshcfg_store_parse_fields "Host|HostName" <<< "$input"

    assert_success
    assert_output --partial "Host server1"
    assert_output --partial "HostName example.com"
    refute_output --partial "# production"
    refute_output --partial "# main domain"
}

# bats test_tags=_sshcfg_store_parse_fields
@test "_sshcfg_store_parse_fields: handles indented fields" {
    local input="Host server1
        HostName example.com
        User ubuntu"

    run _sshcfg_store_parse_fields "HostName|User" <<< "$input"

    assert_success
    assert_line -n 0 "HostName example.com"
    assert_line -n 1 "User ubuntu"
}

# bats test_tags=_sshcfg_store_parse_fields
@test "_sshcfg_store_parse_fields: case-insensitive matching" {
    local input="host server1
    hostname example.com
    user ubuntu"

    run _sshcfg_store_parse_fields "hostname|user" <<< "$input"

    assert_success
    assert_line -n 0 "hostname example.com"
    assert_line -n 1 "user ubuntu"
}

# bats test_tags=_sshcfg_store_parse_fields
@test "_sshcfg_store_parse_fields: ignores non-matching lines" {
    local input="# Comment line
    Host server1
    HostName example.com
    Port 22
    User ubuntu"

    run _sshcfg_store_parse_fields "Host|User" <<< "$input"

    assert_success
    assert_line -n 0 "Host server1"
    assert_line -n 1 "User ubuntu"
}

# bats test_tags=_sshcfg_store_parse_fields
@test "_sshcfg_store_parse_fields: preserves values with spaces" {
    local input="Host server1
    IdentityFile /path/with spaces/key"

    run _sshcfg_store_parse_fields "IdentityFile" <<< "$input"

    assert_success
    assert_output "IdentityFile /path/with spaces/key"
}

# bats test_tags=_sshcfg_store_parse_fields
@test "_sshcfg_store_parse_fields: returns nothing for no matches" {
    local input="Host server1
    HostName example.com"

    run _sshcfg_store_parse_fields "Port" <<< "$input"

    assert_success
    assert_output ""
}

# bats test_tags=_sshcfg_store_parse_fields
@test "_sshcfg_store_parse_fields: handles empty input" {
    run _sshcfg_store_parse_fields "Host" <<< ""

    assert_success
    assert_output ""
}

# bats test_tags=_sshcfg_store_parse_fields
@test "_sshcfg_store_parse_fields: normalizes multiple spaces between field and value" {
    local input="Host    server1
    HostName     example.com"

    run _sshcfg_store_parse_fields "Host|HostName" <<< "$input"

    assert_success
    assert_output --partial "Host server1"
    assert_output --partial "HostName example.com"
}

# ============================================================================
# _sshcfg_store_alias_list
# ============================================================================

# bats test_tags=_sshcfg_store_alias_list,critical
@test "_sshcfg_store_alias_list: extracts simple host aliases" {
    cat > "$TEST_CONFIG" << 'EOF'
Host server1
    HostName example.com

Host server2
    HostName example2.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_line -n 0 "server1"
    assert_line -n 1 "server2"
}

# bats test_tags=_sshcfg_store_alias_list,critical
@test "_sshcfg_store_alias_list: excludes wildcard aliases" {
    cat > "$TEST_CONFIG" << 'EOF'
Host server1
    HostName example.com

Host *
    User default

Host server2
    HostName example2.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    refute_output --partial "*"
    assert_line -n 0 "server1"
    assert_line -n 1 "server2"
}

# bats test_tags=_sshcfg_store_alias_list,critical
@test "_sshcfg_store_alias_list: excludes pattern aliases with ?" {
    cat > "$TEST_CONFIG" << 'EOF'
Host server1
    HostName example.com

Host server?
    HostName pattern.com

Host server2
    HostName example2.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    refute_output --partial "server?"
    assert_line -n 0 "server1"
    assert_line -n 1 "server2"
}

# bats test_tags=_sshcfg_store_alias_list,critical
@test "_sshcfg_store_alias_list: handles multiple aliases per Host line" {
    cat > "$TEST_CONFIG" << 'EOF'
Host server1 srv1 s1
    HostName example.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_line -n 0 "server1"
    assert_line -n 1 "srv1"
    assert_line -n 2 "s1"
}

# bats test_tags=_sshcfg_store_alias_list,critical
@test "_sshcfg_store_alias_list: follows Include directives" {
    cat > "$INCLUDE_CONFIG" << 'EOF'
Host included1
    HostName included.com
EOF

    cat > "$TEST_CONFIG" << EOF
Include ${INCLUDE_CONFIG}

Host server1
    HostName example.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_output --partial "server1"
    assert_output --partial "included1"
}

# bats test_tags=_sshcfg_store_alias_list
@test "_sshcfg_store_alias_list: handles non-existent Include gracefully" {
    cat > "$TEST_CONFIG" << 'EOF'
Include /nonexistent/config

Host server1
    HostName example.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_output "server1"
}

# bats test_tags=_sshcfg_store_alias_list
@test "_sshcfg_store_alias_list: handles empty config file" {
    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_output ""
}

# bats test_tags=_sshcfg_store_alias_list
@test "_sshcfg_store_alias_list: handles config with only comments" {
    cat > "$TEST_CONFIG" << 'EOF'
# This is a comment
# Another comment
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_output ""
}

# bats test_tags=_sshcfg_store_alias_list
@test "_sshcfg_store_alias_list: handles nested Include directives" {
    local nested_config="${TEST_DIR}/nested_config"

    cat > "$nested_config" << 'EOF'
Host nested1
    HostName nested.com
EOF

    cat > "$INCLUDE_CONFIG" << EOF
Include ${nested_config}

Host included1
    HostName included.com
EOF

    cat > "$TEST_CONFIG" << EOF
Include ${INCLUDE_CONFIG}

Host server1
    HostName example.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_output --partial "server1"
    assert_output --partial "included1"
    assert_output --partial "nested1"
}

# bats test_tags=_sshcfg_store_alias_list
@test "_sshcfg_store_alias_list: handles multiple Include directives" {
    local include2="${TEST_DIR}/include2"

    cat > "$INCLUDE_CONFIG" << 'EOF'
Host included1
    HostName included.com
EOF

    cat > "$include2" << 'EOF'
Host included2
    HostName included2.com
EOF

    cat > "$TEST_CONFIG" << EOF
Include ${INCLUDE_CONFIG}
Include ${include2}

Host server1
    HostName example.com
EOF

    run _sshcfg_store_alias_list "$TEST_CONFIG"

    assert_success
    assert_output --partial "server1"
    assert_output --partial "included1"
    assert_output --partial "included2"
}

# ============================================================================
# _sshcfg_store_get
# ============================================================================

# bats test_tags=_sshcfg_store_get,critical
@test "_sshcfg_store_get: retrieves hostname for existing alias" {
    _sshcfg_store_add "$TEST_CONFIG" "testserver" "test.example.com" "testuser" "22" ""

    run _sshcfg_store_get "testserver" "hostname"

    assert_success
    assert_output --partial "hostname test.example.com"
}

# bats test_tags=_sshcfg_store_get,critical
@test "_sshcfg_store_get: retrieves multiple fields" {
    _sshcfg_store_add "$TEST_CONFIG" "testserver" "test.example.com" "testuser" "2222" ""

    run _sshcfg_store_get "testserver" "hostname|user|port"

    assert_success
    assert_output --partial "hostname test.example.com"
    assert_output --partial "user testuser"
    assert_output --partial "port 2222"
}

# bats test_tags=_sshcfg_store_get,critical
@test "_sshcfg_store_get: fails for non-existent alias" {
    run _sshcfg_store_get "nonexistent" "hostname"

    assert_failure
}

# bats test_tags=_sshcfg_store_get
@test "_sshcfg_store_get: uses SSHCFG_STORE_CONF_FILE environment variable" {
    _sshcfg_store_add "$TEST_CONFIG" "envtest" "env.example.com" "envuser" "22" ""

    run _sshcfg_store_get "envtest" "hostname"

    assert_success
    assert_output --partial "hostname env.example.com"
}

# bats test_tags=_sshcfg_store_get
@test "_sshcfg_store_get: retrieves identity file when configured" {
    local key_file="${TEST_DIR}/test_key"
    touch "$key_file"
    _sshcfg_store_add "$TEST_CONFIG" "keytest" "key.example.com" "keyuser" "22" "$key_file"

    run _sshcfg_store_get "keytest" "identityfile"

    assert_success
    assert_output --partial "identityfile ${key_file}"
}

# ============================================================================
# _sshcfg_store_add
# ============================================================================

# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: adds new host configuration" {
    run _sshcfg_store_add "$TEST_CONFIG" "newserver" "new.example.com" "newuser" "22" ""

    assert_success
    assert_file_contains "$TEST_CONFIG" "Host newserver"
    assert_file_contains "$TEST_CONFIG" "HostName new.example.com"
    assert_file_contains "$TEST_CONFIG" "User newuser"
    assert_file_contains "$TEST_CONFIG" "Port 22"
}

# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: adds host with identity file" {
    local key_file="${TEST_DIR}/test_key"
    touch "$key_file"

    run _sshcfg_store_add "$TEST_CONFIG" "keyserver" "key.example.com" "keyuser" "22" "$key_file"

    assert_success
    assert_file_contains "$TEST_CONFIG" "IdentityFile ${key_file}"
    assert_file_contains "$TEST_CONFIG" "IdentitiesOnly yes"
}

# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: creates backup before adding" {
      echo "existing content" > "$TEST_CONFIG"
      local backup_dir="$(dirname "$TEST_CONFIG")"

      run _sshcfg_store_add "$TEST_CONFIG" "newserver" "new.example.com" "newuser" "22" ""

      assert_success

      local backup_file=$(ls -1 "$backup_dir"/config.* 2>/dev/null | head -1)
      assert_file_contains "$backup_file" "existing content"
  }


# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: validates alias before adding" {
    run _sshcfg_store_add "$TEST_CONFIG" "invalid alias" "example.com" "user" "22" ""

    assert_failure
}

# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: validates hostname before adding" {
    run _sshcfg_store_add "$TEST_CONFIG" "server" "invalid..hostname" "user" "22" ""

    assert_failure
}

# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: validates username before adding" {
    run _sshcfg_store_add "$TEST_CONFIG" "server" "example.com" "123invalid" "22" ""

    assert_failure
}

# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: validates port before adding" {
    run _sshcfg_store_add "$TEST_CONFIG" "server" "example.com" "user" "99999" ""

    assert_failure
}

# bats test_tags=_sshcfg_store_add
@test "_sshcfg_store_add: preserves existing hosts" {
    cat > "$TEST_CONFIG" << 'EOF'
Host existing
    HostName existing.com
EOF

    run _sshcfg_store_add "$TEST_CONFIG" "newserver" "new.example.com" "newuser" "22" ""

    assert_success
    assert_file_contains "$TEST_CONFIG" "Host existing"
    assert_file_contains "$TEST_CONFIG" "Host newserver"
}

# bats test_tags=_sshcfg_store_add,critical
@test "_sshcfg_store_add: prevents duplicate host aliases" {
    _sshcfg_store_add "$TEST_CONFIG" "server1" "first.example.com" "user1" "22" ""

    run _sshcfg_store_add "$TEST_CONFIG" "server1" "second.example.com" "user2" "22" ""

    assert_failure
    assert_output --partial "Alias already exists"
}
