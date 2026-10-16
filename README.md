# Dotfiles

Based on recipes and examples from the below resources, among others:

- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [Paul Irish](https://github.com/paulirish/dotfiles)
- [dotfiles](https://dotfiles.github.io)
- [Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/)

**Warning:** If you want to give these tools a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use these settings unless you know what that entails. Use at your own risk!

## Automated macOS Setup

Configuration of macOS and the installation and configuration of various applications, including those installed with Homebrew, is handled through the [Mac Development Ansible Playbook](https://github.com/greylabel/mac-dev-playbook), and which is controlled and automated by Ansible wherever possible.

The [Mac Development Ansible Playbook](https://github.com/greylabel/mac-dev-playbook) incorporates the installation and updating of a set of dotfiles like this one.

## Install from this repo directly

Clone the repository and run the bootstrapper. It pulls the latest changes and **symlinks** the files into place, so edits in the repo take effect immediately (and `lazy-lock.json` updates land back in the repo). Anything already in the way is moved to `~/.dotfiles-backup/<timestamp>/`.

```bash
git clone git@github.com:greylabel/dotfiles.git && cd dotfiles && ./bootstrap.sh
```

To update (or to pick up newly added files), `cd` into the repository and run `./bootstrap.sh` again. Use `./bootstrap.sh -f` to skip the confirmation prompt.

### Layout

- Root dotfiles (`.bash_profile`, `.aliases`, `.inputrc`, `.editorconfig`, …) are linked into `~`.
- Each directory in `config/` is linked into `~/.config/`:

| Directory                    | Tool                                                                                                                                                 |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `config/ghostty`             | [Ghostty](https://ghostty.org/docs/config/reference) terminal                                                                                        |
| `config/herdr`               | [herdr](https://herdr.dev/docs/configuration/) agent workspace (only `config.toml` is linked; herdr keeps runtime files beside it)                   |
| `config/tmux`                | tmux (≥ 3.1 reads `~/.config/tmux/tmux.conf`; the Tokyo Night colors need ≥ 3.6; older versions keep tmux's defaults)                                |
| `config/nvim`                | Neovim (lazy.nvim, Mason, treesitter)                                                                                                                |
| `config/vim`                 | Vim (≥ 9.1 reads `~/.config/vim/vimrc`)                                                                                                              |
| `config/git`                 | git `config` and global `ignore` (shared settings; `git config --global` writes to an untracked `~/.gitconfig` that bootstrap creates) |
| `config/curl`, `config/wget` | Opt-in research profiles, used via `rcurl` / `rwget` (plain `curl`/`wget` keep their defaults)                                                       |

To add a tool, add `config/<tool>/`; no bootstrap changes are needed.

Tools that don't read `~/.config` get their own top-level directory, linked by bootstrap where the tool looks: `iterm2/dotfiles.json` becomes an iTerm2 Dynamic Profile (macOS, when iTerm2 is installed).

### Prerequisites

**Required (macOS):**

```bash
xcode-select --install          # git, make and a C compiler (Neovim builds parsers and plugins)
brew install bash bash-completion@2 git neovim tmux ripgrep fd tree-sitter-cli git-delta
brew install --cask font-fira-code font-symbols-only-nerd-font
brew install --cask ghostty     # and/or iterm2
```

- **Node.js** and **Python 3**, for Neovim's language servers and formatters: see [Neovim tools](#neovim-tools).
- **herdr**: install from [herdr.dev](https://herdr.dev/), if you use it instead of (or alongside) tmux.
- **Homebrew bash** as your login shell: see [Bash from Homebrew](#bash-from-homebrew). macOS's bash 3.2 lacks options these files use.

**Optional, for specific aliases and functions:**

| Install                             | Used by                                                                                                    |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `brew install --cask 1password-cli` | 1Password shell plugins and `~/.config/op-run` wrappers ([Private files and secrets](#private-files-and-secrets)) |
| `brew install tree wget pigz`       | `tre`, `rwget`, faster `targz`                                                                             |
| `brew install uv pnpm pyenv`        | Python and JavaScript tooling the shell sets up when present                                               |
| [TPM](#tmux--tpm)                   | tmux plugins                                                                                               |

**Minimum versions:** Neovim 0.12, Vim 9.1, tmux 3.1 (3.6 for the Tokyo Night colors), git 2.37, bash 4 (macOS's built-in bash 3.2 still works, without `autocd` and `globstar`).

**Linux:** install the same tools with your package manager (`build-essential` or equivalent for `make` and a C compiler; `xdg-utils` for `open`). Distribution packages of Neovim are often older than 0.12; use the [official release](https://github.com/neovim/neovim/releases) instead. Without `git-delta`, git falls back to `less`.

### Neovim tools

On first start, lazy.nvim installs plugins and Mason installs language servers and formatters (`:Lazy` and `:Mason` show progress). They need these on `PATH`:

| Needs                          | For                                                                             |
| ------------------------------ | ------------------------------------------------------------------------------- |
| `git`                          | lazy.nvim (plugins)                                                             |
| `make`, C compiler             | telescope-fzf-native                                                            |
| `tree-sitter` CLI, C compiler  | nvim-treesitter (parsers)                                                       |
| `node`, `npm`                  | Mason: vtsls, eslint, jsonls, yamlls, bashls, dockerls, prettierd               |
| `python3` with `venv`, `pip`   | Mason: basedpyright, sqlfluff                                                   |
| `curl`, `unzip`, `tar`, `gzip` | Mason: lua_ls, ruff, taplo, stylua, shfmt (prebuilt binaries; built into macOS) |
| `rg`, `fd`                     | Telescope search                                                                |

Node via [nvm](https://github.com/nvm-sh/nvm):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/HEAD/install.sh | PROFILE=/dev/null bash  # .bash_profile already loads nvm
nvm install --lts
nvm alias default 'lts/*'
```

`.bash_profile` puts nvm's **default** version on `PATH`, so Neovim needs `nvm alias default` set and must start from a login shell. Python 3 comes from pyenv (`pyenv install 3.12 && pyenv global 3.12`) or `brew install python`.

Check with `:checkhealth lazy mason`. Mason also checks languages this config doesn't use; warnings for luarocks, Java, Julia, Ruby, Go, cargo, PHP and Composer are safe to ignore.

### Installers that edit shell files

`~/.bashrc` and `~/.bash_profile` are links into this repo, so an installer that appends to them edits the repo. `.bash_profile` already sets up nvm, pnpm, pyenv and `~/.local/bin`, so skip those edits:

| Tool   | Install without editing shell files                                       |
| ------ | ------------------------------------------------------------------------- |
| nvm    | `… install.sh \| PROFILE=/dev/null bash`                                  |
| pnpm   | `brew install pnpm`; don't run `pnpm setup`                               |
| uv     | `brew install uv`, or `UV_NO_MODIFY_PATH=1` with the script installer     |
| rustup | `rustup-init --no-modify-path`                                            |

Homebrew never edits shell files. For an installer with no opt-out, check `git diff`, move anything you need into `~/.extra` (untracked) and `git checkout` the file.

Install pnpm with Homebrew rather than Corepack: nvm keeps global packages per Node version, so Corepack's pnpm disappears on each Node upgrade, and Node 25+ no longer bundles Corepack. Projects still pin their pnpm version with `packageManager` in `package.json`.

### Shared keys

Theme is Tokyo Night across Ghostty, iTerm2, herdr, tmux and Neovim: Storm in dark mode, Day in light mode. The terminal follows the macOS appearance, and the others follow the terminal.

| Keys                                  | herdr / tmux                 | Neovim / Vim                                                        |
| ------------------------------------- | ---------------------------- | ------------------------------------------------------------------- |
| `C-a`                                 | prefix                       |                                                                     |
| `prefix` `h/j/k/l`                    | focus pane                   |                                                                     |
| `prefix` `H/J/K/L`                    | resize pane                  |                                                                     |
| `prefix` `\|` / `-`                   | split side by side / stacked |                                                                     |
| `C-h/j/k/l`                           |                              | move between windows                                                |
| `Space` `w` `q` `v` `s` `e`           |                              | write, quit, vsplit, split, file tree                               |
| `Space` `f…` `g…` `c…` `x…` `u…` `a…` |                              | find, git, code, diagnostics, toggles, agent (which-key lists them) |

### Terminals

Any combination works: Ghostty or iTerm2, herdr or tmux, Neovim or Vim. Each layer sticks to standard terminal features rather than one terminal's extras:

- **Keys** are plain terminal keys (prefix, `Ctrl`, `Space`), never `Cmd`. Left Option is Alt/Meta in both terminals, so shell and Neovim Alt shortcuts behave the same; right Option types special characters.
- **Colors** use true colour. Each terminal sets its own `TERM` (`xterm-ghostty`, `xterm-256color`, `tmux-256color`); nothing overrides it.
- **Light/dark**: the terminal switches its palette with macOS. tmux and Neovim read the terminal's background, and herdr follows macOS itself.
- **Clipboard** uses OSC 52, so tmux copy mode, herdr and Neovim (also over SSH) reach the macOS clipboard through any terminal that allows it.
- **Icons** in Neovim need the Nerd Font symbols: built into Ghostty, and set as iTerm2's non-ASCII font by the profile.

|                                       | Ghostty                                     | iTerm2                                                                                  |
| ------------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------- |
| Config                                | `config/ghostty`                            | `iterm2/dotfiles.json` profile "Dotfiles"; make it the default in Settings → Profiles   |
| Palette source                        | built-in themes named on the `theme =` line | generated from Ghostty's same themes by `iterm2/generate.py`                            |
| Light/dark palette                    | `theme = dark:…,light:…`                    | separate light and dark colors in the profile                                           |
| Clipboard (OSC 52)                    | allowed by default                          | enable Settings → General → Selection → _Applications in terminal may access clipboard_ |
| Native text selection over tmux/herdr | hold `Shift` while dragging                 | hold `Option` while dragging                                                            |
| Copy a herdr selection                | `Cmd+C` or `Ctrl+C`                         | `Ctrl+C`                                                                                |

Both terminals' colors come from [iTerm2-Color-Schemes](https://iterm2colorschemes.com/), which Ghostty bundles as its themes. Ghostty's `theme =` line is the one place the theme is chosen: after changing it (or updating Ghostty), run `python3 iterm2/generate.py` to rebuild the iTerm2 profile with the same palettes. Neovim's own colors come from tokyonight.nvim, which draws the same theme with a few small differences in the ANSI colors.

A new terminal fits in the same way: give it Tokyo Night Storm/Day, Fira Code with Nerd Font symbols, left Option as Alt, and OSC 52 clipboard access.

### tmux + TPM

The tmux config loads the [TPM](https://github.com/tmux-plugins/tpm) plugin manager if it is installed:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Then start tmux and press `Ctrl+A` followed by `I` to install the configured plugins.

### Agentic development

- Neovim reloads files changed outside it (for example by an agent in another pane) when it regains focus; tmux sends focus events for this.
- Review an agent's changes with `Space g d` (diffview) and stage or reset hunks with `Space g s` / `Space g r`.
- Optional Claude Code bridge: in Neovim press `Space a c`, then run `/ide` in a `claude` session to see its edits as Neovim diffs (`Space a a` accept, `Space a d` reject). Nothing runs until one of the `Space a` keys is used; delete `config/nvim/lua/plugins/agent.lua` to remove it.

## Extending and overriding

### Additions to `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing (such as detecting which version of `ls` is being used in [`.aliases`](.aliases)) takes place.

### Add custom commands

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

You could also use `~/.extra` to override settings, functions and aliases from these dotfiles repository. It’s probably better to [fork this repository](https://github.com/greylabel/dotfiles/fork) instead, though.

### Private files and secrets

`~/.extra`, `~/.path` and `~/.gitconfig.local` are never committed, and `bootstrap.sh` sets them to `chmod 600` (readable only by you) each time it runs.

`~/.extra` is sourced into every shell, including the shells AI agents run commands in, so **don't export secret values from it**. Keep secrets in 1Password, and let each command fetch them only when it runs:

* **Tools with a [1Password shell plugin](https://developer.1password.com/docs/cli/shell-plugins/)** (`gh`, `aws`, `terraform`, …): set them up with `op plugin init <tool>`. 1Password writes `~/.config/op/plugins.sh`, which `.bash_profile` loads.
* **Any other tool:** create `~/.config/op-run/<command>.env` containing [secret references](https://developer.1password.com/docs/cli/secret-references/), one `VARIABLE=op://vault/item/field` per line. `.functions` then wraps `<command>` so each run gets those variables from 1Password for that run only. To get a reference, right-click a field in 1Password and choose **Copy Secret Reference**. These files hold references, not secrets, and live outside the repo.

Both load only in human shells, never in agent shells.

### Human and agent shells

Shells that AI agents run commands in get plain, predictable commands. `.bash_profile` treats a shell as an agent's when it isn't interactive or when `CLAUDECODE` (Claude Code), `AI_AGENT`, `CODEX_SANDBOX` (Codex) or `GEMINI_CLI` is set. For any other agent, set `DOTFILES_AGENT=1` in its environment. Agent shells don't get:

- the `rm -i`, `cp -v`, `mv -v`, `mkdir -p`, `df -h` and `du -h` aliases, or `diff` running `git diff`
- `man` in Neovim (agents get `less`, which doesn't wait for a terminal)
- the `nocaseglob`, `cdspell`, `autocd` and `globstar` shell options
- 1Password shell plugins and `~/.config/op-run` wrappers

Agent sessions keep the shell environment they started with, so restart them after changing these files.

## Additional and notable configuration

### Git

Create a `~/.gitconfig.local` file (included from `~/.config/git/config`) for your name, email and signing key. Keep tokens out of it; the GitHub CLI authenticates through 1Password.

```bash
[user]

  name = <Your Name>
  email = <you@example.com>
  signingkey = ~/.ssh/id_ed25519.pub

[github]

  user = ghusername
```

### SSH

#### Generating a new SSH key pair

> See Github's [Generating a new SSH key and adding it to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) for more information.

Create directory for SSH keys and configuration and set permissions.

```bash
mkdir ~/.ssh && chmod 0700 ~/.ssh
```

Generate a new SSH key.

```bash
ssh-keygen -t ed25519
```

Set permissions.

```bash
chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub
```

#### SSH Configuration

Create and set permissions on the `~/.ssh/config` file.

```bash
touch ~/.ssh/config && chmod 644 ~/.ssh/config
```

Modify the `~/.ssh/config` file to automatically load keys into the ssh-agent and store passphrases in your keychain.

```bash
IgnoreUnknown AddKeysToAgent,UseKeychain

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

#### Adding your SSH key to the ssh-agent

```bash
eval "$(ssh-agent -s)"
```

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Allowed Signers

See:

- <https://man7.org/linux/man-pages/man1/ssh-keygen.1.html#ALLOWED_SIGNERS>
- <https://docs.gitlab.com/ee/user/project/repository/ssh_signed_commits/>

Create and set permissions on the `allowed_signers` file.

```bash
touch ~/.ssh/allowed_signers && chmod 644 ~/.ssh/allowed_signers
```

Add an entry with a public key.

```bash
<you@example.com> namespaces="git" <public key>
```

At this point, the new key can be added to GitHub and other cloud services.

#### Ghostty terminfo on remote hosts

Ghostty sets `TERM=xterm-ghostty`. If a server you SSH into reports an unknown terminal, copy the terminfo entry to it once:

```bash
infocmp -x xterm-ghostty | ssh <host> -- tic -x -
```

#### Add a passphrase to an existing SSH key

Add/replace the passphrase for an existing private key without regenerating the keypair.

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519
```

#### Check SSH key fingerprint

```bash
ssh-keygen -lf ~/.ssh/id_ed25519.pub # SHA256
```

### Directories for source code

Create `Projects` and `Sites` home directories — generally will contain source code and websites, respectively.

```bash
mkdir ~/Projects && chmod u+rwx,go-rwx ~/Projects
```

```bash
mkdir ~/Sites && chmod u+rwx,go-rwx ~/Sites
```

### ACLs for Projects and Sites

Set ACLs for Projects and Sites to prevent accidental deletion.

```bash
chmod +a "group:everyone deny delete" ~/Projects
```

```bash
chmod +a "group:everyone deny delete" ~/Sites
```

## Homebrew

For reference, the official command to install Homebrew with `curl` is below.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other issue. Run `brew doctor` to see if this is the case.

### Bash from Homebrew

```bash
# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)
```

```bash
# Switch to using brew-installed bash as default shell
if ! grep -qF "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;
```
