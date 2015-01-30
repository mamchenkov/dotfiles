#
# Build shell prompt
# 
# Most of the code is from: https://gist.github.com/293517

# Bash colors from https://wiki.archlinux.org/index.php/Color_Bash_Prompt

# Reset
Color_Off="\[\e[0m\]"       # Text Reset

# Regular Colors
Black="\[\e[0;30m\]"        # Black
Red="\[\e[0;31m\]"          # Red
Green="\[\e[0;32m\]"        # Green
Yellow="\[\e[0;33m\]"       # Yellow
Blue="\[\e[0;34m\]"         # Blue
Purple="\[\e[0;35m\]"       # Purple
Cyan="\[\e[0;36m\]"         # Cyan
White="\[\e[0;37m\]"        # White

# Bold
BBlack="\[\e[1;30m\]"       # Black
BRed="\[\e[1;31m\]"         # Red
BGreen="\[\e[1;32m\]"       # Green
BYellow="\[\e[1;33m\]"      # Yellow
BBlue="\[\e[1;34m\]"        # Blue
BPurple="\[\e[1;35m\]"      # Purple
BCyan="\[\e[1;36m\]"        # Cyan
BWhite="\[\e[1;37m\]"       # White

# Underline
UBlack="\[\e[4;30m\]"       # Black
URed="\[\e[4;31m\]"         # Red
UGreen="\[\e[4;32m\]"       # Green
UYellow="\[\e[4;33m\]"      # Yellow
UBlue="\[\e[4;34m\]"        # Blue
UPurple="\[\e[4;35m\]"      # Purple
UCyan="\[\e[4;36m\]"        # Cyan
UWhite="\[\e[4;37m\]"       # White

# Background
On_Black="\[\e[40m\]"       # Black
On_Red="\[\e[41m\]"         # Red
On_Green="\[\e[42m\]"       # Green
On_Yellow="\[\e[43m\]"      # Yellow
On_Blue="\[\e[44m\]"        # Blue
On_Purple="\[\e[45m\]"      # Purple
On_Cyan="\[\e[46m\]"        # Cyan
On_White="\[\e[47m\]"       # White

# High Intensity
IBlack="\[\e[0;90m\]"       # Black
IRed="\[\e[0;91m\]"         # Red
IGreen="\[\e[0;92m\]"       # Green
IYellow="\[\e[0;93m\]"      # Yellow
IBlue="\[\e[0;94m\]"        # Blue
IPurple="\[\e[0;95m\]"      # Purple
ICyan="\[\e[0;96m\]"        # Cyan
IWhite="\[\e[0;97m\]"       # White

# Bold High Intensity
BIBlack="\[\e[1;90m\]"      # Black
BIRed="\[\e[1;91m\]"        # Red
BIGreen="\[\e[1;92m\]"      # Green
BIYellow="\[\e[1;93m\]"     # Yellow
BIBlue="\[\e[1;94m\]"       # Blue
BIPurple="\[\e[1;95m\]"     # Purple
BICyan="\[\e[1;96m\]"       # Cyan
BIWhite="\[\e[1;97m\]"      # White

# High Intensity backgrounds
On_IBlack="\[\e[0;100m\]"   # Black
On_IRed="\[\e[0;101m\]"     # Red
On_IGreen="\[\e[0;102m\]"   # Green On_IYellow='\e[0;103m'  # Yellow
On_IBlue="\[\e[0;104m\]"    # Blue
On_IPurple="\[\e[0;105m\]"  # Purple
On_ICyan="\[\e[0;106m\]"    # Cyan
On_IWhite="\[\e[0;107m\]"   # White

# Print flag character if current git directory is locally modified
# 
# Used in bash prompt
function __git_dirty {
	git diff --quiet HEAD &>/dev/null 
	[ $? == 1 ] && echo "+"
}

function __git_branch {
	GIT_BRANCH=$(git branch 2>/dev/null | grep '^*' | cut -f 2 -d ' ')
	if [ ! -z "$GIT_BRANCH" ]
	then
		echo "$GIT_BRANCH"
	fi

	# Cleanup
	unset GIT_BRANCH
}

function terminal_title {
	echo "\\[\\033]0;\\u@\\H:\\w\\007\\]"
}

