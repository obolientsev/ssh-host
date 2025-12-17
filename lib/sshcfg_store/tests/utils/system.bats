#!/usr/bin/env bats

load '../test_helper'
source "${SSHCFG_STORE_PLUGIN_DIR}/utils/system.zsh"

setup() {
    load_bats_dep
    TEST_DIR="$BATS_TEST_TMPDIR"
    TEST_FILE="${TEST_DIR}/test.conf"
    BACKUP_DIR="${TEST_DIR}/backups"
    BASE_CONFIG="${TEST_DIR}/base_config"
    INCLUDE_CONFIG="${TEST_DIR}/include_config"
}

teardown() {
    [[ -n "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}

# ============================================================================
# _sshcfg_store_backup_file
# ============================================================================

# bats test_tags=_sshcfg_store_backup_file,critical
@test "_sshcfg_store_backup_file: creates backup of existing file" {
    echo "test content" > "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    assert_dir_exists "$BACKUP_DIR"
    local backup_count=$(find "$BACKUP_DIR" -name "test.conf.*" | wc -l)
    assert_equal "$backup_count" "1"
}

# bats test_tags=_sshcfg_store_backup_file,critical
@test "_sshcfg_store_backup_file: backup contains same content as original" {
    echo "test content" > "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    local backup_file=$(find "$BACKUP_DIR" -name "test.conf.*" -type f)
    assert_equal "$(cat "$backup_file")" "test content"
}

# bats test_tags=_sshcfg_store_backup_file,critical
@test "_sshcfg_store_backup_file: returns success when file doesn't exist" {
    run _sshcfg_store_backup_file "/nonexistent/file.txt" "$BACKUP_DIR"

    assert_success
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: does not create backup dir when file doesn't exist" {
    run _sshcfg_store_backup_file "/nonexistent/file.txt" "$BACKUP_DIR"

    assert_success
    assert_dir_not_exists "$BACKUP_DIR"
}

# bats test_tags=_sshcfg_store_backup_file,critical
@test "_sshcfg_store_backup_file: creates backup directory if it doesn't exist" {
    echo "test content" > "$TEST_FILE"

    assert_dir_not_exists "$BACKUP_DIR"
    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    assert_dir_exists "$BACKUP_DIR"
}

# bats test_tags=_sshcfg_store_backup_file,critical
@test "_sshcfg_store_backup_file: creates backup directory with 700 permissions" {
    echo "test content" > "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    assert_file_permission 700 "$BACKUP_DIR"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: uses file directory as default backup location" {
    echo "test content" > "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE"

    assert_success
    local backup_count=$(find "$TEST_DIR" -name "test.conf.*" | wc -l)
    assert_equal "$backup_count" "1"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: backup filename includes timestamp" {
    echo "test content" > "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    local backup_file=$(find "$BACKUP_DIR" -name "test.conf.*" -type f)
    assert_regex "$backup_file" "test\.conf\.[0-9]{8}_[0-9]{6}$"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: timestamp format is YYYYMMDD_HHMMSS" {
    echo "test content" > "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    local backup_file=$(basename "$(find "$BACKUP_DIR" -name "test.conf.*" -type f)")
    local timestamp="${backup_file#test.conf.}"

    assert_regex "$timestamp" "^[0-9]{8}_[0-9]{6}$"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: preserves file content variations" {
    echo "special chars: @#$%^&*()[]{}|\\;'\"<>?,./~\`" > "$TEST_FILE"
    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"
    assert_success
    local backup_file=$(find "$BACKUP_DIR" -name "test.conf.*" -type f)
    assert_equal "$(cat "$backup_file")" "special chars: @#$%^&*()[]{}|\\;'\"<>?,./~\`"

    printf "line1\nline2\nline3\n" > "$TEST_FILE"
    rm -rf "$BACKUP_DIR"
    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"
    assert_success
    backup_file=$(find "$BACKUP_DIR" -name "test.conf.*" -type f)
    assert_equal "$(cat "$backup_file")" "$(printf "line1\nline2\nline3\n")"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: preserves empty file" {
    touch "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    local backup_file=$(find "$BACKUP_DIR" -name "test.conf.*" -type f)
    assert_file_exists "$backup_file"
    assert_file_empty "$backup_file"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: handles file with spaces in name" {
    local file_with_spaces="${TEST_DIR}/test file.conf"
    echo "test content" > "$file_with_spaces"

    run _sshcfg_store_backup_file "$file_with_spaces" "$BACKUP_DIR"

    assert_success
    local backup_count=$(find "$BACKUP_DIR" -name "test file.conf.*" | wc -l)
    assert_equal "$backup_count" "1"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: handles deeply nested backup directory" {
    echo "test content" > "$TEST_FILE"
    local deep_backup="${BACKUP_DIR}/level1/level2/level3"

    run _sshcfg_store_backup_file "$TEST_FILE" "$deep_backup"

    assert_success
    assert_dir_exists "$deep_backup"
    local backup_count=$(find "$deep_backup" -name "test.conf.*" | wc -l)
    assert_equal "$backup_count" "1"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: handles various file extensions" {
    local config_file="${TEST_DIR}/ssh.config"
    echo "test content" > "$config_file"
    run _sshcfg_store_backup_file "$config_file" "$BACKUP_DIR"
    assert_success
    local backup_file=$(find "$BACKUP_DIR" -name "ssh.config.*" -type f)
    assert_file_exists "$backup_file"
    assert_regex "$backup_file" "ssh\.config\.[0-9]{8}_[0-9]{6}$"

    local no_ext_file="${TEST_DIR}/config"
    echo "test content" > "$no_ext_file"
    rm -rf "$BACKUP_DIR"
    run _sshcfg_store_backup_file "$no_ext_file" "$BACKUP_DIR"
    assert_success
    backup_file=$(find "$BACKUP_DIR" -name "config.*" -type f)
    assert_file_exists "$backup_file"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: works with relative paths" {
    local rel_file="test.conf"
    echo "test content" > "$TEST_DIR/$rel_file"

    cd "$TEST_DIR"
    run _sshcfg_store_backup_file "$rel_file" "backups"
    cd -

    assert_success
    assert_dir_exists "$TEST_DIR/backups"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: original file remains unchanged" {
    echo "original content" > "$TEST_FILE"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    assert_equal "$(cat "$TEST_FILE")" "original content"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: handles moderately sized files" {
    dd if=/dev/zero of="$TEST_FILE" bs=1024 count=10 2>/dev/null

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    local backup_file=$(find "$BACKUP_DIR" -name "test.conf.*" -type f)
    assert_files_equal "$TEST_FILE" "$backup_file"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: backup directory already exists" {
    echo "test content" > "$TEST_FILE"
    mkdir -p "$BACKUP_DIR"

    run _sshcfg_store_backup_file "$TEST_FILE" "$BACKUP_DIR"

    assert_success
    local backup_count=$(find "$BACKUP_DIR" -name "test.conf.*" | wc -l)
    assert_equal "$backup_count" "1"
}

# bats test_tags=_sshcfg_store_backup_file
@test "_sshcfg_store_backup_file: handles hidden files" {
    local hidden_file="${TEST_DIR}/.hidden"
    echo "hidden content" > "$hidden_file"

    run _sshcfg_store_backup_file "$hidden_file" "$BACKUP_DIR"

    assert_success
    local backup_count=$(find "$BACKUP_DIR" -name ".hidden.*" | wc -l)
    assert_equal "$backup_count" "1"
}

# ============================================================================
# _sshcfg_store_ensure_include_directive
# ============================================================================

# bats test_tags=_sshcfg_store_ensure_include_directive,critical
@test "_sshcfg_store_ensure_include_directive: adds Include directive to empty base config" {
    touch "$BASE_CONFIG"
    touch "$INCLUDE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    run grep -Fq "Include ${INCLUDE_CONFIG}" "$BASE_CONFIG"
    assert_success
}

# bats test_tags=_sshcfg_store_ensure_include_directive,critical
@test "_sshcfg_store_ensure_include_directive: Include directive is at the beginning of file" {
    echo "Host server1" > "$BASE_CONFIG"
    echo "  HostName example.com" >> "$BASE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    assert_equal "$(head -n 1 "$BASE_CONFIG")" "Include ${INCLUDE_CONFIG}"
}

# bats test_tags=_sshcfg_store_ensure_include_directive,critical
@test "_sshcfg_store_ensure_include_directive: preserves existing content" {
    echo "Host server1" > "$BASE_CONFIG"
    echo "  HostName example.com" >> "$BASE_CONFIG"
    local original_content=$(cat "$BASE_CONFIG")

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    run grep -q "Host server1" "$BASE_CONFIG"
    assert_success
    run grep -q "HostName example.com" "$BASE_CONFIG"
    assert_success
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: returns success when Include already exists" {
    echo "Include ${INCLUDE_CONFIG}" > "$BASE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
}

# bats test_tags=_sshcfg_store_ensure_include_directive,critical
@test "_sshcfg_store_ensure_include_directive: creates base config if it doesn't exist" {
    assert_file_not_exists "$BASE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    assert_file_exists "$BASE_CONFIG"
}

# bats test_tags=_sshcfg_store_ensure_include_directive,critical
@test "_sshcfg_store_ensure_include_directive: creates include config if it doesn't exist" {
    touch "$BASE_CONFIG"
    assert_file_not_exists "$INCLUDE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    assert_file_exists "$INCLUDE_CONFIG"
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: creates both files if neither exist" {
    assert_file_not_exists "$BASE_CONFIG"
    assert_file_not_exists "$INCLUDE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    assert_file_exists "$BASE_CONFIG"
    assert_file_exists "$INCLUDE_CONFIG"
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: adds blank line after Include directive" {
    touch "$BASE_CONFIG"
    touch "$INCLUDE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    assert_equal "$(sed -n '2p' "$BASE_CONFIG")" ""
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: preserves multiple existing hosts" {
    cat > "$BASE_CONFIG" << 'CONF'
Host server1
    HostName example1.com

Host server2
    HostName example2.com

Host server3
    HostName example3.com
CONF
    local original_hosts=$(grep -c "^Host" "$BASE_CONFIG")

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    local new_hosts=$(grep -c "^Host" "$BASE_CONFIG")
    assert_equal "$original_hosts" "$new_hosts"
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: preserves comments and formatting" {
    cat > "$BASE_CONFIG" << 'CONF'
# This is a comment
Host server1
    HostName example.com  # inline comment
CONF

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    run grep -q "# This is a comment" "$BASE_CONFIG"
    assert_success
    run grep -q "# inline comment" "$BASE_CONFIG"
    assert_success
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: preserves blank lines" {
    cat > "$BASE_CONFIG" << 'CONF'
Host server1
    HostName example.com


Host server2
    HostName example2.com
CONF
    local original_lines=$(wc -l < "$BASE_CONFIG")

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    local new_lines=$(wc -l < "$BASE_CONFIG")
    local expected_lines=$((original_lines + 2))
    assert_equal "$new_lines" "$expected_lines"
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: handles path with spaces" {
    local path_with_spaces="${TEST_DIR}/path with spaces/config"

    run _sshcfg_store_ensure_include_directive "$path_with_spaces" "$BASE_CONFIG"

    assert_success
    run grep -Fq "Include ${path_with_spaces}" "$BASE_CONFIG"
    assert_success
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: handles path with tilde" {
    local tilde_path="~/test_ssh/config"
    touch "$BASE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$tilde_path" "$BASE_CONFIG"

    assert_success
    run grep -Fq "Include ${tilde_path}" "$BASE_CONFIG"
    assert_success
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: distinguishes similar paths" {
    local include1="${TEST_DIR}/config"
    local include2="${TEST_DIR}/config2"
    touch "$BASE_CONFIG"
    touch "$include1"
    touch "$include2"

    run _sshcfg_store_ensure_include_directive "$include1" "$BASE_CONFIG"
    assert_success

    run _sshcfg_store_ensure_include_directive "$include2" "$BASE_CONFIG"
    assert_success

    run grep -Fq "Include ${include1}" "$BASE_CONFIG"
    assert_success
    run grep -Fq "Include ${include2}" "$BASE_CONFIG"
    assert_success
    local include_count=$(grep -c "^Include" "$BASE_CONFIG")
    assert_equal "$include_count" "2"
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: handles moderately large base config" {
    touch "$INCLUDE_CONFIG"
    for i in {1..50}; do
        echo "Host server${i}" >> "$BASE_CONFIG"
        echo "  HostName example${i}.com" >> "$BASE_CONFIG"
    done

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    assert_equal "$(head -n 1 "$BASE_CONFIG")" "Include ${INCLUDE_CONFIG}"
    local host_count=$(grep -c "^Host" "$BASE_CONFIG")
    assert_equal "$host_count" "50"
}

# bats test_tags=_sshcfg_store_ensure_include_directive
@test "_sshcfg_store_ensure_include_directive: atomic file update (uses temp file)" {
    echo "original content" > "$BASE_CONFIG"
    touch "$INCLUDE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$INCLUDE_CONFIG" "$BASE_CONFIG"

    assert_success
    assert_file_not_exists "${BASE_CONFIG}.tmp"
}

# bats test_tags=_sshcfg_store_ensure_include_directive,critical
@test "_sshcfg_store_ensure_include_directive: recognizes both absolute and tilde paths" {
    local abs_config_path="${HOME}/.ssh/test_config"
    local tilde_config_path="~/.ssh/test_config"
    touch "$BASE_CONFIG"
    echo "Include ${abs_config}" > "$BASE_CONFIG"

    run _sshcfg_store_ensure_include_directive "$abs_config" "$BASE_CONFIG"

    assert_success
    local include_count=$(grep -c "^Include" "$BASE_CONFIG")
    assert_equal "$include_count" "1"

    run _sshcfg_store_ensure_include_directive "$tilde_config_path" "$BASE_CONFIG"

    assert_success
    local include_count=$(grep -c "test_config" "$BASE_CONFIG")
    assert_equal "$include_count" "1"
}
