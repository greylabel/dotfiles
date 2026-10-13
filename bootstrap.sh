#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

function doIt() {
	rsync --exclude ".git/" \
  	--exclude ".github/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;

	config_dir="${XDG_CONFIG_HOME:-$HOME/.config}";
	mkdir -p "$config_dir";
	rsync -avh --no-perms ghostty/.config/ "$config_dir/";
	rsync -avh --no-perms herdr/.config/ "$config_dir/";
	rsync -avh --no-perms nvim/.config/ "$config_dir/";

	source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
