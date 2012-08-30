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
# Get all the submodules
# 
cd dotfiles
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

rm -f .gitconfig
ln -s dotfiles/misc/gitconfig .gitconfig

rm -f .vimrc
ln -s dotfiles/vim/vimrc .vimrc

rm -rf .vim
ln -s dotfiles/vim .vim

