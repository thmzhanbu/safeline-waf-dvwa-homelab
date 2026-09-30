#!/usr/bin/env bash
# Ubuntu only: collect versions/state, not environment values, secrets or HTTP bodies.
set -euo pipefail
cd "$(dirname "$0")/.."
[[ "$(uname -s)" == Linux ]] || { echo 'Run this inside the Ubuntu VM.' >&2; exit 1; }
umask 077
lab_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
lab_dir="evidence/private/${lab_stamp}"
mkdir -p "$lab_dir"
{
  date -u +%FT%TZ
  uname -srmo
  cat /etc/os-release
  docker version --format 'Client={{.Client.Version}} Server={{.Server.Version}}'
  docker compose version
  docker compose ps
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
} > "$lab_dir/environment.txt"
docker ps --format '{{.Image}}' | sort -u | while IFS= read -r lab_image; do
  docker image inspect "$lab_image" --format '{{.Id}} {{json .RepoDigests}}'
done > "$lab_dir/image-digests.txt"
echo "Collected private environment metadata in $lab_dir"
echo 'Review it, redact personal details, and record approved version details in the assessment.'
echo 'This is environment evidence only; it does not prove WAF protection.'
