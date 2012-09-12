#
# Build shell prompt
# 

# Print flag character if current git directory is locally modified
# 
# Used in bash prompt
function __git_dirty {
	git diff --quiet HEAD &>/dev/null 
	[ $? == 1 ] && echo "M"
}


if [ "$EUID" -eq "0" ]
then
	# Root user gets red background
	RED="\[\033[41;1;31m\]"
	CYAN="\[\033[41;1;36m\]"
	MAGENTA="\[\033[41;1;35m\]"
	BLUE="\[\033[41;34m\]"
	YELLOW="\[\033[41;1;33m\]"
	GREEN="\[\033[41;1;32m\]"
	BLACK_ON_WHITE="\[\033[0m\]"
else
	# Regular user gets blue background
	RED="\[\033[44;1;31m\]"
	CYAN="\[\033[44;1;36m\]"
	MAGENTA="\[\033[44;1;35m\]"
	BLUE="\[\033[44;34m\]"
	YELLOW="\[\033[44;1;33m\]"
	GREEN="\[\033[44;1;32m\]"
	BLACK_ON_WHITE="\[\033[0m\]"
fi

case $TERM in
	xterm*|rxvt*)
		TITLEBAR="\[\033]0;\u@\H:\w\007\]\n"
		;;
	*)
		TITLEBAR=""
		;;
esac

export PROMPT_DIRTRIM=3 # Limit trailing directory components

PS1="${TITLEBAR}${CYAN}[\t][${MAGENTA}\u${CYAN}@${YELLOW}\h${CYAN}:${GREEN}\w${YELLOW}\$(__git_ps1 \" (%s)\")${RED}\$(__git_dirty)${CYAN}]${BLACK_ON_WHITE}\$ "
PS2="${CYAN}[\t][$MAGENTA\u$CYAN@$YELLOW\h${CYAN}:$GREEN\W$CYAN]${BLACK_ON_WHITE}> "
