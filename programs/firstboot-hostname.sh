#!/usr/bin/env bash
set -e

NAMES=(yoda luke leia han vader rey finn poe obiwan anakin ahsoka)
COLORS=(red blue green black white amber grey pink)

# Get MAC address of first Ethernet
SERIAL=$(ip link show | awk '/ether/ {print $2; exit}' | tr -d ':')

# Fallback if missing
if [ -z "$SERIAL" ]; then
    SERIAL="000000000000"
fi

# Compute seed from all hex characters (0-9, A-F)
SEED=0
for ((i=0; i<${#SERIAL}; i++)); do
    c=${SERIAL:$i:1}
    if [[ $c =~ [0-9] ]]; then
        v=$c
    else
        # Convert hex letter to decimal
        v=$((16#${c^^}))
    fi
    SEED=$((SEED + v))
done

# Pick Star Wars name and color
NAME="${NAMES[$((SEED % ${#NAMES[@]}))]}"
COLOR="${COLORS[$(( (SEED * 7) % ${#COLORS[@]} ))]}"

HOSTNAME="${COLOR}-${NAME}"

rm -f /etc/hostname
echo "$HOSTNAME" > /etc/hostname
hostname "$HOSTNAME"