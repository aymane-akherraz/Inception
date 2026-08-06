#!/bin/bash

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/nginx/ssl/inception.key \
-out /etc/nginx/ssl/inception.crt \
-subj "/C=MA/ST=Rabat/L=Rabat/O=42/OU=1337/CN=$DOMAIN_NAME"

nginx -g "daemon off;"