# 
# Export some useful variables
# 
export PATH=$PATH:$HOME/bin:$HOME/dotfiles/bin
export PAGER=`which --skip-alias less -RFSinX 2> /dev/null`
export EDITOR=`which --skip-alias vim -X 2> /dev/null`
export SVN_EDITOR=$EDITOR
export LC_TIME=en_US
export HISTTIMEFORMAT=" (%F %T) "
export HISTCONTROL=ignoredups:ignorespace
export MOZ_NO_REMOTE=1
export MYSQL_PS1='[\R:\m:\s][\U:\d]> '

# Shorten and simplify cd
export CDPATH=.:~:~/Development/mamchenkov:~/Development/ImpreStyle:~/Development/Exwebris:~/Development:/var/www/html:/var/www/vhosts
# Do not save these commands to history
export HISTIGNORE="bg:fg:h:history"
# Ignore files matching this suffixes from completion
export FIGNORE=".svn"

# When displaying prompt, write previous command to history file so that,
# any new shell immediately gets the history lines from all previous shells.
PROMPT_COMMAND='history -a'
