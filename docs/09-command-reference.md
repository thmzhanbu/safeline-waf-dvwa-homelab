# Important commands and why they were used

This reference explains the commands that establish the lab's security properties. It focuses on the decision each command supports, rather than listing every routine package-installation step.

## Generate private configuration

```bash
bash scripts/init-env.sh
```

This creates `.env` with separate random MariaDB application and root passwords. The script refuses to overwrite an existing file, applies restrictive permissions, and never prints the values. `.env` is excluded from Git.

## Validate the host before deployment

```bash
sudo bash scripts/preflight.sh
```

This read-only check verifies a supported CPU architecture, available memory and disk, required tools, Docker Engine 28 or later, Compose availability, and whether ports 80, 8081, or 9443 are already occupied. Failing early avoids misdiagnosing a platform or port problem as a WAF problem.

## Validate and start DVWA

```bash
sudo docker compose config --quiet
sudo docker compose pull
sudo docker compose up -d --wait --wait-timeout 180
sudo docker compose ps
```

`config --quiet` checks the Compose model without exposing expanded secrets. `pull` makes image retrieval explicit. `up --wait` waits for the MariaDB health check and for DVWA to run. DVWA has no application health check in this file, so also verify an HTTP response and initialize its database in the browser. `ps` records the final state and port mappings.

The most important control is in `compose.yaml`:

```yaml
ports:
  - "127.0.0.1:8081:80"
```

Binding the published port to Ubuntu loopback prevents a normal remote connection from Kali. The database is placed on an internal Docker network and has no published host port.

## Verify origin isolation

On Ubuntu:

```bash
sudo ss -ltnp | grep ':8081'
curl --noproxy '*' -I http://127.0.0.1:8081/
```

On Kali:

```bash
curl --connect-timeout 3 -I http://192.168.126.132:8081/
```

The Ubuntu listener should be `127.0.0.1:8081`, and the direct Kali request should fail. Together these checks show that the vulnerable origin is not exposed on the host-only network.

## Create a controlled baseline route

On Kali:

```bash
ssh -N -o ExitOnForwardFailure=yes -L 127.0.0.1:18080:127.0.0.1:8081 anbu@192.168.126.132
```

This local forward makes the Ubuntu loopback origin temporarily available at `http://127.0.0.1:18080` on Kali. `-N` prevents an interactive shell, and `-L` defines only the required forwarding path. The tunnel is used for baseline comparison and closed afterward.

## Configure name resolution for the protected route

On Kali:

```bash
printf '192.168.126.132 dvwa.lab\n' | sudo tee -a /etc/hosts
getent hosts dvwa.lab
curl -I http://dvwa.lab/
```

The hosts entry makes `dvwa.lab` resolve to Ubuntu's SafeLine listener without relying on public DNS. `getent` verifies the resolver's actual answer. The curl request confirms that the protected route is reachable.

## Verify the SafeLine upstream model

On Ubuntu:

```bash
sudo docker inspect safeline-tengine --format '{{.HostConfig.NetworkMode}}'
sudo docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
```

The Tengine container needs host networking for the loopback upstream design used here. The second command records the WAF components and exposed management/listener ports without printing configuration secrets.

## Verify the SafeLine upgrade

```bash
sudo docker exec safeline-mgt /app/mgt version
```

This reads the version of the management container on the current host. It proves that container reports 9.4.2; it does not resolve the conflicting version shown in later browser screenshots. Verify both views belong to the same instance before attributing test outcomes to a release.

## Restore Kali internet routing

```bash
sudo nmcli device connect eth0
ip route
```

The Kali VM used separate host-only and NAT adapters. Reconnecting `eth0` restored the DHCP default route needed to install Burp Suite. The supplied post-reconnection route output shows the NAT route but does not show the host-only route; verify both interfaces and lab reachability separately before resuming tests.

## Capture a safe Burp request

Burp was used to intercept an ordinary unauthenticated request to `http://dvwa.lab/`. The capture showed zero cookies; the subsequent handling of the held request was not captured. This proves the proxy path without publishing a DVWA session identifier.

## Hash public evidence

```bash
python3 scripts/hash-evidence.py
```

This computes SHA-256 for every published PNG and writes `evidence/SHA256SUMS.txt`. Hashes reveal later byte-level changes to the evidence set; they do not independently prove that a screenshot is authentic.
