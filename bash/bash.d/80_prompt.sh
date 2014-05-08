#
# Build shell prompt
# 
# Most of the code is from: https://gist.github.com/293517

# Bash colors from https://wiki.archlinux.org/index.php/Color_Bash_Prompt

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

# Print flag character if current git directory is locally modified
# 
# Used in bash prompt
function __git_dirty {
	git diff --quiet HEAD &>/dev/null 
	[ $? == 1 ] && echo "M"
}

function __git_branch {
	git branch &> /dev/null
	if [ $? -eq 0 ]
	then
		echo ' ('`git branch | grep '^*' | cut -f 2 -d ' '`')'
	fi
}

function smart_pwd {
    local pwdmaxlen=25
    local trunc_symbol=".."
    local dir=${PWD##*/}
    local tmp=""
    pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
    NEW_PWD=${PWD/#$HOME/\~}
    local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
    if [ ${pwdoffset} -gt "0" ]
    then
        tmp=${NEW_PWD:$pwdoffset:$pwdmaxlen}
        tmp=${trunc_symbol}/${tmp#*/}
        if [ "${#tmp}" -lt "${#NEW_PWD}" ]; then
            NEW_PWD=$tmp
        fi
    fi
}

function boldtext {
    echo "\\[\\033[1m\\]"$1"\\[\\033[0m\\]"
}

function bgcolor {
    echo "\\[\\033[48;5;"$1"m\\]"
}

function fgcolor {
    echo "\\[\\033[38;5;"$1"m\\]"
}

function resetcolor {
    echo "\\[\\e[0m\\]"
}

function terminal_title {
	echo "\\[\\033]0;\\u@\\H:\\w\\007\\]"
}

function ssh_flag {
	if [ ! -z "$SSH_CLIENT" ]
	then
		echo "$(bgcolor 126)$(fgcolor 114)[SSH]"
	fi
}

function fancyprompt {
    PROMPT_COMMAND="smart_pwd"

	if [ "$EUID" -eq "0" ]
	then
		PS1="$(terminal_title)$(ssh_flag)$(bgcolor 124)$(fgcolor 114)[$(fgcolor 117)\t$(fgcolor 114)][$(fgcolor 190)\u$(fgcolor 114)@$(fgcolor 190)\h$(fgcolor 114):$(fgcolor 86)\w$(fgcolor 190)\$(__git_branch)$(fgcolor 196)\$(__git_dirty)$(fgcolor 114)]#$(resetcolor) "
	else
		PS1="$(terminal_title)$(ssh_flag)$(bgcolor 17)$(fgcolor 114)[$(fgcolor 117)\t$(fgcolor 114)][$(fgcolor 190)\u$(fgcolor 114)@$(fgcolor 190)\h$(fgcolor 114):$(fgcolor 86)\w$(fgcolor 190)\$(__git_branch)$(fgcolor 196)\$(__git_dirty)$(fgcolor 114)]\$$(resetcolor) "
	fi
}

function dullprompt {
    PROMPT_COMMAND=""
	if [ "$EUID" -eq "0" ]
	then
		PS1="[\t][\u@\h:\w\$(__git_branch)\$(__git_dirty)]# "
	else
		PS1="[\t][\u@\h:\w\$(__git_branch)\$(__git_dirty)]\$ "
	fi
}

case "$TERM" in
xterm-color|xterm-256color|rxvt*|screen*)
        fancyprompt
    ;;
*)
        dullprompt
    ;;
esac

