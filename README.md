DOTFILES
========

This repository contains most of my "movable" setup.  Mostly these are configurations
for bash shell, git version control, and Vim text editor.

Installation
------------

Download and run the install script, which will fetch all the necessary modules and create
all the necessary links.  Switching to your home directory and backing up your current setup
is a good idea, since:

1. The installation script will create symlinks in your CURRENT directory.
2. The installation script will remove necessary files in your CURRENT directory.


```
cd ~
wget -O - https://raw.github.com/mamchenkov/dotfiles/master/bin/dotfiles-install.sh | /bin/bash
source .bashrc
```

Known Issues
------------

### Missing bash completions

```
-bash: __git_ps1: command not found
```

If you see the above message after installation, you are missing bash completions.  Gladly, the issue
is easily solved by installing bash-completion package.  On Fedora / Red Hat / CentOS do the following:

```
$ sudo yum install bash-completion
```

Once the package is installed, exit your current bash shell and start a new instance.

### Missing LWP::UserAgent perl module

```
Can't locate LWP/UserAgent.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl
/usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at /root/dotfiles/bin/whatismyip line 11.
BEGIN failed--compilation aborted at /root/dotfiles/bin/whatismyip line 11.
```

If you see the above message upon login, your system is missing LWP::UserAgent perl module, which is used by whereami script
to establish your external IP address.  The easiest way to install it is via CPAN, like so:

```
$ sudo cpan
cpan> install LWP::UserAgent
```
