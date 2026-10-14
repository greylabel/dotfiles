PATH="/opt/homebrew/bin:$PATH"
PATH="/opt/homebrew/sbin:$PATH"
PATH="/usr/local/bin:$PATH"
PATH="/usr/local/sbin:$PATH"

# Homebrew prefix, computed once (each `brew --prefix` call costs ~40-80ms)
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2> /dev/null)}"
export HOMEBREW_PREFIX

# pnpm global binaries
if [[ "$OSTYPE" == darwin* ]]; then
	export PNPM_HOME="$HOME/Library/pnpm"
else
	export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
fi

# Directories any install script can write to (go install, pip/uv tools,
# pnpm -g, your own scripts) go after the system directories, so nothing
# dropped there can shadow ssh, git, sudo and the like.
for dir in "$HOME/bin" "$HOME/.local/bin" "${GOPATH:-$HOME/go}/bin" "$PNPM_HOME"; do
	case ":$PATH:" in
		*":$dir:"*) ;;
		*) PATH="$PATH:$dir" ;;
	esac
done
unset dir
export PATH

# Python version management: pyenv shims only. The full `pyenv init` (~0.3s)
# is only needed for `pyenv shell`; uv also reads .python-version files.
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
[ -d "$PYENV_ROOT/shims" ] && PATH="$PYENV_ROOT/shims:$PATH"

# Ruby version management, only when rbenv manages a Ruby (~0.13s otherwise)
if command -v rbenv >/dev/null && compgen -G "$HOME/.rbenv/versions/*" >/dev/null; then
	eval "$(rbenv init -)"
fi

# Node: put nvm's default version on PATH now and load nvm itself on first
# use of `nvm` (~0.5s). Falls back to loading nvm if the default can't be found.
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
	nvm_default="$(cat "$NVM_DIR/alias/default" 2>/dev/null)"
	nvm_default_bin="$(printf '%s\n' "$NVM_DIR/versions/node/v${nvm_default#v}"*/bin | sort -V | tail -1)"
	if [ -n "$nvm_default" ] && [ -d "$nvm_default_bin" ]; then
		PATH="$nvm_default_bin:$PATH"
		nvm() {
			unset -f nvm
			\. "$NVM_DIR/nvm.sh"
			[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
			nvm "$@"
		}
	else
		\. "$NVM_DIR/nvm.sh"
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
	fi
	unset nvm_default nvm_default_bin
fi
export PATH

# iTerm2 shell integration, only inside iTerm2 (its escape codes otherwise
# end up in Ghostty, herdr and agent output)
if [ "${TERM_PROGRAM:-}" = "iTerm.app" ] && [ -e "${HOME}/.iterm2_shell_integration.bash" ]; then
	source "${HOME}/.iterm2_shell_integration.bash"
fi

# Conveniences that prompt, page or change what a command does (rm -i,
# mkdir -p, diff -> git diff, man in Neovim, glob options) are only for
# people. Agent shells get plain commands so they don't hang or misread
# output. Known agents set CLAUDECODE (Claude Code), AI_AGENT, CODEX_SANDBOX
# (Codex) or GEMINI_CLI; set DOTFILES_AGENT=1 for any other agent.
if [[ $- == *i* ]] && [ -z "${CLAUDECODE:-}${AI_AGENT:-}${CODEX_SANDBOX:-}${GEMINI_CLI:-}${DOTFILES_AGENT:-}" ]; then
	DOTFILES_HUMAN_SHELL=1
else
	DOTFILES_HUMAN_SHELL=
fi

# 1Password shell plugins (gh, aws, terraform, wrangler, cdk run with your
# credentials). People only: an agent shell must not inherit cloud access.
if [ -n "$DOTFILES_HUMAN_SHELL" ] && [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/op/plugins.sh" ]; then
	source "${XDG_CONFIG_HOME:-$HOME/.config}/op/plugins.sh"
fi

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Glob and cd conveniences, people only (in an agent shell `rm *.c` must not
# also match *.C, and a typo must not silently change directory):
# * Case-insensitive globbing (used in pathname expansion)
# * Autocorrect typos in path names when using `cd`
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
if [ -n "$DOTFILES_HUMAN_SHELL" ]; then
	for option in nocaseglob cdspell autocd globstar; do
		shopt -s "$option" 2> /dev/null; # autocd/globstar need bash 4; macOS /bin/bash is 3.2
	done;
	unset option;
fi;

# Add tab completion for many Bash commands
if [ -n "$HOMEBREW_PREFIX" ] && [ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$HOMEBREW_PREFIX/etc/bash_completion.d";
	source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh";
elif [ -r /usr/share/bash-completion/bash_completion ]; then
	source /usr/share/bash-completion/bash_completion;
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain` (macOS)
if [[ "$OSTYPE" == darwin* ]]; then
	complete -W "NSGlobalDomain" defaults;
fi;
