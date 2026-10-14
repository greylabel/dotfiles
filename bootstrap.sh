#!/usr/bin/env bash

# Symlink these dotfiles into $HOME and $XDG_CONFIG_HOME.
#
# * Root dotfiles listed in HOME_FILES are linked into ~.
# * Each directory in config/ is linked into ~/.config/, except tools in
#   FILE_LINK_TOOLS (which keep runtime state next to their config), whose
#   files are linked one by one.
# * Anything in the way is moved to ~/.dotfiles-backup/<timestamp>/.
# * Files that moved into config/ (RETIRED_HOME_FILES) are removed from ~ if
#   they link here, or backed up if they're real files (they would override
#   the XDG versions). Old git links are removed; real ~/.gitignore and
#   ~/.gitattributes are left alone (nothing reads them any more).
# * ~/.gitconfig is kept as a real, untracked file so `git config --global`
#   writes there, not into config/git/config in this public repo.
# * Private files (~/.extra, ~/.path, ~/.gitconfig.local) are set to 600.
# * Dangling links that point into this repo are removed.
#
# Usage: ./bootstrap.sh [-f]   (or `source bootstrap.sh` to also reload
# ~/.bash_profile in the current shell)

# Runs in a subshell so cd, variables and helpers never leak into a shell
# that sources this file.
bootstrap_main() (
	HOME_FILES=(
		.aliases
		.bash_profile
		.bash_prompt
		.bashrc
		.editorconfig
		.exports
		.functions
		.hushlogin
		.inputrc
		.tm_properties
	)
	FILE_LINK_TOOLS=(herdr)
	# Private, uncommitted files; kept readable by you only.
	PRIVATE_FILES=(.extra .path .gitconfig.local)
	RETIRED_HOME_FILES=(.vimrc .gvimrc .tmux.conf .curlrc .wgetrc)
	RETIRED_HOME_LINKS=(.gitconfig .gitignore .gitattributes)

	CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

	force=
	[ "$1" = "--force" ] || [ "$1" = "-f" ] && force=1

	if [ -z "$force" ]; then
		read -r -p "This may replace existing files in your home directory (backups are kept). Are you sure? (y/n) " -n 1
		echo ""
		[[ $REPLY =~ ^[Yy]$ ]] || exit 3 # declined
	fi

	# Show what an update would bring in (with signature status: G = good,
	# N = unsigned) before it lands in files your shell sources.
	if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1 && git fetch --quiet; then
		incoming="$(git log --format='%h %G? %an  %s' 'HEAD..@{u}')"
		if [ -n "$incoming" ]; then
			echo "Incoming commits:"
			echo "$incoming"
			REPLY=y
			if [ -z "$force" ]; then
				read -r -p "Pull these before linking? (y/n) " -n 1
				echo ""
			fi
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				git merge --ff-only '@{u}' || echo "update failed; continuing with the local checkout"
			fi
		fi
	fi

	repo="$(pwd -P)"
	config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
	backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
	failed=0

	# Move $1 into the backup dir, keeping its path.
	back_up() {
		local target="$1" rel
		rel="${target#"$HOME"/}"
		mkdir -p "$backup/$(dirname "$rel")" &&
			mv "$target" "$backup/$rel" &&
			echo "backed up $target"
	}

	# Link $2 -> $1, backing up whatever is already at $2.
	link() {
		local src="$1" dest="$2" dest_dir
		if [ "$(readlink "$dest")" = "$src" ]; then
			return 0
		fi
		# Never replace the repo file itself (e.g. when a parent dir links here).
		dest_dir="$(cd "$(dirname "$dest")" 2>/dev/null && pwd -P)"
		if [ "$dest_dir/$(basename "$dest")" = "$src" ]; then
			echo "error: $dest resolves to $src; fix its parent directory" >&2
			return 1
		fi
		if [ -e "$dest" ] || [ -L "$dest" ]; then
			back_up "$dest" || return 1
		fi
		mkdir -p "$(dirname "$dest")" &&
			ln -s "$src" "$dest" &&
			echo "linked $dest -> $src"
	}

	# Remove links into this repo whose target no longer exists. Only links
	# into the repo are touched, so links you made elsewhere are safe.
	prune() {
		local dir="$1" depth="$2" l
		[ -d "$dir" ] || return 0
		while IFS= read -r l; do
			case "$(readlink "$l")" in
				"$repo"/*)
					if [ ! -e "$l" ]; then
						rm "$l" && echo "removed stale link $l"
					fi
					;;
			esac
		done < <(find -H "$dir" -maxdepth "$depth" -type l)
	}

	for f in "${RETIRED_HOME_FILES[@]}"; do
		case "$(readlink "$HOME/$f")" in
			"$repo"/*) rm "$HOME/$f" && echo "removed retired link $HOME/$f" ;;
			*) if [ -e "$HOME/$f" ] || [ -L "$HOME/$f" ]; then back_up "$HOME/$f" || failed=1; fi ;;
		esac
	done

	for f in "${RETIRED_HOME_LINKS[@]}"; do
		case "$(readlink "$HOME/$f")" in
			"$repo"/*) rm "$HOME/$f" && echo "removed retired link $HOME/$f" ;;
		esac
	done

	# A real ~/.gitconfig copied by the old rsync bootstrap repeats this repo's
	# settings (and points git at ~/.gitignore); back it up and start fresh.
	if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ] &&
		grep -q '^ *excludesfile = ~/.gitignore' "$HOME/.gitconfig"; then
		back_up "$HOME/.gitconfig" || failed=1
		echo "note: your name, email and signing key belong in ~/.gitconfig.local (see README)"
	fi
	if [ ! -e "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
		printf '%s\n' \
			'# Machine-local git settings written by git config --global and tools' \
			'# (gh auth setup-git, git lfs install...). Shared settings live in' \
			'# ~/.config/git/config (dotfiles); identity in ~/.gitconfig.local.' \
			> "$HOME/.gitconfig" && echo "created $HOME/.gitconfig (local git settings)"
	fi

	for f in "${HOME_FILES[@]}"; do
		link "$repo/$f" "$HOME/$f" || failed=1
	done

	for tool_dir in config/*/; do
		tool="$(basename "$tool_dir")"
		if [[ " ${FILE_LINK_TOOLS[*]} " == *" $tool "* ]]; then
			# Needs a real directory: move aside a link or file in its place.
			if [ -L "$config_home/$tool" ] || { [ -e "$config_home/$tool" ] && [ ! -d "$config_home/$tool" ]; }; then
				back_up "$config_home/$tool" || {
					failed=1
					continue
				}
			fi
			while IFS= read -r f; do
				link "$repo/config/$tool/$f" "$config_home/$tool/$f" || failed=1
			done < <(cd "config/$tool" && find . -type f | sed 's|^\./||')
		else
			link "$repo/config/$tool" "$config_home/$tool" || failed=1
		fi
	done

	# iTerm2 profile (Tokyo Night Storm/Day, same font and keys as Ghostty),
	# loaded as a Dynamic Profile when iTerm2 is installed
	if [[ "$OSTYPE" == darwin* ]] && [ -d /Applications/iTerm.app ]; then
		link "$repo/iterm2/dotfiles.json" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json" || failed=1
	fi

	# Vim before 9.1.0327 (e.g. Ubuntu 24.04) doesn't read ~/.config/vim/vimrc
	if [[ "$OSTYPE" != darwin* ]]; then
		link "$repo/config/vim/vimrc" "$HOME/.vim/vimrc" || failed=1
	fi

	for f in "${PRIVATE_FILES[@]}"; do
		# Any group/other permission bit set?
		if [ -f "$HOME/$f" ] && [ -n "$(find -L "$HOME/$f" -prune \( -perm -040 -o -perm -020 -o -perm -010 -o -perm -004 -o -perm -002 -o -perm -001 \) -print)" ]; then
			if [ -L "$HOME/$f" ]; then
				# Don't change the mode of a file the link points at
				echo "warning: $HOME/$f links to a file others can read; check its permissions" >&2
			else
				chmod 600 "$HOME/$f" && echo "secured $HOME/$f (chmod 600)" || failed=1
			fi
		fi
	done

	prune "$HOME" 1
	prune "$config_home" 3

	if [ "$failed" -ne 0 ]; then
		echo "bootstrap finished with errors" >&2
		exit 1
	fi
)

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
	# Sourced: also reload the profile in the calling shell.
	bootstrap_main "$@"
	case $? in
		0)
			unset -f bootstrap_main
			# shellcheck source=/dev/null
			source ~/.bash_profile
			;;
		3) unset -f bootstrap_main ;; # declined: nothing changed
		*)
			unset -f bootstrap_main
			false
			;;
	esac
	return
fi
bootstrap_main "$@" || {
	status=$?
	[ "$status" -eq 3 ] && exit 0 # declined
	exit "$status"
}
