#!/usr/bin/env bash
# Read-only Ubuntu checks. Does not install packages or change firewall rules.
set -euo pipefail
[[ "$(uname -s)" == Linux ]] || { echo 'Run this inside the Ubuntu VM.' >&2; exit 1; }
printf 'UTC: '; date -u +%FT%TZ
printf 'Architecture: '; uname -m
case "$(uname -m)" in
  x86_64) if ! grep -qw ssse3 /proc/cpuinfo; then
    echo 'FAIL: SafeLine requires SSSE3 on x86_64; check VM CPU settings.' >&2; exit 1
  fi ;;
  aarch64|arm64) ;;
  *) echo 'Unsupported architecture for this guide.' >&2; exit 1 ;;
esac
free -h
df -h /
for lab_cmd in docker curl openssl python3; do
  command -v "$lab_cmd" >/dev/null || { echo "Missing: $lab_cmd" >&2; exit 1; }
done
docker version --format 'Docker server: {{.Server.Version}}'
lab_major="$(docker version --format '{{.Server.Version}}' | cut -d. -f1)"
if ! [[ "$lab_major" =~ ^[0-9]+$ ]] || (( lab_major < 28 )); then
  echo 'FAIL: use a maintained Docker Engine >=28 for localhost port isolation.' >&2; exit 1
fi
docker compose version
printf '\nCurrent listeners (80 / 8081 / 9443 should be free before deployment):\n'
ss -ltn | awk 'NR == 1 || $4 ~ /:(80|8081|9443)$/'
printf '\nPreflight completed. Confirm VM network isolation manually in the guide.\n'
