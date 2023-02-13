#!/bin/bash
PGPASSWORD=${KC_DB_PASSWORD:-password} psql -w -h "${KC_DB_URL_HOST:-keycloak}" \
        -p "${KC_DB_URL_PORT:-5432}" \
        -U "${KC_DB_USER:-root}" \
        "${KC_DB_URL_DATABASE:-keycloak}" 2> /dev/null || \
    PGPASSWORD=${KC_DB_PASSWORD:-password} psql -h "${KC_DB_URL_HOST:-postgres}" \
        -p "${KC_DB_URL_PORT:-5432}" \
        -U "${KC_DB_USER:-root}" \
        -d "${POSTGRES_DB:-root}" \
        -c "create database ${KC_DB_URL_DATABASE:-keycloak};"
echo "Starting Keycloak"
[[ ${KC_DEV} ]] && dev=-dev
exec /opt/keycloak/bin/kc.sh start$dev ${KC_LAUNCH_ARGS}
