# Dotfiles

These dotfiles configure the shell, the terminals, the editors and Git on macOS. They also work on Linux with small changes.

They are based on these sources, and others:

- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [Paul Irish](https://github.com/paulirish/dotfiles)
- [dotfiles](https://dotfiles.github.io)
- [Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/)

> **CAUTION:** These settings change your shell, your editors and your Git configuration. Do not use them before you read them. Fork this repository first. Then read the code and remove the settings that you do not need.

## Automated macOS setup

The [Mac Development Ansible Playbook](https://github.com/greylabel/mac-dev-playbook) configures macOS and installs applications, including the Homebrew packages. The playbook also installs and updates these dotfiles.

Use the playbook to set up a new Mac fully. Use the instructions in this file to install only the dotfiles.

## Install from this repository

The bootstrap script makes symbolic links from your home directory to the files in this repository. Because the files are links, a change in the repository has an immediate effect. When a tool changes one of its files, for example `lazy-lock.json`, the change goes into the repository.

To install the dotfiles:

1. Install the [prerequisites](#prerequisites).
2. Clone the repository:

   ```bash
   git clone git@github.com:greylabel/dotfiles.git
   ```

3. Go into the repository:

   ```bash
   cd dotfiles
   ```

4. Run the bootstrap script:

   ```bash
   ./bootstrap.sh
   ```

5. Type `y` to confirm.

If a file is already where the script puts a link, the script moves that file to `~/.dotfiles-backup/<timestamp>/`.

To update the dotfiles:

1. Go into the repository.
2. Run `./bootstrap.sh`.
3. If the remote repository has new commits, the script shows them with their signature status. `G` is a good signature. `N` is no signature. Type `y` to get the commits before the script makes the links.

Also run the script after you add a file to the repository. To skip the questions, run `./bootstrap.sh -f`. With `-f`, the script also gets the new commits without a question.

### Layout

The bootstrap script links each dotfile in the root of the repository into your home directory. Examples are `.bash_profile`, `.aliases`, `.inputrc` and `.editorconfig`.

The script links each directory in `config/` into `~/.config/`:

| Directory | Tool | Notes |
| --- | --- | --- |
| `config/ghostty` | [Ghostty](https://ghostty.org/docs/config/reference) terminal | |
| `config/herdr` | [herdr](https://herdr.dev/docs/configuration/) agent workspace | The script links only `config.toml`, because herdr keeps runtime files in the same directory. |
| `config/tmux` | tmux | tmux 3.1 and later read `~/.config/tmux/tmux.conf`. The Tokyo Night colors need tmux 3.6 or later. Older versions use the default tmux colors. |
| `config/nvim` | Neovim | Uses lazy.nvim, Mason and nvim-treesitter. |
| `config/vim` | Vim | Vim 9.1 and later read `~/.config/vim/vimrc`. |
| `config/git` | Git | Shared settings and the global ignore file. The script also makes `~/.gitconfig` as a separate file outside the repository. `git config --global` writes to that file, not to this public repository. |
| `config/curl`, `config/wget` | curl and wget | Research profiles. Use them only through the `rcurl` and `rwget` aliases. Plain `curl` and `wget` keep their default settings. |

To add a tool, add a `config/<tool>/` directory. You do not have to change the bootstrap script.

Some tools do not read `~/.config`. These tools have a directory in the root of the repository, and the script links their files where the tool looks for them. For example, on macOS with iTerm2 installed, the script links `iterm2/dotfiles.json` as an iTerm2 Dynamic Profile.

### Prerequisites

Install Homebrew first. See [Homebrew](#homebrew).

Install these tools on macOS:

```bash
xcode-select --install          # Git, make and a C compiler. Neovim uses them to build parsers and plugins.
brew install bash bash-completion@2 git neovim tmux ripgrep fd tree-sitter-cli git-delta
brew install --cask font-fira-code font-symbols-only-nerd-font
brew install --cask ghostty     # Or iterm2, or both.
```

Also install these items:

- **Node.js and Python 3.** Neovim uses them for language servers and formatters. See [Neovim tools](#neovim-tools).
- **herdr,** if you use it in place of tmux or together with tmux. Install it from [herdr.dev](https://herdr.dev/).
- **Homebrew bash as your login shell.** See [Bash from Homebrew](#bash-from-homebrew). The bash 3.2 that macOS supplies does not have some options that these files use.

These tools are optional. Some aliases and functions need them:

| Install | Necessary for |
| --- | --- |
| `brew install --cask 1password-cli` | The 1Password shell plugins and the `~/.config/op-run` wrappers. See [Private files and secrets](#private-files-and-secrets). |
| `brew install tree wget pigz` | The `tre` function, the `rwget` alias, and a faster `targz` function. |
| `brew install uv pnpm pyenv` | Python and JavaScript tools. The shell configures them if they are installed. |
| [TPM](#tmux-plugins-tpm) | tmux plugins. |

The minimum versions are:

- Neovim 0.12
- Vim 9.1
- tmux 3.1. The Tokyo Night colors need tmux 3.6.
- Git 2.37
- bash 4. The bash 3.2 from macOS also works, but without the `autocd` and `globstar` options.

On Linux, install the same tools with your package manager. For `make` and a C compiler, install `build-essential` or an equivalent package. For the `open` command, install `xdg-utils`. Linux distributions often supply a Neovim version that is older than 0.12. Use the [official Neovim release](https://github.com/neovim/neovim/releases) in its place. If `git-delta` is not installed, Git uses `less` to show its output.

### Neovim tools

When Neovim starts for the first time, lazy.nvim installs the plugins and Mason installs the language servers and formatters. To see the progress, use the `:Lazy` and `:Mason` commands. These installers need the tools in this table on your `PATH`:

| Tool on `PATH` | Necessary for |
| --- | --- |
| `git` | lazy.nvim, to get the plugins. |
| `make` and a C compiler | telescope-fzf-native. |
| `tree-sitter` CLI and a C compiler | nvim-treesitter, to build the parsers. |
| `node` and `npm` | Mason: vtsls, eslint, jsonls, yamlls, bashls, dockerls and prettierd. |
| `python3`, with `venv` and `pip` | Mason: basedpyright and sqlfluff. |
| `curl`, `unzip`, `tar` and `gzip` | Mason: lua_ls, ruff, taplo, stylua and shfmt. Mason downloads these as prebuilt binaries. macOS includes these four tools. |
| `rg` and `fd` | Telescope search. |

To install Node.js with [nvm](https://github.com/nvm-sh/nvm):

1. Install nvm. `PROFILE=/dev/null` stops the installer from editing your shell files. `.bash_profile` already loads nvm.

   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | PROFILE=/dev/null bash
   ```

2. Install the current long-term support (LTS) version of Node.js:

   ```bash
   nvm install --lts
   ```

3. Make this version the default version:

   ```bash
   nvm alias default 'lts/*'
   ```

> **NOTE:** `.bash_profile` adds only the default nvm version to `PATH`. Neovim finds Node.js only if you set a default version and start Neovim from a login shell.

To install Python 3, use one of these methods:

- With pyenv: run `pyenv install 3.12`, then run `pyenv global 3.12`.
- With Homebrew: run `brew install python`.

To check the setup, run `:checkhealth lazy mason` in Neovim. Mason also checks languages that this configuration does not use. You can ignore the warnings for luarocks, Java, Julia, Ruby, Go, cargo, PHP and Composer.

### Installers that edit shell files

`~/.bashrc` and `~/.bash_profile` are links to files in this repository. Thus, an installer that adds lines to these files changes the repository.

`.bash_profile` already configures nvm, pnpm, pyenv and `~/.local/bin`. Do not let installers add lines for these tools. Use the options in this table:

| Tool | How to install without changes to the shell files |
| --- | --- |
| nvm | Run the installer with `PROFILE=/dev/null`, as in [Neovim tools](#neovim-tools). |
| pnpm | Run `brew install pnpm`. Do not run `pnpm setup`. |
| uv | Run `brew install uv`. If you use the install script, set `UV_NO_MODIFY_PATH=1`. |
| rustup | Run `rustup-init --no-modify-path`. |

Homebrew does not edit shell files. If an installer has no option to stop the changes, do these steps after you install:

1. In this repository, run `git diff` to see the changes.
2. Move the lines that you need to `~/.extra`. Git does not track this file.
3. Run `git checkout -- <file>` to remove the changes from the file in the repository.

Install pnpm with Homebrew, not with Corepack. There are two reasons:

- nvm keeps global packages separately for each Node.js version. Thus, the Corepack version of pnpm disappears when you upgrade Node.js.
- Node.js 25 and later do not include Corepack.

A project can still set its pnpm version with the `packageManager` field in `package.json`.

### Theme and shared keys

All the tools use the Tokyo Night theme: Storm in dark mode and Day in light mode. This applies to Ghostty, iTerm2, herdr, tmux and Neovim. The terminal follows the macOS appearance setting. The other tools follow the terminal.

herdr and tmux use the same keys. Neovim and Vim also use the same keys:

| Keys | herdr and tmux | Neovim and Vim |
| --- | --- | --- |
| `Ctrl+A` | The prefix key. | |
| Prefix, then `h`, `j`, `k` or `l` | Move the focus to a different pane. | |
| Prefix, then `H`, `J`, `K` or `L` | Change the size of the pane. | |
| Prefix, then `\|` or `-` | Split the pane side by side or one above the other. | |
| Prefix, then `Ctrl+L` | Clear the pane and its scrollback. | |
| `Ctrl+H`, `Ctrl+J`, `Ctrl+K` or `Ctrl+L` | | Move to a different window. |
| `Space`, then `w`, `q`, `v`, `s` or `e` | | Write, quit, split vertically, split horizontally, or open the file tree. |
| `Space`, then `f`, `g`, `c`, `x`, `u` or `a` | | Neovim only: groups of keys to find, use Git, work with code, show diagnostics, toggle settings, and connect to an agent. which-key shows all the keys in a group. |

### Terminals

You can use any combination of these tools: Ghostty or iTerm2, herdr or tmux, and Neovim or Vim. Each tool uses only standard terminal features, not the special features of one terminal:

- **Keys.** All the shortcuts use standard terminal keys: the prefix, `Ctrl` and `Space`. No shortcut uses `Cmd`. In both terminals, the left Option key is Alt (Meta), so the Alt shortcuts in the shell and in Neovim are the same. The right Option key types special characters.
- **Colors.** All the tools use true color. Each terminal sets its own `TERM` value: `xterm-ghostty`, `xterm-256color` or `tmux-256color`. No file overrides `TERM`.
- **Light and dark mode.** The terminal changes its palette when macOS changes its appearance. tmux and Neovim get the background color from the terminal. herdr gets the setting from macOS directly.
- **Clipboard.** The tools use OSC 52 for the clipboard. Thus, tmux copy mode, herdr and Neovim can copy to the macOS clipboard through any terminal that permits it. This also works over SSH.
- **Icons.** The icons in Neovim need the Nerd Font symbols. Ghostty includes these symbols. The iTerm2 profile sets them as the font for non-ASCII characters.

The two terminals are different in these ways:

| | Ghostty | iTerm2 |
| --- | --- | --- |
| Configuration | `config/ghostty` | `iterm2/dotfiles.json`, which adds the profile "Dotfiles". Make it the default profile in **Settings → Profiles**. |
| Source of the palette | The themes that the `theme =` line names. Ghostty includes these themes. | `iterm2/generate.py` makes the palette from the same Ghostty themes. |
| Light and dark palette | `theme = dark:…,light:…` | The profile has separate colors for light mode and dark mode. |
| Clipboard (OSC 52) | Permitted by default. | Enable **Settings → General → Selection → Applications in terminal may access clipboard**. |
| Select text in the terminal while tmux or herdr is open | Hold `Shift` while you drag. | Hold `Option` while you drag. |
| Copy a herdr selection | `Cmd+C` or `Ctrl+C` | `Ctrl+C` |

The colors in both terminals come from [iTerm2-Color-Schemes](https://iterm2colorschemes.com/). Ghostty includes these color schemes as its themes. Select the theme only on the `theme =` line in the Ghostty configuration. After you change this line or update Ghostty, run `python3 iterm2/generate.py`. This script makes the iTerm2 profile again with the same palettes. The profile also uses the same font and line height as Ghostty.

Neovim gets its colors from tokyonight.nvim. Some ANSI colors in tokyonight.nvim are slightly different from the colors in the terminal palette.

To add a different terminal, configure it with these settings:

- The Tokyo Night Storm and Day themes.
- The Fira Code font, with the Nerd Font symbols.
- The left Option key as Alt.
- Access to the clipboard through OSC 52.

### tmux plugins (TPM)

The tmux configuration loads the [TPM](https://github.com/tmux-plugins/tpm) plugin manager if it is installed. To install TPM and the plugins:

1. Clone TPM:

   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
   ```

2. Start tmux.
3. Press `Ctrl+A`, then press `I`.

### Work with AI agents

- **Files that change outside the editor.** Neovim and Vim load a file again when a different program changes it. An example is an agent in a different pane. They do this when they get the focus again. tmux sends the focus events that make this work.
- **Review changes.** To see all the changes in the working tree, press `Space g d` in Neovim. This opens diffview.
- **Stage or reset changes.** To stage a hunk, press `Space g s`. To reset a hunk, press `Space g r`. In visual mode, these keys stage or reset only the selected lines.
- **Claude Code bridge (optional).** Neovim can show the edits from Claude Code as diffs:
  1. In Neovim, press `Space a c`.
  2. In a `claude` session, run `/ide`.
  3. To accept a diff, press `Space a a`. To reject a diff, press `Space a d`.

  The bridge does not run until you use a `Space a` key. To remove the bridge, delete `config/nvim/lua/plugins/agent.lua`.

## Extend and override

### Add directories to `PATH`

If `~/.path` exists, `.bash_profile` loads it before the other files. Thus, the directories that you add are available when the other files look for tools. For example, `.aliases` looks for the installed version of `ls`.

### Add custom commands

If `~/.extra` exists, `.bash_profile` loads it after the other files. Use this file for commands that you do not want in a public repository.

You can also use `~/.extra` to override settings, functions and aliases from these dotfiles. For larger changes, [fork this repository](https://github.com/greylabel/dotfiles/fork).

### Private files and secrets

Git does not track `~/.extra`, `~/.path` and `~/.gitconfig.local`. Each time the bootstrap script runs, it sets these files to `chmod 600`. Thus, only your user can read them.

> **CAUTION:** `.bash_profile` loads `~/.extra` into every shell, including the shells where AI agents run commands. Do not export secret values from `~/.extra`.

Keep secrets in 1Password. Each command gets its secrets from 1Password only when it runs:

- **Tools with a [1Password shell plugin](https://developer.1password.com/docs/cli/shell-plugins/),** for example `gh`, `aws` and `terraform`. Run `op plugin init <tool>`. 1Password writes `~/.config/op/plugins.sh`, and `.bash_profile` loads this file.
- **All other tools.** Make the file `~/.config/op-run/<command>.env`. In this file, write one [secret reference](https://developer.1password.com/docs/cli/secret-references/) on each line, in the format `VARIABLE=op://vault/item/field`. `.functions` then wraps `<command>`, so that each time the command runs, it gets these variables from 1Password for that run only.

To get a secret reference, right-click a field in 1Password and select **Copy Secret Reference**. The `.env` files contain references, not secrets. They are not in the repository.

Only human shells load the shell plugins and the wrappers. Agent shells do not load them.

### Human and agent shells

The shells where AI agents run commands get plain commands with predictable output. `.bash_profile` identifies an agent shell in two ways:

- The shell is not interactive.
- One of these variables is set: `CLAUDECODE` (Claude Code), `AI_AGENT`, `CODEX_SANDBOX` (Codex) or `GEMINI_CLI`.

For a different agent, set `DOTFILES_AGENT=1` in the environment of that agent.

Agent shells do not get these items:

- The aliases for `rm -i`, `cp -v`, `mv -v`, `mkdir -p`, `df -h` and `du -h`, and the alias that runs `git diff` in place of `diff`.
- `man` in Neovim. Agents get `less`, which does not wait for a terminal.
- The shell options `nocaseglob`, `cdspell`, `autocd` and `globstar`.
- The 1Password shell plugins and the `~/.config/op-run` wrappers.

An agent session keeps the shell environment that it had when it started. After you change these files, start the agent session again.

### Formatting and checks

All files use spaces for indentation, as `.editorconfig` specifies. The indentation is 2 spaces, or 4 spaces for Python. Only Makefiles and Go files use tabs, because their tools need tabs.

Neovim formats a file when you save it. CI checks the same formatting with the same tool versions:

| Files | Formatter or linter | CI workflow |
| --- | --- | --- |
| `config/nvim/**/*.lua` | StyLua, with `config/nvim/.stylua.toml` | `stylua.yml` |
| `bootstrap.sh`, `.bash_profile`, `.bashrc`, `.bash_prompt`, `.aliases`, `.exports` and `.functions` | shfmt, with the indentation from `.editorconfig` | `shfmt.yml` |
| The same shell files | ShellCheck, with `.shellcheckrc` | `shellcheck.yml` |

Keep the tool versions in CI the same as the versions in Mason. Mason installs the newest StyLua and shfmt one time. After that, Mason updates them only when you tell it to: open `:Mason`, then press `U`.

After you update StyLua or shfmt in Mason, do these steps:

1. Get the version that Mason installed:

   ```bash
   ~/.local/share/nvim/mason/bin/stylua --version
   ~/.local/share/nvim/mason/bin/shfmt --version
   ```

2. For StyLua, set `version` in `.github/workflows/stylua.yml` to the same version.
3. For shfmt, set `SHFMT_VERSION` in `.github/workflows/shfmt.yml` to the same version.
4. For shfmt, also set `SHFMT_SHA256` in the same file. To get the checksum, use this command with the new version:

   ```bash
   v=v3.14.1
   curl -fsSL "https://github.com/mvdan/sh/releases/download/$v/shfmt_${v}_linux_amd64" | shasum -a 256
   ```

CI does not check `.macos`.

## Additional configuration

### Git

Make a `~/.gitconfig.local` file for your name, your email address and your signing key. `~/.config/git/config` includes this file. Do not put tokens in this file. The GitHub CLI gets its credentials from 1Password.

```ini
[user]

  name = <Your Name>
  email = <you@example.com>
  signingkey = ~/.ssh/id_ed25519.pub

[github]

  user = ghusername
```

### SSH

#### Make a new SSH key pair

> **NOTE:** For more information, see the GitHub guide [Generating a new SSH key and adding it to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/).

1. Make the directory for SSH keys and SSH configuration. Only your user can use this directory:

   ```bash
   mkdir ~/.ssh && chmod 0700 ~/.ssh
   ```

2. Make a new SSH key:

   ```bash
   ssh-keygen -t ed25519
   ```

3. Set the permissions of the key files:

   ```bash
   chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub
   ```

#### Configure SSH

1. Make the `~/.ssh/config` file. Only your user can read and write it:

   ```bash
   touch ~/.ssh/config && chmod 600 ~/.ssh/config
   ```

2. Add these lines to `~/.ssh/config`. They load keys into the ssh-agent automatically, and they keep passphrases in the macOS keychain.

   ```text
   IgnoreUnknown AddKeysToAgent,UseKeychain

   Host *
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_ed25519
   ```

#### Add your SSH key to the ssh-agent

1. Start the ssh-agent:

   ```bash
   eval "$(ssh-agent -s)"
   ```

2. Add your key, and keep its passphrase in the macOS keychain:

   ```bash
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   ```

#### Allowed signers

Git uses the allowed signers file to verify SSH signatures on commits. `config/git/config` sets the location of this file to `~/.ssh/allowed_signers`. For more information, see:

- [ssh-keygen: ALLOWED SIGNERS](https://man7.org/linux/man-pages/man1/ssh-keygen.1.html#ALLOWED_SIGNERS)
- [GitLab: Sign commits with SSH keys](https://docs.gitlab.com/ee/user/project/repository/ssh_signed_commits/)

To set up the file:

1. Make the file and set its permissions:

   ```bash
   touch ~/.ssh/allowed_signers && chmod 644 ~/.ssh/allowed_signers
   ```

2. Add a line with your email address and your public key:

   ```text
   <you@example.com> namespaces="git" <public key>
   ```

3. Add the public key to GitHub and to other services. On GitHub, add it as an authentication key and as a signing key.

#### Ghostty terminfo on remote hosts

Ghostty sets `TERM=xterm-ghostty`. A server can show an error for this terminal type if it does not know it. To fix this, copy the terminfo entry to the server one time:

```bash
infocmp -x xterm-ghostty | ssh <host> -- tic -x -
```

#### Add a passphrase to an SSH key

To add or change the passphrase of a private key, use this command. You do not have to make a new key pair.

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519
```

#### Show the fingerprint of an SSH key

To show the SHA256 fingerprint of your public key, use this command:

```bash
ssh-keygen -lf ~/.ssh/id_ed25519.pub
```

### Directories for source code

Make the `Projects` and `Sites` directories in your home directory. `Projects` is for source code. `Sites` is for websites. Only your user can use these directories.

```bash
mkdir ~/Projects && chmod u+rwx,go-rwx ~/Projects
```

```bash
mkdir ~/Sites && chmod u+rwx,go-rwx ~/Sites
```

### ACLs for Projects and Sites

These access control lists (ACLs) prevent the deletion of the `Projects` and `Sites` directories. They do not prevent the deletion of the files in the directories.

```bash
chmod +a "group:everyone deny delete" ~/Projects
```

```bash
chmod +a "group:everyone deny delete" ~/Sites
```

## Homebrew

To install Homebrew, use the official command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> **NOTE:** If a Homebrew command fails, you possibly must accept the Xcode license, or correct a different problem. To find the problem, run `brew doctor`.

### Bash from Homebrew

To use the Homebrew version of bash as your login shell:

1. Get the location of Homebrew:

   ```bash
   BREW_PREFIX=$(brew --prefix)
   ```

2. Add the Homebrew bash to the list of permitted shells, if it is not in the list:

   ```bash
   grep -qxF "${BREW_PREFIX}/bin/bash" /etc/shells || echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
   ```

3. Make the Homebrew bash your login shell:

   ```bash
   chsh -s "${BREW_PREFIX}/bin/bash"
   ```

4. Open a new terminal window.
