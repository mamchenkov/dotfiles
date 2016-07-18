DOTFILES
========

This repository contains most of my "movable" setup.  Mostly these are configurations
for bash shell, git version control, and Vim text editor.

Installation
------------

Clone the repository:

```
$ git clone https://github.com/mamchenkov/dotfiles.git
$ cd dotfiles
```

**DANGER** This will overwrite your current dot files!

Run Ansible

```
$ ansible-playbook all.yml --ask-sudo-pass 
```

You can skip package installations and/or network operations (Vim plugins cloning, etc)
with something like:

```
$ ansible-playbook all.yml --skip-tags="network,packages"
```

If you want to install/configure only certain parts, replace `all.yml` in the commands
above with of the other playbooks.

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
3.	For root user, an automatically initialized local git repository in /etc folder, with automatic commits of all
	changes upon logout.
4.  Colors for man pages.

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

*  MySQL prompt that includes current user, host, and selected database.

Feedback
--------

If you need to get in touch, send me an email to leonid@mamchenkov.net .  Alternatively, you can send in
comments and pull requests for the project on GitHub at https://github.com/mamchenkov/dotfiles .

Patches welcome! ;)

