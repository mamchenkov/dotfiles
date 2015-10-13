class fonts (String $home = '/home/leonid') {

	file { "$home/.fonts":
		ensure => 'directory',
		source => 'puppet:///modules/fonts/fonts',
		recurse => true,
		purge => true,
		mode => '0664',
	}

}
