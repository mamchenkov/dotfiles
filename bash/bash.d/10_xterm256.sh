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
		;;
esac
