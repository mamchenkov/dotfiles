node default {

	# Switch home for root user
	if $id == 'root' {
		$home = '/root'
	}
	else {
		$home = "/home/$id"
	}

	class { 'bash': home => $home }
	class { 'vim': home => $home }
	class { 'fonts': home => $home }

	# Identity information is picked up from ~/.identity file
	class { 'git': 
		home => $home,
		user_name => $::git_user_name,
		user_email => $::git_user_email,
		github_user => $::git_github_user,
	}
}
