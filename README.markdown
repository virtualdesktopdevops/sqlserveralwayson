# sqlserveralwayson #

This modules installs a fully working Microsoft SQL Server AlwaysOn cluster. It has been designed to install both primary replica nodes with the following features :
- SPN creation on sql service account (service account not yet created by this module, schedulded in next release)
- SQL server installation and initial configuration (MaxDop Firewall, Memory, Admin rights, ...)
- Failover cluster creation (primary node) or join (replica node) with File Share witness
- AlwaysOn configuration (availability group, server endpoints, availability group listener) on both primary and replica nodes.


## Integration informations
The default MSSQLSERVER SQL Server instance is created during installation. This module does not provide the capability to create other SQL instances.

The database failover mecanism integrated in this module is SQL Server AlwaysOn.

The module can be installed on a Standard, Datacenter, Core version of Windows 2012R2 or Windows 2016.

**BREAKING CHANGE :** This module requires puppetlabs/dsc compiled with SQLServerDSC >= 10.0.0.0

## Usage
- **setup_svc_username** : (string) Privileged account used by Puppet for installing the software and creating the failover cluster (spn creation, computer registration, local administrator privilèges needed)
- **setup_svc_password** : (string) Password of the privileged account. Should be encrypted with hiera-eyaml.
- **setupdir** : (string) Path of a folder containing the SQL Server installer (unarchive the ISO image in this folder).
- **sa_password** : (string) SQL Server SA password for mixed mode SQL authentication configuration.
- **productkey** : (string)(optionnal) Product key for licensed installations.
- **sqlservicecredential_username** : (String) Domain service account for the SQL service **WITHOUT** Netbios Domain Name prefix. The account will be automatically created in Active Directory by the module. MSSQLSvc/fqdn_of_sql_server_node SPN will be associated with the service account.
- **sqlservicecredential_password** : (String) :  Password of the service account for the SQL service. Should be encrypted with hiera-eyaml.
- **sqlagentservicecredential_username** : (String) Domain service account for the SQL Agent service **WITHOUT** Netbios Domain Name prefix. The account will be automatically created in Active Directory by the module.
- **sqlagentservicecredential_password** : (String) Password of the service account for the SQL Agent service. Should be encrypted with hiera-eyaml.
- **sqladministratoraccounts** : (String[] Array) : Array of accounts to be made SQL administrators.
- **sqluserdbdir** : (String)(optionnal) Path for SQL database files. Default to 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
- **sqluserdblogdir** : (String)(optionnal) Path for SQL log files. Default to 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
- **sqlbackupdir** : (String)(optionnal) Path for SQL backup files. Default to 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup'
- **sqltempdbdir** : (String)(optionnal) Path for SQL TempDB files. Default to 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
- **sqltempdblogdir** : (String)(optionnal) Path for SQL TempDB log files. Default to 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Data'
- **clusterName** : (String) Failover cluster name.
- **clusterIP** : (String) Failover cluster IP address.
- **fileShareWitness** : (String) Fileshare witness UNC path in the format'\\witness.company.local\witness$'. Needs to be writable by SQL nodes.
- **listenerIP** : (String) The IP address used for the availability group listener, in the format 192.168.10.45/255.255.252.0.
- **role** : (String) Needs to be 'primary' for primary SQL nodes or 'secondary' for SQL replica nodes


## Installing a Microsoft SQL Server AlwaysOn cluster
The following example creates a 2 nodes SQL Server Always On Availability group :
- SQL Server is installed on both nodes using the privileged **DOMAIN-TEST\svc-puppet** account.
- SQL Server service and agent are configured to run using the **DOMAIN-TEST\svc-sql-puppet** service account.
- Mixed mode logon is configured with the required "SA password" used to recover SQL Server access in case of windows authentication service failure
- Windows Failover Cluster named **CLDB01** is created and configured with the **\\192.168.1.10\quorum** file share witness
- Always On Availability group is created including endpoints and **CLDB01LI** listener (IP address : 192.168.1.61). The listener name is derived from the failover cluster name by the module

The replica node is installed with the same parameters and joined to the **CLDB01** windows failover cluster and to the Avalability Group. **Notice the role => 'secondary'** which defines the role of the node.

### Sample architecture :
![Sample SQL Server Always On architecture](https://virtualdesktopdevops.github.io/images/sql-server-always-on-architecture.jpg)

### Sample Puppet code :
~~~puppet
#Primary node
node 'SQL01' {
	class{'sqlserveralwayson':
	  setup_svc_username=>'DOMAIN-TEST\svc-puppet',
	  setup_svc_password=>'P@ssw0rd',
	  setupdir=>'\\fileserver.local\SQLServer2012.en',
	  sa_password=>'P@ssw0rd',
	  productkey => 'key-key-key',
	  sqlservicecredential_username => 'svc-sql-puppet',
	  sqlservicecredential_password=>'P@ssw0rd',
	  sqlagentservicecredential_username => 'svc-sql-puppet',
	  sqlagentservicecredential_password => 'P@ssw0rd',
	  sqladministratoraccounts => [ 'DOMAIN-TEST\svc-puppet', 'DOMAIN-TEST\Administrator' ],
	  clusterName => 'CLDB01',
	  clusterIP => '192.168.1.60',
	  fileShareWitness=> '\\192.168.1.10\quorum',
	  listenerIP => '192.168.1.61/255.255.255.0',
	  role => 'primary'
	}
}

#Replica node
node 'SQL02' {
	class{'sqlserveralwayson':
	  setup_svc_username=>'DOMAIN-TEST\svc-puppet',
	  setup_svc_password=>'P@ssw0rd',
	  setupdir=>'\\fileserver.local\SQLServer2012.en',
	  sa_password=>'P@ssw0rd',
	  productkey => 'key-key-key',
	  sqlservicecredential_username => 'svc-sql-puppet',
	  sqlservicecredential_password=>'P@ssw0rd',
	  sqlagentservicecredential_username => 'svc-sql-puppet',
	  sqlagentservicecredential_password => 'P@ssw0rd',
	  sqladministratoraccounts => [ 'DOMAIN-TEST\svc-puppet', 'DOMAIN-TEST\Administrator' ],
	  clusterName => 'CLDB01',
	  clusterIP => '192.168.1.60',
	  fileShareWitness=> '\\192.168.1.10\quorum',
	  listenerIP => '192.168.1.61/255.255.255.0',
	  role => 'secondary'
	}
}

~~~
