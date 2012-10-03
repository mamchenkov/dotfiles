# Bash Directory Bookmarks
# From: http://habrahabr.ru/post/151484/#habracut                                                                                                                                        
alias m1='alias g1="cd `pwd`"'                                                                                                                                          
alias m2='alias g2="cd `pwd`"'                                                                                                                                          
alias m3='alias g3="cd `pwd`"'                                                                                                                                          
alias m4='alias g4="cd `pwd`"'                                                                                                                                          
alias m5='alias g5="cd `pwd`"'                                                                                                                                          
alias m6='alias g6="cd `pwd`"'                                                                                                                                          
alias m7='alias g7="cd `pwd`"'                                                                                                                                          
alias m8='alias g8="cd `pwd`"'                                                                                                                                          
alias m9='alias g9="cd `pwd`"'                                                                                                                                          
alias mdump='alias|grep -e "alias g[0-9]"|grep -v "alias m" > ~/.bookmarks'                                                                                             
alias mload='if [ -e ~/.bookmarks ] ; then source ~/.bookmarks ; fi'
alias ah='(echo;alias | grep  "g[0-9]" | grep -v "m[0-9]" | cut -d" " -f "2,3"| sed "s/=/   /" | sed "s/cd //";echo)' 

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

# Mysql with fancy pager
alias mysql="mysql --pager='nice_tables | grcat dotfiles/etc/grcat.conf | less -RFSinX'"

alias head='head -n $((${LINES:-12}-2))' #as many as possible without scrolling
alias tail='tail -n $((${LINES:-12}-2)) -s.1' #Likewise, also more responsive -f

# what most people want from od (hexdump)
alias hd='od -Ax -tx1z -v'

# Leaving
alias quit="exit"
alias bye="exit"
