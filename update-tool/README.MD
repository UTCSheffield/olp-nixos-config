# UTC OLP NixOS Update Tool System

### Server
- Fixed IP as going to be used internally
- Websocket server that clients connect to, sends an update broadcast on trigger
- Setup involves downloading the latest release from https://github.com/UTCSheffield/olp-nixos-update/releases and then creating /etc/systemd/system/utc_update_server.service
```systemd
[Unit]
Description=UTC Update Server
After=network.target

[Service]
ExecStart=/bin/utc_update_server
User=root
Restart=on-failure
RestartSec=10
StartLimitInterval=30
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
```
- Then run systemctl daemon-reload && systemctl enable utc_update_server.service --now



### Update Trigger
- Websocket client that connects to a different endpoint, sends "update", then disconnects, triggering commands on client



### Client
- Websocket server that clients connect to, sends an update broadcast on trigger
- Setup involves downloading the latest release from https://github.com/UTCSheffield/olp-nixos-update/releases and then creating /etc/systemd/system/utc_update_server.service
```systemd
[Unit]
Description=UTC Update Client
After=network.target

[Service]
ExecStart=/bin/utc_update_client
User=root
Restart=on-failure
RestartSec=10
StartLimitInterval=30
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
```
- Then run systemctl daemon-reload && systemctl enable utc_update_server.service --now
