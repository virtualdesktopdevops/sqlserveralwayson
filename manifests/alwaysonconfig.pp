class sqlserveralwayson::alwaysonconfig inherits sqlserveralwayson {

  #Enable AlwaysOn on MSSQL service
  dsc_sqlalwaysonservice{'EnableAlwaysOn':
    dsc_ensure => 'Present',
    dsc_servername => $hostname,
    dsc_instancename => 'MSSQLSERVER',
    dsc_restarttimeout => 15,
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }->

  # Adding the required service account to allow the cluster to log into SQL
  dsc_sqlserverlogin{'AddNTServiceClusSvc':
    dsc_ensure => 'Present',
    dsc_name => 'NT SERVICE\ClusSvc',
    dsc_logintype => 'WindowsUser',
    dsc_servername => $hostname,
    dsc_instancename => 'MSSQLSERVER',
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }->

  # Add the required permissions to the cluster service login
  dsc_sqlserverpermission{'AddNTServiceClusSvcPermissions':
    dsc_ensure => 'Present',
    dsc_servername => $hostname,
    dsc_instancename => 'MSSQLSERVER',
    dsc_principal => 'NT SERVICE\ClusSvc',
    dsc_permission => ['AlterAnyAvailabilityGroup', 'ViewServerState'],
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }->

  dsc_sqlserverendpoint{'SQLServerEndpoint':
    dsc_endpointname => 'HADR',
    dsc_ensure => 'Present',
    dsc_port => '5022',
    dsc_servername => $fqdn,
    dsc_instancename => 'MSSQLSERVER',
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }->

  dsc_sqlserverendpointpermission{'SQLConfigureEndpointPermission':
		dsc_ensure => 'Present',
		dsc_servername => $hostname,
		dsc_instancename => 'MSSQLSERVER',
		dsc_name => 'HADR',
		dsc_principal => "${domainnetbiosname}\\$sqlservicecredential_username",
		dsc_permission => 'CONNECT',
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }

  if ( $role == 'primary' ) {
     # Create the availability group on the instance tagged as the primary replica
    dsc_sqlag{'CreateSQLAvailabilityGroup':
      dsc_ensure => 'Present',
      dsc_name => $clusterName,
      dsc_servername => $hostname,
      dsc_instancename => 'MSSQLSERVER',
      dsc_availabilitymode => 'SynchronousCommit',
      dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => [ Dsc_sqlalwaysonservice['EnableAlwaysOn'] , Dsc_sqlserverendpoint['SQLServerEndpoint'] ]
    }

    dsc_sqlaglistener{'AvailabilityGroupListener':
			dsc_ensure => 'Present',
			dsc_servername => $fqdn,
			dsc_instancename => 'MSSQLSERVER',
			dsc_availabilitygroup => $clusterName,
			dsc_name => "${clusterName}LI",
			dsc_ipaddress => $listenerIP,
			dsc_port => 1433,
			dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => [ Dsc_sqlag['CreateSQLAvailabilityGroup'] ]
    }

  }
  else {

    dsc_sqlagreplica{'SQLAvailabilityGroupAddReplica':
			dsc_ensure => 'Present',
			dsc_name => $hostname,
			dsc_availabilitygroupname => $clusterName,
			dsc_servername => $hostname,
			dsc_instancename => 'MSSQLSERVER',
			dsc_primaryreplicaservername => $clusterName,
			dsc_primaryreplicainstancename => 'MSSQLSERVER',
			dsc_endpointhostname => $hostname,
			dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => [ Dsc_sqlalwaysonservice['EnableAlwaysOn'] , Dsc_sqlserverendpoint['SQLServerEndpoint'] ]
    }
  }
}
