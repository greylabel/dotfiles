#!/bin/bash


# to maintain cask ....
#     brew update && brew cask upgrade && brew cleanup && brew cask cleanup`

brew tap caskroom/cask
brew tap caskroom/versions

# Install Docker Toolbox
brew cask install docker-toolbox

# Install Vagrant
brew cask install virtualbox
brew cask install vagrant
brew cask install vagrant-manager

# brew cask install java

# Install fonts
brew tap caskroom/fonts
brew cask install font-fira-code

# Install native apps
brew cask install cyberduck
brew cask install spotify