class vim (String $home = '/home/leonid') {

	if $id == 'root' {
		$packages = [
			'vim-enhanced',
		]

		package { $packages:
			ensure => 'latest'
		}
	} else {
		warning("Skipping package installation for non-root user")
	}

}
