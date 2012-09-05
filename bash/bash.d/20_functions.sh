#
# Various useful functions
# 

# Check if command exists
# 
# Usage: have fortune && fortune
function have() { 
	type "$1" &> /dev/null; 
}

# Print flag character if current git directory is locally modified
# 
# Used in bash prompt
function __git_dirty {
	git diff --quiet HEAD &>/dev/null 
	[ $? == 1 ] && echo "M"
}
