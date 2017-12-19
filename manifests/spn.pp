class sqlserveralwayson::spn inherits sqlserveralwayson {
  #Create local certificates directory to store powershell scripts
  
  dsc_file{ 'ScriptsDirectory':
    dsc_destinationpath => 'C:\Scripts',
    dsc_type => 'Directory',
    dsc_ensure => 'Present'
  }
  
  #Download SPN creation script
  file{ "C:\\Scripts\\setspn.ps1":
    source => 'puppet:///modules/sqlserveralwayson/setspn.ps1',
    source_permissions => ignore,
    require => Dsc_file['ScriptsDirectory'] 
  }->
  
  #Download SPN verification script
  file{ "C:\\Scripts\\checkspn.ps1":
    source => 'puppet:///modules/sqlserveralwayson/checkspn.ps1',
    source_permissions => ignore,
    require => Dsc_file['ScriptsDirectory'] 
  }->

	exec { 'CreateSPN':
	  command   => "& C:\\Scripts\\setspn.ps1 -spn 'MSSQLSvc/${fqdn}' -serviceaccount ${sqlservicecredential_username}",
	  onlyif    => " & C:\\Scripts\\checkspn.ps1 -spn 'MSSQLSvc/${fqdn}' -serviceaccount ${sqlservicecredential_username}",
	  provider  => powershell
	}
}