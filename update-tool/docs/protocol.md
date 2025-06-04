## Connect
Clients will:
* Connect to server URL passed as cli argument
* Send the server its hostname
* Initiate Version Check

## Version Check
Exchange can be initiated by client or server

Client initiates exchange:
* When system boots
* When client service (re)started

Server initiates exchange:
* When requested by admin
```
Client: { clientGitHash, hostname, branch }
Server: { serverGitHash }
```
If hash is equal nothing happens

If hash is not equal, client initiates Update stage

## Update
