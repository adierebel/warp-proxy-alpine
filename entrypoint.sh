#!/bin/sh
cd /data

# Register an account if you don't have one (Persistence Check)
if [ ! -f "wgcf-account.toml" ]; then
    echo "Register a new Cloudflare WARP account..."
    wgcf register --accept-tos
    wgcf generate
fi

# Setup WireGuard
mkdir -p /etc/wireguard
cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# IPv4 only
sed -i 's/AllowedIPs = 0.0.0.0\/0, ::\/0/AllowedIPs = 0.0.0.0\/0/g' /etc/wireguard/wgcf.conf

# Run WireGuard
wg-quick up wgcf
sleep 1
resolvconf -u # fix signature mismatch
wg-quick up wgcf

# Run MicroSocks
echo "MicroSocks SOCKS5 Server is active on port 1080..."
microsocks -i 0.0.0.0 -p 1080