function ssh_flag {
	if [ ! -z "$SSH_CLIENT" ]
	then
		echo "[SSH]"
	fi
}

function fancyprompt {
	local RETVAL=$?

	# Last command successful - green, otherwise bright red
	if [ "$RETVAL" -eq "0" ]
	then
		LAST_COLOR=$IGreen
		LAST_SYMBOL=":)"
	else
		LAST_COLOR=$IRed
		LAST_SYMBOL=":("
	fi

	# Root is bright red, everyone else is green
	if [ "$EUID" -eq "0" ]
	then
		USER_COLOR=$BIRed
		PROMPT_COLOR=$BIRed
		FEEL_COLOR=$IRed
	else
		USER_COLOR=$IGreen
		PROMPT_COLOR=$IWhite
		FEEL_COLOR=$IWhite
	fi

	# Load average green, or bright yellow, or bright red
	CPUS=$(grep -c vendor_id /proc/cpuinfo)
	CPUS=$(printf "%.0f" $CPUS)
	read ONE REST < /proc/loadavg
	LOAD=$(printf "%.0f" $ONE)
	if [ "$LOAD" -lt "$CPUS" ]
	then 
		LOAD_COLOR=$IGreen
	elif [ "$LOAD" -eq "$CPUS" ]
	then 
		LOAD_COLOR=$BIYellow
	else 
		LOAD_COLOR=$BIRed
	fi

	# .com|.org|.net hostnames are bright red
	if [[ $HOSTNAME =~ ".com" || $HOSTNAME =~ ".org" || $HOSTNAME =~ ".net" ]]
	then
		HOST_COLOR=$IYellow
	# localhost|localdomain hostnames are green
	elif [[ $HOSTNAME =~ "localhost" || $HOSTNAME =~ "localdomain" ]]
	then
		HOST_COLOR=$IGreen
	# everything else yellow
	else
		HOST_COLOR=$IYellow
	fi

	GIT_BRANCH=$(__git_branch)
	if [ ! -z "$GIT_BRANCH" ]
	then
		GIT_DIRTY=$(__git_dirty)
		if [ ! -z "$GIT_DIRTY" ]
		then
			GIT_DIRTY="$BIRed$GIT_DIRTY"
		fi
		# Bright yellow for master branch, purple for everything else
		if [ "$GIT_BRANCH" == "master" ]
			then
				GIT_BRANCH_COLOR=$BIYellow
			else
				GIT_BRANCH_COLOR=$Purple
		fi
		GIT_BRANCH="$FEEL_COLOR⑂ ${GIT_BRANCH_COLOR}$GIT_BRANCH$GIT_DIRTY$FEEL_COLOR"
	fi


	PS1="$(terminal_title)\n"
	PS1="$PS1$BIPurple$(ssh_flag)"
	PS1="$PS1$FEEL_COLOR┌[$BIWhite\d \t$FEEL_COLOR] "
	PS1="$PS1[$USER_COLOR\u$FEEL_COLOR@$HOST_COLOR\H$FEEL_COLOR] "
	PS1="$PS1[load:$LOAD_COLOR$ONE$FEEL_COLOR] "
	PS1="$PS1[procs:$FEEL_COLOR$(ps aux | wc -l)$FEEL_COLOR]\n"
	PS1="$PS1├[$IBlue$(pwd) $GIT_BRANCH$FEEL_COLOR]\n"
	PS1="$PS1└[${LAST_COLOR}${LAST_SYMBOL}${FEEL_COLOR}]$PROMPT_COLOR\\$ $Color_Off"

	# Cleanup
	unset FEEL_COLOR USER_COLOR HOST_COLOR LOAD_COLOR LAST_COLOR PROMPT_COLOR 
}

function dullprompt {
    PROMPT_COMMAND=""
	if [ "$EUID" -eq "0" ]
	then
		PS1="[\t][\u@\h:\w\$(__git_branch)\$(__git_dirty)]\\$ "
	else
		PS1="[\t][\u@\h:\w\$(__git_branch)\$(__git_dirty)]\\$ "
	fi
}

case "$TERM" in
xterm-color|xterm-256color|rxvt*|screen*)
        PROMPT_COMMAND=fancyprompt
    ;;
*)
        PROMPT_COMMAND=dullprompt
    ;;
esac

