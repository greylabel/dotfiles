#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
# ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed
# Install Bash 4.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install `wget` with IRI support.
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim
brew install grep
brew install openssh
brew install screen

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hashpump
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install pngcheck
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install tcptrace
brew install ucspi-tcp # `tcpserver` etc.
brew install xpdf
brew install xz

# Install other useful binaries.
brew install ack
#brew install exiv2
brew install git
brew install git-lfs
brew install imagemagick
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install tree
brew install vbindiff
brew install zopfli

###

brew install ansible
brew install colordiff
brew install curl
brew install dnsmasq
brew install goaccess
brew install gpatch
brew install graphviz
brew install httpie
brew install icoutils
brew install jmeter
brew install jpegoptim
# brew install libressl
brew install mitmproxy
brew install openssl
brew install patchutils
brew install percona-toolkit
brew install pianobar
brew install pngcrush
brew install tldr
brew install watchman

# Install apache
# brew install httpd

# Install node
brew install node

# Install yarn
brew install yarn

# Install mysql
brew install mysql
# brew services start mysql

# Install reddis
brew install redis
# brew services start redis

# Install memcached
brew install memcached
# brew services start memcached

# Install PHP
brew install php@7.1

brew install composer

# Previously in homebrew-php, which is deprecated.
# brew install drush-launcher
# brew install drupal-code-sniffer
# brew install drupalconsole

# Install Python
brew install python
brew install pyenv

# Install Ruby
brew install ruby
brew install rbenv
brew install ruby-build
brew install rbenv-default-gems
brew install rbenv-gemset

# Install Go
brew install golang

# Install Elixir
brew install elixir

# Remove outdated versions from the cellar.
brew cleanup
