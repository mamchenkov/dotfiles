#
# Download and install dotfiles.
# 
# SAFETY NOTE : installation is done in the CURRENT directory
# COMPATIBILITY NOTE: commands are running in the CURRENT shell

#
# Get dotfiles, if they aren't already here
# 
if [ ! -d "dotfiles" ]
then
	git clone git://github.com/mamchenkov/dotfiles.git dotfiles
fi

#
# Run the update script
# 
dotfiles/bin/dotfiles-update.sh
