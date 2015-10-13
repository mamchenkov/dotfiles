node default {

	if $id == 'root' {
		$home = '/root'
	}
	else {
		$home = "/home/$id"
	}

	class { 'bash': home => $home }
	class { 'vim': home => $home }
	class { 'git': home => $home }
	class { 'fonts': home => $home }
}
