# olp-nixos-config/update-tool

This directory contains the code and documentation for both the client & server for the update tool.

## Rationale
We need a way to ensure that configs across machine are up to date and correct, Additionally. We need automated tooling to ensure that machines are up to date with the latest OS and security versions. This tool will ensure that the fleet is relatively maintenance free

## Requirements

### Server
- Handle flake upgrades
- Offer easy to follow error logs
- Provide (simple) UI to show connected device status's (WIP)
- Handle syncing configs on commit via github webhook

### Client
- Pulls latest commit hash from server
- Checks against local config
- Pulls and rebuilds if required