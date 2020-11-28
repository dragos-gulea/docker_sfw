#!/bin/bash

#if [ ! -f /etc/nginx/ssl/default.crt ]; then
#    openssl genrsa -out "/etc/nginx/ssl/default.key" 2048
#    openssl req -new -key "/etc/nginx/ssl/default.key" -out "/etc/nginx/ssl/default.csr" -subj "/CN=default/O=default/C=UK"
#    openssl x509 -req -days 365 -in "/etc/nginx/ssl/default.csr" -signkey "/etc/nginx/ssl/default.key" -out "/etc/nginx/ssl/default.crt"
#fi

if [ -z "$LE_ACME_DOMAINS" ]; then
    echo "Skip letsencrypt certificate generation"
    nginx
    exit 1
fi

cd /usr/local/bin/ && ./acme.sh --install --home /etc/letsencrypt --nocron --noprofile

if [ "$LE_FAKE_CA" = "1" ]; then
    echo "Fake certificate being generated"
    export LE_TEST="--test"
fi

cd /etc/letsencrypt || return


# Standalone when no certificates (to prevent nginx error)

nginx -t || \
    (
        ./acme.sh --home /etc/letsencrypt --issue $LE_ACME_DOMAINS --standalone --httpport $LE_ACME_HTTP_PORT --verify-server $LE_TEST
    )

nginx &
while :; do
    ./acme.sh --home /etc/letsencrypt --issue $LE_ACME_DOMAINS $LE_ACME_WEB_PATHS --tlsport $LE_ACME_TLS_PORT --verify-server $LE_TEST
    nginx -s reload
    sleep 6h;
done
