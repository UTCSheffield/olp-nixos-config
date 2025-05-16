## Version check
Exchange can be initiated by client or server

Client initiates exchange:
* When system boots
* When client service (re)started

Server initiates 
```
Client: { clientGitHash, hostname, branch }
Server: { serverGitHash }
```
If hash is equal nothing happens

If hash is not equal, client initiates Update stage

## Update
