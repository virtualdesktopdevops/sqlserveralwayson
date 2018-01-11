class sqlserveralwayson::serviceaccounts inherits sqlserveralwayson {

	#Needed for ActiveDirectory remote management using Powershell
	dsc_windowsfeature{ 'RSAT-AD-Powershell':
		dsc_ensure => 'Present',
		dsc_name => 'RSAT-AD-Powershell'
	}

	#SQL service account creation (Active Directory)
	dsc_xaduser{'SvcSQLAccount':
		dsc_domainname => $domain,
		dsc_domainadministratorcredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		dsc_username => $sqlservicecredential_username,
		dsc_password => {'user' => $sqlservicecredential_username, 'password' => $sqlservicecredential_password},
		dsc_ensure => 'Present',
		require => Dsc_windowsfeature['RSAT-AD-Powershell']
	}

	#Configure MSSQLSvc SPN on SQL service account
	dsc_xadserviceprincipalname{'SvcSQLSPN':
		dsc_account => $sqlservicecredential_username,
		dsc_serviceprincipalname => "MSSQLSvc/${fqdn}",
		dsc_ensure => present,
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		require => Dsc_xaduser['SvcSQLAccount']
	}

	#SQL Agent service account creation (Active Directory)
	dsc_xaduser{'SvcSQLAgentAccount':
		dsc_domainname => $domain,
		dsc_domainadministratorcredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		dsc_username => $sqlagentservicecredential_username,
		dsc_password => {'user' => $sqlagentservicecredential_username, 'password' => $sqlagentservicecredential_password},
		dsc_ensure => 'Present',
		require => Dsc_windowsfeature['RSAT-AD-Powershell']
	}

}
