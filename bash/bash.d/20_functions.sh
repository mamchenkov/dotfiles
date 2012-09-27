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
