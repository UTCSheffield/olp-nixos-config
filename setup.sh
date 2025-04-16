#!/usr/bin/env bash

branch="master"

while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      branch="$2"
      shift 2
      ;;
    *)
      echo "Usage: $0 [--branch <branch>]"
      exit 1
      ;;
  esac
done

url="https://raw.githubusercontent.com/UTCSheffield/olp-nixos-config/refs/heads/${branch}/setuppt2.sh"

curl -o ./setuppt2.sh -L "$url"
chmod +x ./setuppt2.sh
./setuppt2.sh
