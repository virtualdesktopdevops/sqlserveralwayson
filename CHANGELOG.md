# Changelog - sqlserveralwayson #

## Version 2.0.0
- **BREAKING CHANGE** : Require puppetlabs/dsc compiled with SQLServerDSC >= 10.0.0.0
- **BREAKING CHANGE** : Changed $sqlservicecredential_username and  $sqlagentservicecredential_username format. User accounts now required **WITHOUT** Netbios Domain Name prefix.
- **BREAKING CHANGE** : Removed $domainName class parameter. Used facts instead.
- **BREAKING CHANGE** : Removed $domainNetbiosName class parameter. Used custom fact instead.
- Changed database availability mode to SynchronousCommit


## Version 1.1.0
- Module compatible with xSQLServer <= 9.0.0.0

## Version 1.0.0
- Initial release
