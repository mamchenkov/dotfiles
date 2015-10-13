class git (
	String $home = '/home/leonid',
	String $user_name = 'Leonid Mamchenkov',
	String $user_email = 'leonid@mamchenkov.net',
	String $github_user = 'mamchenkov',
) {

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
		content => template('git/gitconfig.erb'),
	}

	file { "$home/.gitignore":
		ensure => 'present',
		source => 'puppet:///modules/git/gitignore',
	}

}
