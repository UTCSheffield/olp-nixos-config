# UTC OLP NixOS Update Tool System

### Server
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
