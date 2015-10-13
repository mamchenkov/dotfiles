class bash (String $home = '/home/leonid') {
	
	if $id == 'root' {
		$packages = [
			'ack',
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

	file { "$home/bin":
		ensure => 'directory',
		source => 'puppet:///modules/bash/bin',
		recurse => true,
		purge => true,
		mode => '0775',
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

	file { "$home/.ackrc":
		ensure => 'present',
		source => 'puppet:///modules/bash/ackrc',
	}

	file { "$home/.grcatrc":
		ensure => 'present',
		source => 'puppet:///modules/bash/grcatrc',
	}

}
