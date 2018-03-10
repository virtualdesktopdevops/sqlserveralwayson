#Class configuring Windows failover cluster which is a foundation for SQL Server AlwaysOn feature
class sqlserveralwayson::clusterconfig inherits sqlserveralwayson {

  if ( $sqlserveralwayson::role == 'primary' ) {
    #Failover cluster creation
    dsc_xcluster{'CreateFailoverCluster':
      dsc_name                          => $sqlserveralwayson::clustername,
      dsc_staticipaddress               => $sqlserveralwayson::clusterip,
      dsc_domainadministratorcredential => {
        'user'     => $sqlserveralwayson::setup_svc_username,
        'password' => $sqlserveralwayson::setup_svc_password
      }
    }

    #File share whitness configuration
    #Warning, bug https://github.com/PowerShell/xFailOverCluster/issues/35 on Windows 2016
    dsc_xclusterquorum{'SetQuorumToNodeAndDiskMajority':
      dsc_issingleinstance => 'Yes',
      dsc_type             => 'NodeAndFileShareMajority',
      dsc_resource         => $sqlserveralwayson::filesharewitness,
      require              => Dsc_xcluster['CreateFailoverCluster']
    }

  }
  else {
    dsc_xwaitforcluster{'SecondaryReplicaWaitForCluster':
      dsc_name             => $sqlserveralwayson::clustername,
      dsc_retryintervalsec => 10,
      dsc_retrycount       => 6
    }

    dsc_xcluster{'JoinCluster':
      dsc_name                          => $sqlserveralwayson::clustername,
      dsc_staticipaddress               => $sqlserveralwayson::clusterip,
      dsc_domainadministratorcredential => {
        'user'     => $sqlserveralwayson::setup_svc_username,
        'password' => $sqlserveralwayson::setup_svc_password
        },
      require                           => Dsc_xwaitforcluster['SecondaryReplicaWaitForCluster']
    }
  }
}
