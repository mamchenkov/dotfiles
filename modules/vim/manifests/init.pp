class vim {

	$packages = [
		'vim-enhanced',
	]

	package { $packages:
		ensure => 'latest'
	}

}
