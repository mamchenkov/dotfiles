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

If you have cloned the repository and want to use your own username and/or branch, you can
specify that as arguments to dotfiles-install.sh script.  The defaults values are:

```
cd ~
wget -O - https://raw.github.com/mamchenkov/dotfiles/master/bin/dotfiles-install.sh mamchenkov master | /bin/bash
source .bashrc
```

Use your GitHub username instead of 'mamchenkov' and your desired branch instead of 'master'.

Known Issues
------------

### Untracked changes in vim submodules

When you run Vim, documentation for plugins is automatically generated, which results in doc/tags files created all
around submodules.  This annoyingly is being reported by git.  To solve this issue, you can update submodules to not
report untracked files changes.  Remove all those doc/tags files and run the following command:

```
for s in `git submodule  --quiet foreach 'echo $name'` ; do git config submodule.$s.ignore untracked ; done
```

Thanks to: http://stackoverflow.com/questions/4343544/generating-tags-to-different-location-by-pathogen

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

Features
--------

Here is a brief overview of some of the features hidden deep in these dotfiles.

### Bash shell

1.	Colorful prompt, featuring current time, username, hostname, working directory, as wel as Git information.
	When working whitin in git repository, the prompt will show the name of the current git branch, as well as 
	a little "M" flag, if the working directory is dirty (if it was modified).  The prompt will also change
	background color from blue to red, when working as root user, provided you have installed dotfiles for both
	your normal user and root.
2.	Support for 256 color terminals.
3.	System information on shell start, including hostname, distribution name and version, IP address, load average,
	number of current processes, available and total disk space, and simplified uptime.
4.	For root user, an automatically initialized local git repository in /etc folder, with automatic commits of all
	changes upon logout.
5.  Colors for man pages.

### Git version control

1.	Color support in console git client.
2.	Several handy git aliases to make frequent operations faster ("st" instead of "status", "co" instead of "checkout",
	etc).
3.	Several handy git aliases to make long lists of parameters much shorter ("lol", "changelog", etc).

### Vim text editor

1.	Modular configuration of plugins with Pathogen plugin and git submodules.
2.  Collection of plugins for web developers (PHP Indent, NERDTree, Syntastic, Tagbar, Gist, etc).
3.	Support for 256 colors in console.

### Miscelanous

1. 	Easier installer, which can also be used to update the setup and all the symlinks.
2.  MySQL prompt that includes current user, host, and selected database.

Feedback
--------

If you need to get in touch, send me an email to leonid@mamchenkov.net .  Alternatively, you can send in
comments and pull requests for the project on GitHub at https://github.com/mamchenkov/dotfiles .

Patches welcome! ;)

