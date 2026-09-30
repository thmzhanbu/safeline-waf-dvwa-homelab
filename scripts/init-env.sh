#!/usr/bin/env bash
# Generates credentials locally; never prints their values or overwrites .env.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v openssl >/dev/null || { echo 'Install openssl first.' >&2; exit 1; }
if [[ -e .env ]]; then
  echo '.env already exists; keeping it. Do not regenerate passwords for an existing database.'
  exit 0
fi
umask 077
set -o noclobber
lab_db_password="$(openssl rand -hex 24)"
lab_root_password="$(openssl rand -hex 24)"
cat > .env <<EOF
DVWA_IMAGE=ghcr.io/digininja/dvwa:latest
MARIADB_IMAGE=mariadb:10
DVWA_DB_PASSWORD=${lab_db_password}
DB_ROOT_PASSWORD=${lab_root_password}
EOF
echo 'Created private .env. Keep this file out of Git and screenshots.'
