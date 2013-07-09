#
# Download and install dotfiles.
# 
# SAFETY NOTE : installation is done in the CURRENT directory
# COMPATIBILITY NOTE: commands are running in the CURRENT shell

USER=$1
BRANCH=$2

if [ -z "$USER" ]
then
	USER=mamchenkov
fi

if [ -z "$BRANCH" ]
then
	BRANCH=master
fi

echo $USER $BRANCH
exit 1

#
# Get dotfiles, if they aren't already here
# 
if [ ! -d "dotfiles" ]
then
	echo "Getting dotfiles via git protocol"
	git clone git://github.com/$USER/dotfiles.git dotfiles
fi

if [ ! -d "dotfiles" ]
then
	echo "Getting dotfiles via ssh protocol"
	git clone git@github.com:$USER/dotfiles.git dotfiles
fi

if [ ! -d "dotfiles" ]
then
	echo "Getting dotfiles via http protocol"
	git clone https://github.com/$USER/dotfiles.git dotfiles
fi

#
# Before removing everything, make sure the dotfiles are here
#
if [ ! -d "dotfiles" ]
then
	echo "Failed to fetch dotfiles. Dying ..."
	exit 1
fi

#
# Get all the submodules
# 
cd dotfiles
git checkout $BRANCH
git pull
git submodule init
git submodule update
cd ..

#
# Replace current files with symlinks to dotfiles
# 
rm -f .bashrc
ln -s dotfiles/bash/bashrc .bashrc

rm -f .bash_profile
ln -s dotfiles/bash/bash_profile .bash_profile

rm -f .bash_logout
ln -s dotfiles/bash/bash_logout .bash_logout

rm -f .inputrc
ln -s dotfiles/bash/inputrc .inputrc

rm -f .ackrc
ln -s dotfiles/misc/ackrc .ackrc

rm -f .gitconfig
ln -s dotfiles/misc/gitconfig .gitconfig

rm -f .vimrc
ln -s dotfiles/vim/vimrc .vimrc

rm -rf .vim
ln -s dotfiles/vim .vim

rm -rf .fonts
ln -s dotfiles/fonts .fonts

#
# Source .bashrc into current shell
#
source .bashrc
