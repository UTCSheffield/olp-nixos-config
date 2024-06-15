# Nixos-config/update-tool

This directory contains the code and documentation for both the client & server for the update tool.

## Rationale
We need a way to ensure that configs across machine are up to date and correct, Additionally. We need automated tooling to ensure that machines are up to date with the latest OS and security versions. This tool will ensure that the fleet is relativly maintenance free

## Requirements

### Server
- Handle flake upgrades
- Offer Easy to follow error logs
- Provide websocket gateway
- Provide (simple) UI to show connected device status's
- Handle syncing configs on change

### Client
- Listen for upgrade requests on boot/on change
- Connect to WS
- Provide simple CLI to abstract simple NixOS tasks (nix-env installs)

Both should be well documented, tested and easy to maintain

## Tech Stacks
### Server
- Javascript (maybe Typescript)
- Express
- Pure HTML/CSS/JS

### Client
- Rust (Needs to use little resources and not crash)
- Systemd

