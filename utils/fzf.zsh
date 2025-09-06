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

# Interactive input using fzf with predefined options
# _ssh_host_fzf_input "Enter port: " "22\n2222\n8080"
# => "22" (user selected or typed custom value)
# => Returns 1 if user cancels with Esc
_ssh_host_fzf_input() {
    local prompt="$1" options="$2"
    local result

    while true; do

        result=$(echo -e "$options" | \
            _ssh_host_fzf_base  --prompt="$prompt" \
                                --header="" \
                                --print-query \
                                --height=12 )

        [[ $? -eq 130 ]] && return 1

        result=$(_ssh_host_sanitize_fzf_result "$result")

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
