#!/bin/bash

export ADMIN_USERNAME="$(grep "^ADMIN_USERNAME=" "/run/secrets/credentials" | cut -d'=' -f2)"
export ADMIN_PASSWORD="$(grep "^ADMIN_PASSWORD=" "/run/secrets/credentials" | cut -d'=' -f2)"

exec onlogs
