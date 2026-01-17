#!/bin/sh

cd /data

# 1. Register an account if you don't have one (Persistence Check)
if [ ! -f "wgcf-account.toml" ]; then
    echo "Register a new Cloudflare WARP account..."
    wgcf register --accept-tos
    wgcf generate
fi

# 2. Setup WireGuard
mkdir -p /etc/wireguard
cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# 3. Run WireGuard
WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up wgcf

# 4. Run MicroSocks
# -i: listen address (0.0.0.0 so that it can be accessed from outside the container)
# -p: port (1080)
echo "MicroSocks SOCKS5 Server is active on port 1080..."
microsocks -i 0.0.0.0 -p 1080
