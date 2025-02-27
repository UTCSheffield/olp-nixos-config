#!/bin/sh
git -C /etc/nixos pull
nixos-rebuild switch --flake /etc/nixos#makerlab-3040
