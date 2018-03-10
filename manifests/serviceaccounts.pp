#Class creating SQL Server and SQL agent service accounts in Active Directory + associated Service Principal Names (SPN)
class sqlserveralwayson::serviceaccounts inherits sqlserveralwayson {

  #Needed for ActiveDirectory remote management using Powershell
  dsc_windowsfeature{ 'RSAT-AD-Powershell':
    dsc_ensure => 'Present',
    dsc_name   => 'RSAT-AD-Powershell'
  }

  #SQL service account creation (Active Directory)
  dsc_xaduser{'SvcSQLAccount':
    dsc_domainname                    => $facts['domain'],
    dsc_domainadministratorcredential => {
      'user'     => $sqlserveralwayson::setup_svc_username,
      'password' => $sqlserveralwayson::setup_svc_password
      },
    dsc_username                      => $sqlserveralwayson::sqlservicecredential_username,
    dsc_password                      => {
      'user'     => $sqlserveralwayson::sqlservicecredential_username,
      'password' => $sqlserveralwayson::sqlservicecredential_password
      },
    dsc_ensure                        => 'Present',
    require                           => Dsc_windowsfeature['RSAT-AD-Powershell']
  }

  #Configure MSSQLSvc SPN on SQL service account
  dsc_xadserviceprincipalname{'SvcSQLSPN':
    dsc_account              => $sqlserveralwayson::sqlservicecredential_username,
    dsc_serviceprincipalname => "MSSQLSvc/${facts['fqdn']}",
    dsc_ensure               => present,
    dsc_psdscrunascredential => {'user' => $sqlserveralwayson::setup_svc_username, 'password' => $sqlserveralwayson::setup_svc_password},
    require                  => Dsc_xaduser['SvcSQLAccount']
  }

  #SQL Agent service account creation (Active Directory)
  dsc_xaduser{'SvcSQLAgentAccount':
    dsc_domainname                    => $facts['domain'],
    dsc_domainadministratorcredential => {
      'user'     => $sqlserveralwayson::setup_svc_username,
      'password' => $sqlserveralwayson::setup_svc_password
      },
    dsc_username                      => $sqlserveralwayson::sqlagentservicecredential_username,
    dsc_password                      => {
      'user'     => $sqlserveralwayson::sqlagentservicecredential_username,
      'password' => $sqlserveralwayson::sqlagentservicecredential_password
      },
    dsc_ensure                        => 'Present',
    require                           => Dsc_windowsfeature['RSAT-AD-Powershell']
  }
}
