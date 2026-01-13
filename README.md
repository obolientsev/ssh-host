# ❯❯ ssh-host 

[![Build Status](https://github.com/obolientsev/ssh-host/actions/workflows/ci.yml/badge.svg)](https://github.com/obolientsev/ssh-host/actions/workflows/ci.yml)
[![zsh](https://img.shields.io/badge/zsh-%3E%3D5.0-orange.svg)](https://www.zsh.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Zsh plugin to simplify interaction with SSH config, ssh, scp.

## Table of Contents

- [Key Features](#key-features)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Key Bindings](#key-bindings)
- [Troubleshooting](#troubleshooting)

## Key Features

|  |  |
|---------|------|
| **Interactive Host Selection**<br>Browse hosts from .ssh/config with fuzzy search and live preview of connection details, port, key, and descriptions. Filter and navigate with keyboard. | ![Host Selection](demo/select.gif) |
| **Quick Host Setup**<br>Add new hosts through guided setup. Plugin automatically manages SSH config with Include directive, keeping your main config clean. Supports ed25519 and RSA-4096 key generation with SSH agent integration. | ![Add Host](demo/add.gif) |
| **SCP Support**<br>Upload files/directories with `ctrl-u`, download with `ctrl-d`. Auto-detects recursive transfers for directories. | ![SCP Support](demo/scp.gif) |
| **Pin**<br>Press `ctrl-p` to pin frequently-used hosts to the top of your list. Quick access to servers or most used environments. | ![Pin Host](demo/pin.gif) |
| **Custom Descriptions**<br>Press `ctrl-e` to add descriptions to hosts. Document server purpose, environment (prod/staging/dev), or notes. | ![Edit Description](demo/edit.gif) |


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
| `Ctrl-U` | Upload file to selected host          |
| `Ctrl-D` | Download file from selected host      |
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
