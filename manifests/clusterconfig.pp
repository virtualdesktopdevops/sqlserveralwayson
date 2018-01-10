class sqlserveralwayson::clusterconfig inherits sqlserveralwayson {

  if ( $role == 'primary' ) {
    #Failover cluster creation
    dsc_xcluster{'CreateFailoverCluster':
      dsc_name => $clusterName,
      dsc_staticipaddress => $clusterIP,
      dsc_domainadministratorcredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password}
    }

    #File share whitness configuration
    #Warning, bug https://github.com/PowerShell/xFailOverCluster/issues/35 on Windows 2016
    dsc_xclusterquorum{'SetQuorumToNodeAndDiskMajority':
      dsc_issingleinstance => 'Yes',
      dsc_type => 'NodeAndFileShareMajority',
      dsc_resource => $fileShareWitness,
      require => Dsc_xcluster['CreateFailoverCluster']
    }

  }
  else {
    dsc_xwaitforcluster{'SecondaryReplicaWaitForCluster':
      dsc_name => $clusterName,
      dsc_retryintervalsec => 10,
      dsc_retrycount => 6
    }

    dsc_xcluster{'JoinCluster':
      dsc_name => $clusterName,
      dsc_staticipaddress => $clusterIP,
      dsc_domainadministratorcredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
      require => Dsc_xwaitforcluster['SecondaryReplicaWaitForCluster']
    }
  }
}
