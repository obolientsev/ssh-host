# ❯❯ ssh-host 
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![zsh](https://img.shields.io/badge/zsh-%3E%3D5.0-orange.svg)](https://www.zsh.org/)
![Interactive demo](demo.gif)

A zsh plugin for securely managing SSH hosts with an interactive fzf interface.

## Features

- **Interactive Management**: Browse and connect to SSH hosts with fzf-powered fuzzy search and live previews
- **Secure Key Creation**: Generate ed25519 or RSA-4096 keys with automatic SSH agent integration
- **Host Organization**: Pin frequently-used hosts and add descriptions for quick identification
- **Non-Invasive**: Separate SSH config file with automatic backups
- **Minimal Dependencies**: Uses native SSH tools for maximum compatibility

## Requirements

- `zsh` >= 5.0
- `fzf` - Fuzzy finder for interactive selection

## Installation

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

## Quick Start

<details>
<summary>1. Install fzf:</summary>

```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt install fzf

# Arch Linux
sudo pacman -S fzf
```
</details>

2. Launch the plugin:
```bash
ssh-host
```

3. Follow the instructions to add your first host.


### Key Bindings

| Key       | Action                               |
|-----------|--------------------------------------|
| `↑/↓`    | Navigate hosts                        |
| `Enter`  | Connect to selected host              |
| `Ctrl-N` | Add new host                          |
| `Ctrl-E` | Edit selected host description        |
| `Ctrl-P` | Toggle `pin` status of selected host  |
| `Esc`    | Quit                                  |

---

**Note**: This plugin manages SSH configurations in a separate file to avoid conflicts with your existing setup. All generated keys are stored in `~/.ssh/ssh_host/keys/`.