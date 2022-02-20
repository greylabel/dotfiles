#!/bin/bash


# to maintain cask ....
#     brew update && brew cask upgrade && brew cleanup && brew cask cleanup`


# Install native apps

brew tap caskroom/cask
brew tap caskroom/versions

# Install Chromedriver
brew cask install chromedriver

# Install Docker Toolbox
brew cask install docker-toolbox

# Install Java
# brew cask install java

# Install fonts
brew tap homebrew/cask-fonts
brew cask install font-courier-prime
brew cask install font-fira-code
