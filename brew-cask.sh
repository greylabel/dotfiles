#!/bin/bash


# to maintain cask ....
#     brew update && brew cask upgrade && brew cleanup && brew cask cleanup`


# Install native apps

brew tap homebrew/cask
brew tap homebrew/versions

# Install Chromedriver
brew install --cask chromedriver

# Install Docker Toolbox
brew install --cask docker-toolbox

# Install Java
# brew cask install java

# Install fonts
brew tap homebrew/cask-fonts
brew install --cask font-courier-prime
brew install --cask font-fira-code
brew install --cask font-inter
