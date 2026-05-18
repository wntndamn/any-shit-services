#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${DATA_DIR:-/data}"
DOMAIN="${DOMAIN:?DOMAIN is required}"
DNS_PORT="${DNS_PORT:-53}"
SOCKS_PORT="${SOCKS_PORT:-1080}"

mkdir -p "$DATA_DIR"

if [[ ! -f "$DATA_DIR/cert.pem" ]] || [[ ! -f "$DATA_DIR/key.pem" ]]; then
    openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp256k1 -days 3650 \
        -nodes -keyout "$DATA_DIR/key.pem" -out "$DATA_DIR/cert.pem" \
        -subj "/CN=$DOMAIN" 2>/dev/null
fi

if [[ ! -f "$DATA_DIR/reset-seed" ]]; then
    openssl rand -hex 32 > "$DATA_DIR/reset-seed"
fi

EXT_IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
if [[ -z "$EXT_IP" ]]; then
    EXT_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi
if [[ -z "$EXT_IP" ]]; then
    echo "Cannot detect external IP" >&2
    exit 1
fi

cat > /etc/danted.conf <<EOF
logoutput: stderr

internal: 127.0.0.1 port = ${SOCKS_PORT}
external: ${EXT_IP}

socksmethod: none
clientmethod: none

client pass {
    from: 127.0.0.1/32 to: 0.0.0.0/0
    log: connect disconnect error
}

socks pass {
    from: 127.0.0.1/32 to: 0.0.0.0/0
    protocol: tcp udp
    log: connect disconnect error
}
EOF

danted -D

exec slipstream-server \
    --dns-listen-port "$DNS_PORT" \
    --target-address "127.0.0.1:${SOCKS_PORT}" \
    --domain "$DOMAIN" \
    --cert "$DATA_DIR/cert.pem" \
    --key "$DATA_DIR/key.pem" \
    --reset-seed "$DATA_DIR/reset-seed"
