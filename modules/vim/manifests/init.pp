class vim (String $home = '/home/leonid') {

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

}
