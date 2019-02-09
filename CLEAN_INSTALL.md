# Clean Install – OS X 10.14 Mojave
* [Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/)

## OS X Setup

#### Create directories
```bash
mkdir ~/Projects && chmod +a "group:everyone deny delete" Projects
mkdir ~/Sites && chmod +a "group:everyone deny delete" Sites
```

#### Set hostname (optional)
```bash
sudo scutil --set HostName Babylon
```

### SSH
[Generating a new SSH key and adding it to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)

#### Generating a new SSH key

```bash
cd ~/
mkdir .ssh
chmod go-rwx .ssh
cd .ssh
```

```bash
ssh-keygen -t rsa -b 4096 -C "grant@greylabel.net"
chmod 600 id_rsa.pub
```

#### Adding your SSH key to the ssh-agent
```bash
eval "$(ssh-agent -s)"
```

Modify your `~/.ssh/config` file to automatically load keys into the ssh-agent and store passphrases in your keychain.
```bash
Host *
 AddKeysToAgent yes
 UseKeychain yes
 IdentityFile ~/.ssh/id_rsa
```

```bash
ssh-add -K ~/.ssh/id_rsa
```

At this point, the new key should be added to GitHub.

### Git
Create and use `~/.gitconfig.local` file for username / github token / etc.

```
[user]

  name = Grant Gaudet
  email = grant@greylabel.net

[github]

  user = greylabel
```

### Dotfiles

