class git (
	$home = '/home/leonid',
	$user_name = 'Leonid Mamchenkov',
	$user_email = 'leonid@mamchenkov.net',
	$github_user = 'mamchenkov',
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
