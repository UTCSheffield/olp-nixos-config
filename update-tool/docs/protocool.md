# # Nixos-config/update-tool/docs/protocool.md

This document contains the protocool that the server and client will conform to


!!!! OUTDATED, WILL BE UPDATED WHEN ACTUAL IMPL is finished !!!!

## Version state
Exchange can be init'd by client or server, If init'd by client, skip first server block  
Server: `ConfigVersion?`  
Client: `Version ${gitCommitHash}`

## Update
Exchange init'd by server
Server: `Update`  
Client: `Aknowleged`  
... Wait until update complete ...  
if error:
Client: `UpdateError ${error}`
if success:
Client: `UpdateSuccess`

## Connect
Exchange init'd by client   
Client: `Connect`  
Server: [VersionState flow]
