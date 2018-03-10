#Class installing Microsotf SQL Server and required windows roles & features
class sqlserveralwayson::install inherits sqlserveralwayson {

  #reboot { 'before':
  #  when => pending,
  #}

  dsc_windowsfeature{'NET-Framework-Core':
    dsc_ensure               => 'Present',
    dsc_name                 => 'NET-Framework-Core',
    dsc_includeallsubfeature => true
  }

  dsc_windowsfeature{'NET-Framework-45-Core':
    dsc_ensure               => 'Present',
    dsc_name                 => 'NET-Framework-45-Core',
    dsc_includeallsubfeature => true
  }

  dsc_windowsfeature{'RSAT-AD-PowerShell':
    dsc_ensure => 'Present',
    dsc_name   => 'RSAT-AD-PowerShell'
  }

  dsc_windowsfeature{'Failover-Clustering':
    dsc_ensure => 'Present',
    dsc_name   => 'Failover-Clustering'
  }

  dsc_windowsfeature{'RSATClusteringPowerShell':
    dsc_ensure => 'Present',
    dsc_name   => 'RSAT-Clustering-PowerShell',
    require    => [ Dsc_windowsfeature['Failover-Clustering'] ]
  }

  dsc_windowsfeature{'RSATClusteringCmdInterface':
    dsc_ensure => 'Present',
    dsc_name   => 'RSAT-Clustering-CmdInterface',
    require    => [ Dsc_windowsfeature['RSATClusteringPowerShell'] ]
  }

  dsc_sqlsetup{ 'InstallSQLDefaultInstance':
    dsc_action               => 'Install',
    dsc_instancename         => 'MSSQLSERVER',
    dsc_features             => 'SQLENGINE,AS',
    dsc_sqlcollation         => 'SQL_Latin1_General_CP1_CI_AS',
    dsc_securitymode         => 'SQL',
    dsc_sapwd                => {'user' => 'sa', 'password' => $sqlserveralwayson::sa_password},
    dsc_productkey           => $sqlserveralwayson::productkey,
    dsc_sqlsvcaccount        => {
      'user'     => "${facts['domainnetbiosname']}\\${sqlserveralwayson::sqlservicecredential_username}",
      'password' => $sqlserveralwayson::sqlservicecredential_password
      },
    dsc_agtsvcaccount        => {
      'user'     => "${facts['domainnetbiosname']}\\${sqlserveralwayson::sqlagentservicecredential_username}",
      'password' => $sqlserveralwayson::sqlagentservicecredential_password
      },
    dsc_assvcaccount         => {
      'user'     => "${facts['domainnetbiosname']}\\${sqlserveralwayson::sqlservicecredential_username}",
      'password' => $sqlserveralwayson::sqlservicecredential_password
      },
    dsc_sqlsysadminaccounts  => $sqlserveralwayson::sqladministratoraccounts,
    dsc_assysadminaccounts   => $sqlserveralwayson::sqladministratoraccounts,
    dsc_installshareddir     => 'C:\Program Files\Microsoft SQL Server',
    dsc_installsharedwowdir  => 'C:\Program Files (x86)\Microsoft SQL Server',
    dsc_instancedir          => 'C:\Program Files\Microsoft SQL Server',
    dsc_installsqldatadir    => 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data',
    dsc_sqluserdbdir         => $sqlserveralwayson::sqluserdbdir,
    dsc_sqluserdblogdir      => $sqlserveralwayson::sqluserdblogdir,
    dsc_sqltempdbdir         => $sqlserveralwayson::sqltempdbdir,
    dsc_sqltempdblogdir      => $sqlserveralwayson::sqltempdblogdir,
    dsc_sqlbackupdir         => $sqlserveralwayson::sqlbackupdir,
    dsc_asconfigdir          => 'c:\MSOLAP\Config',
    dsc_asdatadir            => 'c:\MSOLAP\Data',
    dsc_aslogdir             => 'c:\MSOLAP\Log',
    dsc_asbackupdir          => 'c:\MSOLAP\Backup',
    dsc_astempdir            => 'c:\MSOLAP\Temp',
    dsc_sourcepath           => $sqlserveralwayson::setupdir,
    dsc_updateenabled        => 'False',
    dsc_forcereboot          => true,
    dsc_psdscrunascredential => {'user' => $sqlserveralwayson::setup_svc_username, 'password' => $sqlserveralwayson::setup_svc_password},
    require                  => [
      Dsc_windowsfeature['NET-Framework-Core'],
      Dsc_windowsfeature['NET-Framework-45-Core'],
      Dsc_windowsfeature['Failover-Clustering']
      ],
    notify                   => Reboot['after_run']
  }

  reboot { 'after_run':
    apply => finished,
  }
}
