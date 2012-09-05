# 
# Aliases
# 
alias vi="vim"
alias ll="ls -al --group-directories-first"
alias df="df -kTh"
alias du="du -kh"
alias ..="cd ..;"
alias ...="cd ..;"
alias h="history"
alias p="phing"
alias traceroute="traceroute -I"
alias who="who -HT"
alias mkdir="mkdir -p"
alias path="echo -e ${PATH//:/\\n}"

alias head='head -n $((${LINES:-12}-2))' #as many as possible without scrolling
alias tail='tail -n $((${LINES:-12}-2)) -s.1' #Likewise, also more responsive -f

# what most people want from od (hexdump)
alias hd='od -Ax -tx1z -v'

# Leaving
alias quit="exit"
alias bye="exit"
