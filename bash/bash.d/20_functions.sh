#
# Various useful functions
# 

# Check if command exists
# 
# Usage: have fortune && fortune
function have() { 
	type "$1" &> /dev/null; 
}


