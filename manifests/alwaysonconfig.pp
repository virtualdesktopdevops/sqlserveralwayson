class sqlserveralwayson::alwaysonconfig inherits sqlserveralwayson {
  
  #Enable AlwaysOn on MSSQL service
  dsc_xsqlserveralwaysonservice{'EnableAlwaysOn':
    dsc_ensure => 'Present',
    dsc_sqlserver => $hostname,
    dsc_sqlinstancename => 'MSSQLSERVER',
    dsc_restarttimeout => 15,
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }->
  
  # Adding the required service account to allow the cluster to log into SQL
  dsc_xsqlserverlogin{'AddNTServiceClusSvc':
    dsc_ensure => 'Present',
    dsc_name => 'NT SERVICE\ClusSvc',
    dsc_logintype => 'WindowsUser',
    dsc_sqlserver => $hostname,
    dsc_sqlinstancename => 'MSSQLSERVER',
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }->

  # Add the required permissions to the cluster service login
  dsc_xsqlserverpermission{'AddNTServiceClusSvcPermissions':
    dsc_ensure => 'Present',
    dsc_nodename => $hostname,
    dsc_instancename => 'MSSQLSERVER',
    dsc_principal => 'NT SERVICE\ClusSvc',
    dsc_permission => ['AlterAnyAvailabilityGroup', 'ViewServerState'],
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }->

  dsc_xsqlserverendpoint{'SQLServerEndpoint':
    dsc_endpointname => 'HADR',
    dsc_ensure => 'Present',
    dsc_port => '5022',
    dsc_sqlserver => $fqdn,
    dsc_sqlinstancename => 'MSSQLSERVER',
    dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }
  
  dsc_xsqlserverendpointpermission{'SQLConfigureEndpointPermission':
		dsc_ensure => 'Present',
		dsc_nodename => $hostname,
		dsc_instancename => 'MSSQLSERVER',
		dsc_name => 'HADR',
		dsc_principal => $sqlservicecredential_username,
		dsc_permission => 'CONNECT',
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
  }
  
  if ( $role == 'primary' ) {
     # Create the availability group on the instance tagged as the primary replica
    dsc_xsqlserveralwaysonavailabilitygroup{'CreateSQLAvailabilityGroup':
      dsc_ensure => 'Present',
      dsc_name => $clusterName,
      dsc_sqlserver => $hostname,
      dsc_sqlinstancename => 'MSSQLSERVER',
      dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => [ Dsc_xsqlserveralwaysonservice['EnableAlwaysOn'] , Dsc_xsqlserverendpoint['SQLServerEndpoint'] ]
    }
    
    dsc_xsqlserveravailabilitygrouplistener{'AvailabilityGroupListener':
			dsc_ensure => 'Present',
			dsc_nodename => $fqdn,
			dsc_instancename => 'MSSQLSERVER',
			dsc_availabilitygroup => $clusterName,
			dsc_name => "${clusterName}LI",
			dsc_ipaddress => $listenerIP,
			dsc_port => 1433,
			dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => [ Dsc_xsqlserveralwaysonavailabilitygroup['CreateSQLAvailabilityGroup'] ]
    }
    
  }
  else {
        
    dsc_xsqlserveralwaysonavailabilitygroupreplica{'SQLAvailabilityGroupAddReplica':
			dsc_ensure => 'Present',
			dsc_name => $hostname,
			dsc_availabilitygroupname => $clusterName,
			dsc_sqlserver => $hostname,
			dsc_sqlinstancename => 'MSSQLSERVER',
			dsc_primaryreplicasqlserver => $clusterName,
			dsc_primaryreplicasqlinstancename => 'MSSQLSERVER',
			dsc_endpointhostname => $hostname,
			dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => [ Dsc_xsqlserveralwaysonservice['EnableAlwaysOn'] , Dsc_xsqlserverendpoint['SQLServerEndpoint'] ]
    }
  }
}
