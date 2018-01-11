# Class: sqlserveralwayson
#
# This module manages sqlserveralwayson
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class sqlserveralwayson(
  $setup_svc_username,
	$setup_svc_password,
	$setupdir,
	$sa_password, #SA password for mixed mode SQL authentication
	$productkey = '',
	$sqlservicecredential_username,
	$sqlservicecredential_password,
	$sqlagentservicecredential_username,
	$sqlagentservicecredential_password,
  $sqladministratoraccounts,
  $sqluserdbdir = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data',
  $sqluserdblogdir = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data',
  $sqlbackupdir = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup',
  $sqltempdbdir = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data',
  $sqltempdblogdir = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data',
  $clusterName,
  $clusterIP,
  $fileShareWitness, #Format '\\witness.company.local\witness$'
  $listenerIP, #The IP address used for the availability group listener, in the format 192.168.10.45/255.255.252.0.
  $role, ##primary or secondary
  )
{
  #Using $domain fact du get the active directory domain name
  $domainName = $domain

  contain sqlserveralwayson::serviceaccounts
	contain sqlserveralwayson::install
	contain sqlserveralwayson::config
	contain sqlserveralwayson::clusterconfig
	contain sqlserveralwayson::alwaysonconfig

	Class['::sqlserveralwayson::serviceaccounts'] ->
	Class['::sqlserveralwayson::install'] ->
	Class['::sqlserveralwayson::config'] ->
	Class['::sqlserveralwayson::clusterconfig']->
	Class['::sqlserveralwayson::alwaysonconfig']
}
