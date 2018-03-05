class sqlserveralwayson::config inherits sqlserveralwayson {

	#Network configuration
	dsc_sqlservernetwork{ 'ConfigureSQLNetwork':
		dsc_instancename => 'MSSQLSERVER',
		dsc_protocolname => "tcp",
		dsc_isenabled => true,
		dsc_tcpport => '1433',
		dsc_restartservice => true
	}

	#Windows Firewall configuration
	dsc_sqlwindowsfirewall{'CreateFirewallRules':
		dsc_ensure => 'Present',
		dsc_features => 'SQLENGINE,AS',
		dsc_instancename => 'MSSQLSERVER',
		dsc_sourcepath => $setupdir,
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
	}

	#Disable UAC
	#dsc_xuac{'UACNeverNotifyAndDisableAll':
	#  dsc_setting => 'NeverNotifyAndDisableAll'
	#}

	#Admin access configuration
	dsc_sqlserverlogin{'DomainAdminsLogin':
		dsc_ensure => 'Present',
		dsc_servername => $hostname,
		dsc_instancename => 'MSSQLSERVER',
		dsc_name => "${domainnetbiosname}\\Domain Admins",
		dsc_logintype => 'WindowsGroup',
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
	}

	dsc_sqlserverrole{'AddDomainAdminsSQLSysadmin':
		dsc_ensure => 'Present',
		dsc_serverrolename => 'sysadmin',
		dsc_memberstoinclude => "${domainnetbiosname}\\Domain Admins",
		dsc_servername => $hostname,
		dsc_instancename => 'MSSQLSERVER',
		require => Dsc_sqlserverlogin['DomainAdminsLogin'],
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
	}

	#Service account access configuration. Mandatory for AlwaysOn replica login capability on HADR server endpoint
	dsc_sqlserverlogin{'ServiceAccountLogin':
		dsc_ensure => 'Present',
		dsc_servername => $hostname,
		dsc_instancename => 'MSSQLSERVER',
		dsc_name => "${domainnetbiosname}\\$sqlservicecredential_username",
		dsc_logintype => 'WindowsUser',
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
	}

	#User rights configuration
	dsc_userrightsassignment{ 'PerformVolumeMaintenanceTasks':
		dsc_policy => 'Perform_volume_maintenance_tasks',
		dsc_identity => 'Builtin\Administrators'
	}

	dsc_userrightsassignment{ 'LockPagesInMemory':
		dsc_policy => 'Lock_pages_in_memory',
		dsc_identity => 'Builtin\Administrators'
	}

	#Performances configuration
	dsc_sqlservermaxdop{ 'SetMAXDOP':
		dsc_servername => 'localhost',
		dsc_instancename => 'MSSQLSERVER',
		dsc_maxdop => 0
	}

	#xSQLServerMemory SetMAXDOP{
		#SQLInstanceName = $Configuration.InstallSQL.InstanceName
		#DependsOn = "[xSqlServerSetup]InstallSQL"
		#MaxMemory = $MAXMemory
		#DynamicAlloc = $False
	#}
}
