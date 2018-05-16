# .bashrc
#
# Lots and lots of pieces were borrowed from Advanced Bash Scripting
# Guide and the rest of the Web.  Thanks to all who helped along the
# way.


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#
# Switch terminal to support 256 colors, if possible
# 
case $TERM in
	xterm*)
		# Check if the terminal supports 256 colors
		if [ -e /usr/share/terminfo/x/xterm-256color ]; then
			export TERM='xterm-256color'
		else
			export TERM='xterm-color'
		fi
		;;
	*)
		export TERM='linux'
		;;
esac

#
# Various useful functions
# 

# Check if command exists
# 
# Usage: have fortune && fortune
function have() { 
	type "$1" &> /dev/null; 
}

# Show top 10 used commands in history
function top10() {
	history | awk '{a[$4]++ } END{for(i in a){print a[i] " " i}}'|sort -rn |head -n 10
}

# 
# Export some useful variables
# 
export PATH=$PATH:./bin/:./vendor/bin:$HOME/bin:$HOME/dotfiles/bin
export PAGER="$(which --skip-alias less) -RFSinX"
export EDITOR="$(which --skip-alias vim) -X"
export LC_TIME=en_US
export HISTTIMEFORMAT="%F %T"
export HISTCONTROL=ignoredups:ignorespace
export MOZ_NO_REMOTE=1
export MYSQL_PS1='[\R:\m:\s][\U:\d]> '

# Shorten and simplify cd
export CDPATH=.:~:~/Work:~/Development:/var/www/html:/var/www/vhosts
# Do not save these commands to history
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:h:history:clear"
# Ignore files matching this suffixes from completion
export FIGNORE="$FIGNORE:.svn"
# Automatically trim long paths in prompt (requries Bash 4.x)
export PROMPT_DIRTRIM=2

# When displaying prompt, write previous command to history file so that,
# any new shell immediately gets the history lines from all previous shells.
PROMPT_COMMAND='history -a'

# 
# Aliases
# 
alias vi="$EDITOR"
alias vim="$EDITOR"
alias ll="ls -al --group-directories-first"
alias df="df -kTh"
alias du="du -kh"
alias ..="cd ..;"
alias ...="cd ..;"
alias h="history"
alias traceroute="traceroute -I"
alias who="who -HT"
alias mkdir="mkdir -p"
alias path="echo -e ${PATH//:/\\n}"

# Mysql with fancy pager
alias mysql="mysql --pager='nice_tables | grcat ~/.grcatrc | $PAGER'"

alias head='head -n $((${LINES:-12}-2))' #as many as possible without scrolling
alias tail='tail -n $((${LINES:-12}-2)) -s.1' #Likewise, also more responsive -f

# what most people want from od (hexdump)
alias hd='od -Ax -tx1z -v'

# Leaving
alias quit="exit"
alias bye="exit"

# 
# Less pager colors for man pages
# Source:
# http://unix.stackexchange.com/questions/119/colors-in-man-pages/147#147
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_ZN=$(tput ssubm)
export LESS_TERMCAP_ZV=$(tput rsubm)
export LESS_TERMCAP_ZO=$(tput ssupm)
export LESS_TERMCAP_ZW=$(tput rsupm)

# 
# Set some shell options
# 
ulimit -S -c 0 			# No core dump files

set -o notify 			# Notify when jobs in background terminate
#set -o noclobber 		# Prevent overwriting files by rediction
#set -o nounset 		# Errors if using undefined variable
set -o vi 				# Vi-style command editing

# See all with: shopt -p
shopt -s cdable_vars 	# directory to cd is in variable
shopt -s autocd 		# Prepend cd to directory names automatically
shopt -s dirspell 		# correct spelling mistakes during tab completion
shopt -s cdspell 		# correct minor spelling mistakes
shopt -s checkhash 		# check hash for the command,before path search
shopt -s checkwinsize 	# check window size after every command
shopt -s cmdhist 		# save multiline commands as one history item
shopt -s histappend histreedit histverify # better history management

