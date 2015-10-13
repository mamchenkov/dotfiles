class vim ($home = '/home/leonid') {

	if $id == 'root' {
		$packages = [
			'ctags',
			'vim-enhanced',
		]

		package { $packages:
			ensure => 'latest'
		}
	} else {
		warning("Skipping package installation for non-root user")
	}

	file { "$home/.vim":
		ensure => 'directory',
	}

	file { "$home/.vim/autoload":
		ensure => 'directory',
		source => 'puppet:///modules/vim/vim/autoload',
		recurse => true,
		purge => true,
		mode => 'a+rX,ug+w,o-w',
		require => File["$home/.vim"],
	}

	file { "$home/.vim/bundle":
		ensure => 'directory',
		recurse => false,
		purge => false,
		mode => 'a+rX,ug+w,o-w',
		require => File["$home/.vim"],
	}

	file { "$home/.vim/sessions":
		ensure => 'directory',
		recurse => false,
		purge => false,
		mode => 'a+rX,ug+w,o-w',
		require => File["$home/.vim"],
	}

	file { "$home/.vim/undodir":
		ensure => 'directory',
		recurse => false,
		purge => false,
		mode => 'a+rX,ug+w,o-w',
		require => File["$home/.vim"],
	}

	file { "$home/.vimrc":
		ensure => 'present',
		source => 'puppet:///modules/vim/vimrc',
	}

	vcsrepo { "$home/.vim/bundle/tagbar":
		ensure => latest,
		provider => git,
		source => 'https://github.com/majutsushi/tagbar.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/closetag":
		ensure => latest,
		provider => git,
		source => 'https://github.com/docunext/closetag.vim.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/nerdcommenter":
		ensure => latest,
		provider => git,
		source => 'https://github.com/scrooloose/nerdcommenter.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/nerdtree":
		ensure => latest,
		provider => git,
		source => 'https://github.com/scrooloose/nerdtree.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/better-css-syntax":
		ensure => latest,
		provider => git,
		source => 'https://github.com/vim-scripts/Better-CSS-Syntax-for-Vim.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/syntastic":
		ensure => latest,
		provider => git,
		source => 'https://github.com/scrooloose/syntastic.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/javascript":
		ensure => latest,
		provider => git,
		source => 'https://github.com/pangloss/vim-javascript.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/colorschemes":
		ensure => latest,
		provider => git,
		source => 'https://github.com/flazz/vim-colorschemes.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/phpdocumentor":
		ensure => latest,
		provider => git,
		source => 'https://github.com/vim-scripts/PDV--phpDocumentor-for-Vim.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/search-complete":
		ensure => latest,
		provider => git,
		source => 'https://github.com/vim-scripts/SearchComplete.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/php":
		ensure => latest,
		provider => git,
		source => 'https://github.com/vim-scripts/php.vim--Garvin.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/php-indent":
		ensure => latest,
		provider => git,
		source => 'https://github.com/2072/PHP-Indenting-for-VIm.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/smart-tabs":
		ensure => latest,
		provider => git,
		source => 'https://github.com/vim-scripts/Smart-Tabs.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/jquery":
		ensure => latest,
		provider => git,
		source => 'https://github.com/vim-scripts/jQuery.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/gist":
		ensure => latest,
		provider => git,
		source => 'https://github.com/mattn/gist-vim.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/webapi":
		ensure => latest,
		provider => git,
		source => 'https://github.com/mattn/webapi-vim.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/gitgutter":
		ensure => latest,
		provider => git,
		source => 'https://github.com/airblade/vim-gitgutter.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/matchit":
		ensure => latest,
		provider => git,
		source => 'https://github.com/tmhedberg/matchit.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/supertab":
		ensure => latest,
		provider => git,
		source => 'https://github.com/ervandew/supertab.git',
		require => File["$home/.vim/bundle"],
	}

	vcsrepo { "$home/.vim/bundle/base16":
		ensure => latest,
		provider => git,
		source => 'https://github.com/chriskempson/base16-vim.git',
		require => File["$home/.vim/bundle"],
	}

}
