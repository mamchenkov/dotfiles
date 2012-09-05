# 
# Set some shell options
# 
ulimit -S -c 0 			# No core dump files

set -o notify 			# Notify when jobs in background terminate
#set -o noclobber 		# Prevent overwriting files by rediction
#set -o nounset 		# Errors if using undefined variable
set -o vi 				# Vi-style command editing


shopt -s cdable_vars 	# directory to cd is in variable
shopt -s cdspell 		# correct minor spelling mistakes
shopt -s checkhash 		# check hash for the command,before path search
shopt -s checkwinsize 	# check window size after every command
shopt -s cmdhist 		# save multiline commands as one history item
shopt -s histappend histreedit histverify # better history management

shopt -u mailwarn
unset MAILCHECK
