#!/bin/bash

# Automatic git commits of changes in /etc on logout of root user
# Original: http://grahamweldon.com/posts/view/automatic-commits-for-server-configuration-files

if [ "$EUID" -eq "0" ]
then
	if [ ! -d /etc/.git ]; then
		cd /etc
		git init
		git config user.name "Server Administrator"
		git config user.email "root@localhost"
	fi
	git \
		--work-tree=/etc \
		--git-dir=/etc/.git \
		add . >/dev/null 2>&1
	git \
		--work-tree=/etc \
		--git-dir=/etc/.git \
		commit -a -m "Logout commit `date +%c`" >/dev/null 2>&1
fi

# Save directory bookmarks for the next time
have mdump && mdump
