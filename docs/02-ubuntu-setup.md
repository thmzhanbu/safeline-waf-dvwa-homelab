# 2. Install the server components on Ubuntu

All commands in this guide run **inside Ubuntu**, from its console or SSH terminal. Use a dedicated lab VM. Copy this repository folder into Ubuntu, then open a terminal in `safeline-dvwa-homelab`. Keep the folder on a normal guest filesystem, rather than a shared folder with unusual permissions.

## 1. Prepare packages and Docker

```bash
sudo apt update
sudo apt install -y ca-certificates curl git openssl python3 openssh-server
sudo systemctl enable --now ssh
```

If `sudo docker version` and `sudo docker compose version` already work, check that the Docker **server** is a maintained version at least 28, then skip installation. This guide uses `sudo`; joining the Docker group is unnecessary.

For a fresh Ubuntu VM, install Engine from [Docker's Ubuntu repository instructions](https://docs.docker.com/engine/install/ubuntu/). If you previously installed `docker.io`, Snap Docker, Podman or old Compose, use that page's conflict-removal procedure first after checking that the VM has no valuable workloads.

The following configures Docker's package repository on a fresh supported Ubuntu guest:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl --fail --show-error --location https://download.docker.com/linux/ubuntu/gpg \
  --output /etc/apt/keyrings/docker.asc
sudo chmod 0644 /etc/apt/keyrings/docker.asc
lab_ubuntu_codename="$(. /etc/os-release; echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
lab_arch="$(dpkg --print-architecture)"
cat <<EOF | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${lab_ubuntu_codename}
Components: stable
Architectures: ${lab_arch}
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo docker run --rm hello-world
sudo docker compose version
```

This lab requires Docker Engine 28 or later because older releases had a documented same-network exception to localhost port isolation. Docker-published ports can also bypass UFW handling. VM network isolation and an external reachability check are part of this design. [Docker port publishing](https://docs.docker.com/engine/network/port-publishing/)

## 2. Run preflight checks

From the repository root:

```bash
sudo bash scripts/preflight.sh
```

Before installing, ports **80**, **8081** and **9443** should be unused. If a service already occupies one, identify it with `sudo ss -ltnp` and resolve the conflict on the lab VM. Do not stop unrelated services blindly. Check available memory and disk against guide 1. On x86, the VM must expose SSSE3. ARM users must also verify current SafeLine release/edition availability; architecture detection alone does not prove licensing compatibility.

## 3. Start DVWA and its database

```bash
bash scripts/init-env.sh
sudo docker compose config --quiet
sudo docker compose pull
sudo docker compose up -d --wait --wait-timeout 180
sudo docker compose ps
curl --noproxy '*' -sS -o /dev/null -w 'Origin HTTP %{http_code}\n' \
  http://127.0.0.1:8081/login.php
sudo docker compose port dvwa 80
```

Expected configuration: the last command reports `127.0.0.1:8081`. The database should be healthy. A login page should be reachable; initialization is completed in the browser in guide 3. A status code alone does not prove the whole application is ready.

The `.env` passwords are generated database credentials. They do not change DVWA's training login (`admin` / `password`). Do not run plain `docker compose config` in a screenshot: it expands secrets. The `--quiet` form checks validity without printing configuration.

Our [Compose file](../compose.yaml) adapts the upstream DVWA services with explicit database variables, a health check, an internal database network, a frontend network needed for reliable loopback publishing, and manual restart behavior. It deliberately sets the default application security level to Low. Authentication remains enabled. The health check follows [MariaDB's supported helper](https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration/docker-and-mariadb/using-healthcheck-sh).

## 4. Install SafeLine separately

SafeLine maintains its own containers and state directory; do not merge them into the DVWA Compose project. Download the vendor's installer from its official source, inspect it and retain its hash locally:

```bash
mkdir -p work/installers
curl --fail --show-error --location \
  https://raw.githubusercontent.com/chaitin/SafeLine/main/scripts/manage.py \
  --output work/installers/safeline-manage.py
sha256sum work/installers/safeline-manage.py > work/installers/safeline-manage.sha256
less work/installers/safeline-manage.py
sudo python3 work/installers/safeline-manage.py --en
```

Select **INSTALL** in the interactive menu. Accept `/data/safeline` as the installation directory for this guide and port `9443` for management. If you choose a different path, replace it in later commands. Follow the edition/region prompts appropriate to your installation and record your actual version. Installation needs outbound internet access. Use the current [vendor deployment page](https://docs.waf.chaitin.com/en/GetStarted/Deploy) if the installer procedure has changed.

The command above invokes the [official installer source](https://github.com/chaitin/SafeLine/blob/main/scripts/manage.py); the file itself is not bundled here. It installs downloaded vendor components with administrator privileges, so inspect it before running. Complete administrator setup immediately on the isolated network. Follow the installed version's password or two-factor setup flow. Save credentials privately; omit passwords, QR codes and recovery material from screenshots.

If the installer tells you to initialize the administrator manually, its currently reviewed command is:

```bash
sudo docker exec safeline-mgt /app/mgt-cli reset-admin --once
```

Use this only for the initial setup when instructed, not as a routine step after every launch. Follow your version's displayed instructions if the command differs.

## 5. Verify the WAF containers

```bash
sudo docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
sudo docker inspect safeline-tengine --format '{{.HostConfig.NetworkMode}}'
```

The network-mode check must show `host` for the loopback upstream design. If it does not, stop and adapt the upstream networking before testing. Open `https://192.168.126.132:9443` in a normal Kali browser. For a self-signed certificate, verify that this is your lab IP and accept it only for this console. The website on port 80 is configured in guide 3; it need not respond yet.

Management may bind on all Ubuntu interfaces in the vendor configuration. Keep this VM on host-only plus outbound NAT, with no port forwarding or bridge. Do not expose it to the Internet. If UFW is already enabled, use narrow SSH/HTTP rules for your host-only network as needed; do not disable the firewall or assume it controls every Docker mapping.

## 6. Record the installed versions

Once both stacks are running:

```bash
sudo bash scripts/collect-environment.sh
sudo chown -R "$(id -u):$(id -g)" evidence/private
```

Review the generated text files and record approved version details in the assessment. Record the SafeLine version/edition from its console, plus Kali and Burp versions, in the report. Record the installer's SHA-256 too. Do not copy SafeLine's `.env`, resource directory or whole configuration dump to GitHub.

For repeatability, inspect the actual image digests:

```bash
sudo docker image inspect ghcr.io/digininja/dvwa:latest --format '{{json .RepoDigests}}'
sudo docker image inspect mariadb:10 --format '{{json .RepoDigests}}'
```

Then replace `DVWA_IMAGE` and `MARIADB_IMAGE` in your private `.env` with the corresponding `repository@sha256:...` values. Do not invent a digest or use a digest for another platform. Record both references in the report. SafeLine has several images; retain their references together and use vendor-supported upgrade procedures. Avoid updates between the baseline and protected tests.

## 7. Pause and resume

From this repository, `sudo docker compose stop` pauses DVWA and MariaDB. Resume with `sudo docker compose up -d --wait --wait-timeout 180`. These services are configured not to auto-start after a reboot. SafeLine uses its own restart policy and may auto-start.

To stop SafeLine as well, open its installation directory in a separate terminal and run its Compose stop command there. Do not confuse `/data/safeline` with this repository. Export and review evidence before restoring snapshots or resetting databases.