shopt -u mailwarn
unset MAILCHECK

# Load git prompt script
source ~/bin/git-prompt.sh

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

function fancyprompt {
	local RETVAL=$?

	# Last command successful - green, otherwise red
	if [ "$RETVAL" -eq "0" ]
	then
		LAST_COLOR=$Green
		LAST_SYMBOL="\\$"
	else
		LAST_COLOR=$Red
		LAST_SYMBOL="\\$"
	fi

	# Root is bright red, everyone else is green
	if [ "$EUID" -eq "0" ]
	then
		USER_COLOR=$IRed
		PROMPT_COLOR=$IRed
		FEEL_COLOR=$IBlack
	else
		USER_COLOR=$Green
		PROMPT_COLOR=$IWhite
		FEEL_COLOR=$IBlack
	fi

	# Load average green, or bright yellow, or bright red
	CPUS=$(grep -c vendor_id /proc/cpuinfo)
	CPUS=$(printf "%.0f" $CPUS)
	read ONE REST < /proc/loadavg
	LOAD=$(printf "%.0f" $ONE)
	if [ "$LOAD" -lt "$CPUS" ]
	then 
		LOAD_COLOR=$Green
	elif [ "$LOAD" -eq "$CPUS" ]
	then 
		LOAD_COLOR=$IYellow
	else 
		LOAD_COLOR=$IRed
	fi

	# localhost|localdomain hostnames are green, as well as anything with .ppl. (people)
	if [[ $HOSTNAME =~ "localhost" || $HOSTNAME =~ "localdomain" || $HOSTNAME =~ ".ppl." ]]
	then
		HOST_COLOR=$Green
	# .com|.org|.net hostnames are bright red
	elif [[ $HOSTNAME =~ ".com" || $HOSTNAME =~ ".org" || $HOSTNAME =~ ".net" ]]
	then
		HOST_COLOR=$IRed
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
			GIT_DIRTY="$IRed$GIT_DIRTY"
		fi
		# Bright yellow for master branch, purple for everything else
		if [ "$GIT_BRANCH" == "master" ]
			then
				GIT_BRANCH_COLOR=$IYellow
			else
				GIT_BRANCH_COLOR=$Purple
		fi
		GIT_BRANCH="$FEEL_COLOR⑂${GIT_BRANCH_COLOR}$GIT_BRANCH$GIT_DIRTY$FEEL_COLOR"
	fi


	# Terminal title and new online separator for each prompt
	PS1="$(terminal_title)\n"
	# Time with color by load
	PS1="$PS1$FEEL_COLOR[$LOAD_COLOR\t$FEEL_COLOR|"
	# User with color by username at host with color by hostname
	PS1="$PS1$USER_COLOR\u$FEEL_COLOR@$HOST_COLOR\H$FEEL_COLOR:"
	# Current folder and git branch with color by branch name and modified
	PS1="$PS1$IBlue\w$GIT_BRANCH$FEEL_COLOR]"
	# Prompt with color by last status
	PS1="$PS1${LAST_COLOR}${LAST_SYMBOL}${FEEL_COLOR} $Color_Off"

	# Cleanup
	unset FEEL_COLOR USER_COLOR HOST_COLOR LOAD_COLOR LAST_COLOR PROMPT_COLOR 
}

function dullprompt {
	if [ "$EUID" -eq "0" ]
	then
		PS1="[\t][\u@\h:\w\$(__git_branch)\$(__git_dirty)]\\$ "
	else
		PS1="[\t][\u@\h:\w\$(__git_branch)\$(__git_dirty)]\\$ "
	fi
}

case "$TERM" in
xterm-color|xterm-256color|rxvt*|screen*)
		# Update history on each command
        PROMPT_COMMAND="fancyprompt && history -a"
    ;;
*)
		# Update history on each command
        PROMPT_COMMAND="dullprompt && history -a"
    ;;
esac

# 
# Last bits
# 

# Show host information
#have whereami && whereami

# Show thought of the day
#have fortune && echo Thought of the day: && fortune -s && echo

