#
# Build shell prompt
# 
# Most of the code is from: https://gist.github.com/293517

# Print flag character if current git directory is locally modified
# 
# Used in bash prompt
function __git_dirty {
	git diff --quiet HEAD &>/dev/null 
	[ $? == 1 ] && echo "M"
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

function fancyprompt {
    PROMPT_COMMAND="smart_pwd"

	if [ "$EUID" -eq "0" ]
	then
		PS1="$(bgcolor 196)$(fgcolor 114)[$(fgcolor 117)\t$(fgcolor 114)][$(fgcolor 190)\u$(fgcolor 114)@$(fgcolor 190)\h$(fgcolor 114):$(fgcolor 86)\w$(fgcolor 190)\$(__git_ps1 \" (%s)\")$(fgcolor 196)\$(__git_dirty)$(fgcolor 114)]#$(resetcolor) "
	else
		PS1="$(bgcolor 17)$(fgcolor 114)[$(fgcolor 117)\t$(fgcolor 114)][$(fgcolor 190)\u$(fgcolor 114)@$(fgcolor 190)\h$(fgcolor 114):$(fgcolor 86)\w$(fgcolor 190)\$(__git_ps1 \" (%s)\")$(fgcolor 196)\$(__git_dirty)$(fgcolor 114)]\$$(resetcolor) "
	fi
}

function dullprompt {
    PROMPT_COMMAND=""
	if [ "$EUID" -eq "0" ]
	then
		PS1="[\t][\u@\h:\w\$(__git_ps1 \" (%s)\")\$(__git_dirty)]# "
	else
		PS1="[\t][\u@\h:\w\$(__git_ps1 \" (%s)\")\$(__git_dirty)]\$ "
	fi
}

case "$TERM" in
xterm-color|xterm-256color|rxvt*|screen-256color)
        fancyprompt
    ;;
*)
        dullprompt
    ;;
esac

