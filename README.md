# ❯❯ ssh-host 

[![Build Status](https://github.com/obolientsev/ssh-host/actions/workflows/ci.yml/badge.svg)](https://github.com/obolientsev/ssh-host/actions/workflows/ci.yml)
[![zsh](https://img.shields.io/badge/zsh-%3E%3D5.0-orange.svg)](https://www.zsh.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Zsh plugin to simplify interaction with SSH config. **Browse/search/connect** to configured hosts. **Securely add** new configs. **Pin/describe** entries for better navigation.

![Interactive demo](demo.gif)

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Key Bindings](#key-bindings)
- [Troubleshooting](#troubleshooting)

## Features

- **Interactive Management**: Browse and connect to configured hosts with fzf-powered fuzzy search and live previews
- **Secure Key Creation**: Generate ed25519 or RSA-4096 keys with automatic SSH agent integration
- **Host Organization**: Pin frequently-used hosts and add descriptions for quick identification
- **Non-Invasive**: Separate SSH config file with automatic backups
- **Minimal Dependencies**: Uses native SSH tools for maximum compatibility

## Requirements

- `zsh` >= 5.0
- `fzf` - Fuzzy finder for interactive selection

## Getting Started

1. [Install fzf](https://github.com/junegunn/fzf)

2. Install `ssh-host`:

    <details>
    <summary>Zinit / Antigen / Znap</summary>

    Add to your `~/.zshrc`:
    ```bash
    zinit load "obolientsev/ssh-host"
    # or
    antigen bundle obolientsev/ssh-host
    # or
    znap source "obolientsev/ssh-host"
    ```
    </details>

    or

    <details>
    <summary><b>Oh My Zsh</b></summary>

    1. Clone the repository:
    ```bash
    git clone https://github.com/obolientsev/ssh-host ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ssh-host
    ```

    2. Add to your plugins list in `~/.zshrc`:
    ```bash
    plugins=(ssh-host $plugins)
    ```

    3. Restart your shell:
    ```bash
    source ~/.zshrc
    ```
    </details>


3. Launch the plugin:
    ```bash
    ssh-host
    ```

4. Follow the instructions to add your first host.


### Key Bindings

| Key       | Action                               |
|-----------|--------------------------------------|
| `↑/↓`    | Navigate hosts                        |
| `Enter`  | Connect to selected host              |
| `Ctrl-N` | Add new host                          |
| `Ctrl-E` | Edit selected host description        |
| `Ctrl-P` | Toggle `pin` status of selected host  |
| `Esc`    | Quit                                  |

## Troubleshooting

<details>
<summary><b>Too many authentication failures</b></summary>

**Issue**: SSH server rejects connection after trying too many keys. Happens when ssh-agent has multiple keys loaded and SSH tries them all before the correct one, exceeding server's `MaxAuthTries` limit (typically 6 attempts).

**Fix**: Add `IdentitiesOnly yes` to force SSH to use only specified keys, not all agent keys.

**Update config**:
```
Host problematic-host
    HostName example.com
    User myuser
    IdentityFile ...
    IdentitiesOnly yes  # Add this line
```

**Prevent globally**: Add to `~/.ssh/config` top:
```
Host *
    IdentitiesOnly yes
```

</details>

---

> [!Note]
> This plugin manages SSH configurations in a separate file to avoid conflicts with your existing setup. All generated keys are stored in `~/.ssh/ssh_host/keys/`.
