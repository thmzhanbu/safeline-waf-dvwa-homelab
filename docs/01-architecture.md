# 1. Plan the VMs and network

## Roles and example addresses

You already have Kali and Ubuntu. Keep Kali as the tester and Ubuntu as the server. This guide assumes an Ubuntu Server 24.04 LTS VM, rootful Docker Engine, and an ordinary Kali desktop. A newer supported Ubuntu release can work; verify it against Docker and SafeLine requirements before installing.

| Machine | Suggested allocation | Host-only IP | Role |
|---|---|---|---|
| Ubuntu | 4 vCPU, 6–8 GB RAM, 40 GB disk | `192.168.126.132/24` | SafeLine, DVWA, MariaDB, SSH |
| Kali | 2 vCPU, 4 GB RAM, 30 GB disk | `192.168.126.133/24` | Burp, browser, evidence capture |

The addresses match the supplied host-only evidence; resource allocations in this guide are recommendations, not measurements. Substitute your own addresses in commands and record them in your new test report. Check for overlaps with VPN, LAN and Docker subnets. Both guests must use the same host-only network. On Apple Silicon, use ARM64 guest images and confirm the installed SafeLine release supports that architecture; do not follow x86-only ISO instructions blindly.

In your hypervisor, add a host-only adapter to each VM. Use NAT as a separate adapter for package/image downloads, with no forwarded ports. Do not use bridged networking. Reserve DHCP leases or assign unused static addresses through your VM's normal network settings; leave gateway/DNS blank on the host-only adapter and keep the default route on NAT. Do not paste interface names from another machine.

Take a clean snapshot of each VM before installation. After provisioning, disconnect the NAT adapters during the manual tests if the installed SafeLine release operates normally without them. If your version needs cloud connectivity, document that dependency and retain outbound-only NAT. A host-only network is still shared with the host and any other VMs attached to it; keep unrelated guests off it.

## Addresses and ports

| Service | Address used by tester | Purpose |
|---|---|---|
| WAF protected site | `http://dvwa.lab` → Ubuntu `:80` | All protected application tests |
| SafeLine console | `https://192.168.126.132:9443` | Administration on isolated lab network |
| SSH | Ubuntu `:22` | Administration and temporary baseline tunnel |
| DVWA origin | Ubuntu `127.0.0.1:8081` | SafeLine upstream, never published to the VM's network IP |
| Baseline tunnel | Kali `127.0.0.1:18080` | Controlled route around the WAF for comparison |
| Burp listener | Kali `127.0.0.1:8080` | Browser interception; distinct from DVWA's port |
| MariaDB | Container network only | No published host port |

The supplied Compose file keeps MariaDB on an internal backend network with no published database port. DVWA also joins a normal frontend network so Docker can create the loopback web mapping reliably. DVWA can therefore make outbound connections while Ubuntu has internet access; disconnect the VM's NAT adapter during testing when your installed SafeLine release permits it. This is a practical lab boundary, not a sandbox guarantee against a host compromise.

## Why localhost works for the WAF upstream

The [official SafeLine Compose file](https://github.com/chaitin/SafeLine/blob/main/compose.yaml) uses Linux host networking for `safeline-tengine`. It therefore reaches Ubuntu's `127.0.0.1:8081`. Use that address as the upstream. Do not substitute `localhost:8080`, a Kali address, `dvwa.lab`, or a Docker service name: they refer to a different endpoint or can create a proxy loop. Check the installed container's network mode before relying on this design.

## Reachability checks

On each VM:

```bash
ip -br address
ip route
date -u
```

On Kali, after Ubuntu SSH is installed:

```bash
ping -c 3 192.168.126.132
ssh labuser@192.168.126.132
```

Replace `labuser` with your actual Ubuntu username. Check the SSH host fingerprint against the Ubuntu console on first connection. Synchronize both VM clocks before correlating test times. After deployment, validate that WAF traffic works while direct origin traffic fails; see guide 3.

The lab intentionally uses HTTP to make request analysis simple. This demonstrates inspection of HTTP traffic, not HTTPS certificate deployment, TLS hardening, high availability or production readiness.
