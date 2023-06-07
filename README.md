# Dotfiles

#### Based on recipes and examples from
* [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
* [Paul Irish](https://github.com/paulirish/dotfiles)
* [dotfiles](https://dotfiles.github.io)
* [Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/)

**Warning:** If you want to give these tools a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

## macOS Setup

Configuration of macOS and installation and configuration of various applications is handled through the  [Mac Development Ansible Playbook](https://github.com/greylabel/mac-dev-playbook).

## Dotfiles

Can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with `~/dotfiles` as a symlink.) The bootstrapper script will pull in the latest version and copy the files to your home folder.

```bash
git clone git@github.com:greylabel/g.files.git && cd dotfiles && source bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing (such as [detecting which version of `ls` is being used](https://github.com/greylabel/g.files/blob/master/.aliases#L18)) takes place.

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

You could also use `~/.extra` to override settings, functions and aliases from these dotfiles repository. It’s probably better to [fork this repository](https://github.com/greylabel/g.files/fork) instead, though.

## Configuration

### Git
Create and use `~/.gitconfig.local` file for username / github token / etc.

```
[user]

  name = Grant Gaudet
  email = grant@greylabel.net

[github]

  user = greylabel
```

## Go
See `.exports`.

```bash
export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
```

## PHP

See `.bash_profile`.

`PATH="/usr/local/opt/php@8.2/bin:$PATH"`
`PATH="/usr/local/opt/php@8.2/sbin:$PATH"`

### Composer for PHP

See `.exports`.

`export COMPOSER_PROCESS_TIMEOUT=2000`
`export COMPOSER_MEMORY_LIMIT=-1`
