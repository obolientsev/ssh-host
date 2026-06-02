# ❯❯ ssh-host 

[![Build Status](https://github.com/obolientsev/ssh-host/actions/workflows/ci.yml/badge.svg)](https://github.com/obolientsev/ssh-host/actions/workflows/ci.yml)
[![zsh](https://img.shields.io/badge/zsh-%3E%3D5.0-orange.svg)](https://www.zsh.org/)
[![zsh](https://img.shields.io/badge/Awesome-zsh--plugins-d07cd0?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABVklEQVRIS+3VvWpVURDF8d9CRAJapBAfwWCt+FEJthIUUcEm2NgIYiOxsrCwULCwktjYKSgYLfQF1JjCNvoMNhYRCwOO7HAiVw055yoBizvN3nBmrf8+M7PZsc2RbfY3AfRWeNMSVdUlHEzS1t6oqvt4n+TB78l/AKpqHrdwLcndXndU1WXcw50k10c1PwFV1fa3cQVzSR4PMd/IqaoLeIj2N1eTfG/f1gFVtQMLOI+zSV6NYz4COYFneIGLSdZSVbvwCMdxMsnbvzEfgRzCSyzjXAO8xlHcxMq/mI9oD+AGlhqgxjD93OVOD9TUuICdXd++/VeAVewecKKv2NPlfcHUAM1qK9FTnBmQvJjkdDfWzzE7QPOkAfZiEce2ECzhVJJPHWAfGuTwFpo365pO0NYjmEFr5Eas4SPeJfll2rqb38Z7/yaaD+0eNM3kPejt86REvSX6AamgdXkgoxLxAAAAAElFTkSuQmCC)](https://github.com/unixorn/awesome-zsh-plugins)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

zsh plugin that cuts ssh and scp boilerplate
<div><img src="demo/select.gif" width="49%"> <img src="demo/add.gif" width="49%"></div>

## Table of Contents

- [Key Features](#key-features)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Key Bindings](#key-bindings)
- [Tips](#tips)
- [Troubleshooting](#troubleshooting)

## Key Features

<details>
<summary><b>Interactive Host Selection</b></summary>

Browse hosts from .ssh/config with fuzzy search and live preview of connection details, port, key, and descriptions.
Filter and navigate with keyboard.
![Host Selection](demo/select.gif)
</details>

<details>
<summary><b>Quick Host Setup</b></summary>

Press `Ctrl+N` to add new hosts through guided setup. Behind the scenes the plugin:
- Generates an ed25519/RSA-4096 key (or skips key generation for password-based auth)
- Backs up existing SSH config and keys before any changes
- Appends the host to a ssh config file via `Include` directive, leaving your main config untouched
- Adds key to SSH agent
- Deploys the public key to the server via `ssh-copy-id`

![Add Host](demo/add.gif)
</details>

<details>
<summary><b>SCP Support</b></summary>

Upload files/directories with `Ctrl+U`, download with `Ctrl+D`. Auto-detects recursive transfers for directories.
![SCP Support](demo/scp.gif)
</details>

<details>
<summary><b>Pin</b></summary>

Press `Ctrl+P` to pin frequently-used hosts to the top of your list. Quick access to servers or most used environments.
![Pin Host](demo/pin.gif)
</details>

<details>
<summary><b>Custom Descriptions</b></summary>

Press `Ctrl+E` to add descriptions to hosts. Document server purpose, environment (prod/staging/dev), or notes.
![Edit Description](demo/edit.gif)
</details>


## Requirements

- [`zsh` >= 5.0](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
- [`fzf` - Fuzzy finder for interactive selection](https://github.com/junegunn/fzf)

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

## Tips

<details>
<summary><b>Adding a new SSH key to your GitHub account</b></summary>

To configure your account on GitHub.com you need add an SSH key to your GitHub account.
To generate new SSH key and configure it correctly follow these steps:

![Edit Description](demo/add-git.gif)

1. Open `ssh-host` → press `Ctrl-N`
2. Fill in the wizard:
   - Alias: `github`
   - Hostname: `github.com`
   - User: `git`
   - Port: `22`
   - Key type: `ed25519`
3. Confirm setup
4. Copy `Public key` from response:
```terminaloutput
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgiKN9FQcPgCUuA81PSn28ThZQANY0v4pvMTfjZo8Ka github@demo
```
5. Paste into [GitHub Settings → SSH keys](https://github.com/settings/keys)

> For more details [GitHub docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

</details>

<details>
<summary><b>Multiple GitHub accounts (personal + work)</b></summary>

Useful if you contribute to repos with a personal account but push to work repos under a different account.
SSH doesn't support multiple identities for the same hostname out of the box — aliases solve this.

1. Add SSH key (see tip above) for personal account with alias `github-personal`
2. Add SSH key (see tip above) for work account with alias `github-work`
3. Copy each pubkey to the corresponding GitHub account's [SSH keys](https://github.com/settings/keys)
4. Use the alias in git remotes instead of `github.com`:
   ```bash
   # in work project
   git remote set-url origin github-work:org/work_repo.git
   # in personal project
   git remote set-url origin github-personal:username/repo.git
   ```

</details>

<details>
<summary><b>Multi-alias Host entries</b></summary>

If you use multi-alias Host blocks in your SSH config, the plugin shows each alias as a separate entry:
```
Host production prod p
    HostName example.com
    User ubuntu
```
All three — `production`, `prod`, `p` — appear in the list by default.

To show only the first alias per block, add to your `~/.zshrc`:
```bash
export SSH_HOST_SHOW_ALL_SUB_ALIAS=false
```

</details>

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