#### Links and resources
* [dotfiles](https://dotfiles.github.io)

### Homebrew and global packages

```bash
# install package manager
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

```bash
./brew.sh
./brew-cask.sh
```

### Vagrant

```bash
vagrant plugin install vagrant-hostsupdater
```

### Xcode

#### Agree To Xcode
```bash
sudo xcrun cc
```

## Go

See `.exports`.

```bash
export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
```

## Node

#### Packages

```bash
npm install -g bower
```

## Python

```bash
pip install --upgrade setuptools
pip install --upgrade pip
pip install virtualenv
pip install ipython
```

## PHP

#### Links and resources
* [Homebrew PHP](https://github.com/Homebrew/homebrew-php)

See `.exports`.

`PATH="/usr/local/opt/php@7.1/bin:$PATH"`
`PATH="/usr/local/opt/php@7.1/sbin:$PATH"`

```bash
#setup daemon
mkdir -p ~/Library/LaunchAgents
cp /usr/local/opt/php@7.1/homebrew.mxcl.php@7.1.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.php@7.1.plist

/usr/local/etc/php/7.1/php.ini

memory_limit = 1G
date.timezone = America/Los_Angeles
upload_max_filesize = 64M
post_max_size = 32M

brew services start php@7.1

```

### Composer for PHP

[Downloading the Composer Executable](https://getcomposer.org/doc/00-intro.md#downloading-the-composer-executable)

[Download Composer](https://getcomposer.org/download/)
```bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
```

[Run these commands to globally install `composer` on your system:](https://getcomposer.org/doc/00-intro.md#globally)

```
curl -sS https://getcomposer.org/installer | php

mv composer.phar /usr/local/bin/composer
```

```bash
composer global require "hirak/prestissimo:^0.3"
```

## Ruby

#### rbenv

*Compatibility note:* rbenv is incompatible with RVM. Please make sure to fully uninstall RVM and remove any references to it from your shell initialization files before installing rbenv.

#### Gems
```bash
gem install bundler
```

## MySQL

```bash
# create mysql config
cp -v $(brew --prefix mysql)/support-files/my-default.cnf $(brew --prefix)/etc/my.cnf
```

```bash
cat >> $(brew --prefix)/etc/my.cnf <<'EOF'

# Settings overrides
innodb_buffer_pool_size = 128M
max_allowed_packet = 1073741824
innodb_file_per_table = 1
EOF
```

```bash
# start mysql
brew services start mysql
```

```bash
# secure mysql
$(brew --prefix mysql)/bin/mysql_secure_installation
```

## Apache

```bash
# Stop the built-in Apache
sudo launchctl unload /System/Library/LaunchDaemons/org.apache.httpd.plist 2>/dev/null
```

```bash
# Install Apache 2.2
brew install -v homebrew/apache/httpd22 --with-homebrew-openssl --with-mpm-event
```

```bash
# Install the mod_fastcgi module
brew install -v homebrew/apache/mod_fastcgi --with-brewed-httpd22
```

Follow the remaining Apache setup instructions in the [OS X 10.10 Yosemite Local Development Environment: Apache, PHP, and MySQL with Homebrew](https://echo.co/blog/os-x-1010-yosemite-local-development-environment-apache-php-and-mysql-homebrew).

## NGINX

```bash
sudo cp -v /usr/local/opt/nginx/*.plist /Library/LaunchDaemons/ &&
sudo chown root:wheel /Library/LaunchDaemons/homebrew.mxcl.nginx.plist &&
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
```

## Local Web Server

### Add DNS Domains, Enable dnsmasq daemon

This will route requests to any url ending in **.build** back to your own computer. The goal is to use urls like http://example.com.build for development while you work on http://example.com

```bash
mkdir -pv $(brew --prefix)/etc/ && \
echo 'address=/.build/127.0.0.1' > $(brew --prefix)/etc/dnsmasq.conf && \
sudo cp -v $(brew --prefix dnsmasq)/homebrew.mxcl.dnsmasq.plist /Library/LaunchDaemons && \
sudo launchctl load -w /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist && \
sudo mkdir -v /etc/resolver && \
sudo zsh -c 'echo "nameserver 127.0.0.1" > /etc/resolver/build'

#flush cache
sudo discoveryutil mdnsflushcache && scutil --dns
```

### Enable virtual hosts

This will allow you to serve folders under ~/Sites/ as websites.

* ~/Sites
  * example.com
    * htdocs
      * index.html

to access this site, visit http://example.com.build


### Match production server paths
```bash
sudo mkdir -p /var/ && sudo ln -s ~/Sites /var/www
```

## Drupal

### Drush Launcher

Follow the setup instructions on the [Drush Launcher](https://github.com/drush-ops/drush-launcher) project page.

## OS X Software

### Install from developer web sites

* [1Password](https://agilebits.com/downloads)
* [Adobe Creative Cloud](http://www.adobe.com/creativecloud/desktop-app.html)
* [Airfoil](https://rogueamoeba.com/airfoil/mac/)
* [Backblaze](https://www.backblaze.com/mac/install_backblaze.dmg)
* [Chrome](https://www.google.com/intl/en/chrome/browser/)
* [Cyberduck](https://cyberduck.io/download)
* [Docker](https://store.docker.com/editions/community/docker-ce-desktop-mac)
* [Dropbox](https://www.dropbox.com/downloading?src=index)
* [Encypt.me](https://encrypt.me/apps/)
* [Firefox](http://www.mozilla.org/en-US/firefox/all/)
* [Garmin Express](https://www.garmin.com/en-US/software/express)
* [iTerm2](https://www.iterm2.com/)
* [JetBrains Toolbox App](https://www.jetbrains.com/toolbox/app/)
* [Kaleidoscoope](https://www.kaleidoscopeapp.com)
* [Keep It](http://reinventedsoftware.com/keepit/downloads/)
* [NetNewsWire](http://netnewswireapp.com/mac/)
* [OmniFocus](https://www.omnigroup.com/download/latest/omnifocus)
* [PhpStorm](https://www.jetbrains.com/phpstorm/download/)
* [Sequel Pro](http://www.sequelpro.com/)
* [Sketch](https://www.sketchapp.com/download/sketch.zip)
* [Spotify](https://www.spotify.com/us/download/other/)
* [TextMate](http://macromates.com/download)
* [Tower](https://www.git-tower.com/mac/)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [VLC](https://www.videolan.org/vlc/download-macosx.html)
* [Webkit](http://webkit.org)
* [Wireshark](https://www.wireshark.org/download.html)
* [Zeplin](https://zpl.io/download-mac)

### Install from App Store

* [Alfred](https://itunes.apple.com/us/app/alfred/id405843582?mt=12)
* [Amphetamine](https://itunes.apple.com/us/app/amphetamine/id937984704?mt=12)
* [Better Renamer 9](https://itunes.apple.com/us/app/better-rename-9/id414209656?mt=12)
* [Slack](https://itunes.apple.com/se/app/slack/id803453959?mt=12)
* [Xcode](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12)

### Browser Extensions

#### Safari

[Safari Extensions](https://safari-extensions.apple.com)

* [1Password](https://safari-extensions.apple.com/details/?id=com.agilebits.onepassword4-safari-2BUA8C4S2C)
* [Dreditor](https://dreditor.org)
* [Grammarly](https://safari-extensions.apple.com/details/?id=com.grammarly.spellchecker.extension-W8F64X92K3)
* [Instapaper](https://safari-extensions.apple.com/details/?id=com.instapaper.extension-CAM49M58WK)
* [Pin It Button](https://safari-extensions.apple.com/extensions/com.pinterest.extension-HWZFLG9PNK/Pinterest-Safari.safariextz)
* [Wipr](https://safari-extensions.apple.com/details/?id=com.giorgiocalderolla.wipr-desktop-4449XA862Y)
