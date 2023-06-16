# Dotfiles

#### Based on recipes and examples from the below resources, among others...
* [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
* [Paul Irish](https://github.com/paulirish/dotfiles)
* [dotfiles](https://dotfiles.github.io)
* [Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/)

**Warning:** If you want to give these tools a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use these settings unless you know what that entails. Use at your own risk!

## Automated macOS Setup

Configuration of macOS and the installation and configuration of various applications, including those installed with Homebrew, is handled through the [Mac Development Ansible Playbook](https://github.com/greylabel/mac-dev-playbook), and which is controlled and automated by Ansible wherever possible.

The [Mac Development Ansible Playbook](https://github.com/greylabel/mac-dev-playbook) incorporates the installation and updating of a set of dotfiles like this one.

## Install from this repo directly

To use these dotfiles directly, clone or download a copy of this repository. The bootstrapper script will pull in the latest version and copy the files to your home folder.

```bash
git clone git@github.com:greylabel/dotfiles.git && cd dotfiles && source bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
source bootstrap.sh
```

To update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

## Extending and overriding
### Additions to `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing (such as [detecting which version of `ls` is being used](https://github.com/greylabel/dotfiles/blob/master/.aliases#L20)) takes place.

### Add custom commands

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

You could also use `~/.extra` to override settings, functions and aliases from these dotfiles repository. It’s probably better to [fork this repository](https://github.com/greylabel/dotfiles/fork) instead, though.

## Additional and notable configuration

### Git
Create a `~/.gitconfig.local` file for username / github token / etc.

```
[user]

  name = <Your Name>
  email = <you@example.com>
  signingkey = ~/.ssh/id_ed25519.pub

[github]

  user = ghusername

```
