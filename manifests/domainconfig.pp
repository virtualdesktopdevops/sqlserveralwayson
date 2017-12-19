class sqlserveralwayson::domainconfig inherits sqlserveralwayson {

  #Create SQL Server Organizaational Unit
  dsc_xADOrganizationalUnit{ 'OrgUnitCITRIX':
    dsc_name => 'SQL Server',
    #Specified the X500 (DN) path of the organizational unit's parent object.
    dsc_path => $domainbasedn,
    dsc_description => "SQL Server",
    dsc_protectedfromaccidentaldeletion => true,
    dsc_ensure => 'present'
    #Credential: User account credentials used to perform the operation (optional). Note: if not running on a domain controller, this is required.
  }
}