class git (String $home = '/home/leonid') {

	if $id == 'root' {
		$packages = [
			'git',
			'tig',
		]

		package { $packages:
			ensure => 'latest'
		}
	} else {
		warning("Skipping package installation for non-root user")
	}

	file { "$home/.gitconfig":
		ensure => 'present',
		source => 'puppet:///modules/git/gitconfig',
	}

	file { "$home/.gitignore":
		ensure => 'present',
		source => 'puppet:///modules/git/gitignore',
	}

}
