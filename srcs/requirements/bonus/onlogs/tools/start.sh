#!/bin/sh

export ADMIN_PASSWORD="$(grep "^ADMIN_PASSWORD=" "/run/secrets/credentials" | cut -d'=' -f2)"

exec onlogs
