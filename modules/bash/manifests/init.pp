class bash (String $home = '/home/leonid') {
	
	if $id == 'root' {
		$packages = [
			'bash',
			'bash-completion',
		]

		package { $packages:
			ensure => 'latest'
		}
	}
	else {
		warning("Skipping package installation for non-root user")
	}

	file { "$home/.bash_logout":
		ensure => 'present',
		source => 'puppet:///modules/bash/bash_logout',
	}

	file { "$home/.bash_profile":
		ensure => 'present',
		source => 'puppet:///modules/bash/bash_profile',
	}

	file { "$home/.bashrc":
		ensure => 'present',
		source => 'puppet:///modules/bash/bashrc',
	}

	file { "$home/.inputrc":
		ensure => 'present',
		source => 'puppet:///modules/bash/inputrc',
	}

}
