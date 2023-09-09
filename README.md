# Dotfiles

Based on recipes and examples from the below resources, among others...

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

```bash
[user]

  name = <Your Name>
  email = <you@example.com>
  signingkey = ~/.ssh/id_ed25519.pub

[github]

  user = ghusername

```

### SSH

#### Generating a new SSH key pair

> See Github's [Generating a new SSH key and adding it to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) for more information.

Create directory for SSH keys and configuration and set permissions.

```bash
mkdir ~/.ssh && chmod 0700 ~/.ssh
```

Generate a new SSH key.

```bash
ssh-keygen -t ed25519
```

Set permissions.

```bash
chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub
```

#### SSH Configuration

Create and set permissions on the `~/.ssh/config` file.

```bash
touch ~/.ssh/config && chmod 644 ~/.ssh/config
```

Modify the `~/.ssh/config` file to automatically load keys into the ssh-agent and store passphrases in your keychain.

```bash
IgnoreUnknown AddKeysToAgent,UseKeychain

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

#### Adding your SSH key to the ssh-agent

```bash
eval "$(ssh-agent -s)"
```

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Allowed Signers

See:
- https://man7.org/linux/man-pages/man1/ssh-keygen.1.html#ALLOWED_SIGNERS
- https://docs.gitlab.com/ee/user/project/repository/ssh_signed_commits/

Create and set permissions on the `allowed_signers` file.

```bash
touch ~/.ssh/allowed_signers && chmod 644 ~/.ssh/allowed_signers
```

Add an entry with a public key.

```bash
<you@example.com> namespaces="git" <public key>
```

At this point, the new key can be added to GitHub and other cloud services.

#### Add a passphrase to an existing SSH key

Add/replace the passphrase for an existing private key without regenerating the keypair.

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519
```

#### Check SSH key fingerprint

```bash
ssh-keygen -lf ~/.ssh/id_ed25519.pub # SHA256
```

### Directories for source code

Create `Projects` and `Sites` home directories — generally will contain source code and websites, respectively.

```bash
mkdir ~/Projects && chmod u+rwx,go-rwx ~/Projects
```

```bash
mkdir ~/Sites && chmod u+rwx,go-rwx ~/Sites
```

###### ACLs for Projects and Sites

Set ACLs for Projects and Sites to prevent accidental deletion.

```bash
chmod +a "group:everyone deny delete" ~/Projects
```

```bash
chmod +a "group:everyone deny delete" ~/Sites
```

## Homebrew

For reference, the official command to install Homebrew with `curl` is below.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other issue. Run `brew doctor` to see if this is the case.

### Bash from Homebrew

```bash
# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)
```

```bash
# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;
```
