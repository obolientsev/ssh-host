# Base fzf configuration with common settings
# echo "option1\noption2" | _ssh_host_fzf_base --prompt="Select: " --multi
# => Opens fzf with standard layout, colors, and additional options
_ssh_host_fzf_base() {
    fzf \
        --height=100% \
        --layout=reverse \
        --border \
        --ansi \
        --bind="esc:abort" \
        "$@"
}

# Interactive input using fzf with predefined options and validation
# _ssh_host_fzf_input "Enter port: " "22\n2222\n8080" "_validate_port"
# => "22" (user selected or typed valid value)
# => Shows validation errors in header and re-prompts until valid
# => Returns 1 if user cancels with Esc
_ssh_host_fzf_input() {
    local prompt="$1" options="$2" validator="$3"
    local result current_error=""

    while true; do

        result=$(echo -e "$options" | \
            _ssh_host_fzf_base  --prompt="$prompt" \
                                --header="$current_error" \
                                --print-query \
                                --height=12 )

        [[ $? -eq 130 ]] && return 1

        result=$(_ssh_host_sanitize_fzf_result "$result")

        [[ -n "$validator" ]] && { validation_output=$("$validator" "$result" 2>&1)
                    [[ $? -eq 0 ]] || { current_error=$(_ssh_host_format_error "$validation_output"); continue; } }

        echo "$result"
        return 0
    done
}

# Cleans fzf output by removing descriptions and extra lines
# _ssh_host_sanitize_fzf_result "ubuntu - Default user\nubuntu"
# => "ubuntu"
# _ssh_host_sanitize_fzf_result "custom_input\n"
# => "custom_input"
_ssh_host_sanitize_fzf_result() {
    local input="$1"
    input="${input%% - *}"
    input="${input#$'\n'}"
    input="${input%%$'\n'*}"
    echo "$input"
}

# Formats validation error message for fzf header display
# _ssh_host_format_error "Port must be between 1-65535"
# => "Validation error:"
# => " → Port must be between 1-65535"
_ssh_host_format_error() {
  local msg="$1"
  printf "${SSH_HOST_COLOR_RED}Validation error:${SSH_HOST_COLOR_NC}\n"
  awk '{print " → " $0}' <<< "$msg"
}
