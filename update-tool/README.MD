# UTC OLP NixOS Update Tool System

### Server
- Fixed IP as going to be used internally
- Websocket server that clients connect to, sends an update broadcast on trigger
- Setup involves installing the nix-os package, released soon



### Update Trigger
- Websocket client that connects to a different endpoint, sends "update", then disconnects, triggering commands on client
- Setup involves installing the nix-os package, released soon



### Client
- Websocket server that clients connect to, sends an update broadcast on trigger
- Setup involves installing the nix-os package, released soon
