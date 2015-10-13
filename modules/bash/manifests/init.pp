class bash {

	$packages = [
		'bash',
		'bash-completion',
	]

	package { $packages:
		ensure => 'latest'
	}

}
