# 3. Connect Kali, Burp and SafeLine

## 1. Resolve the protected hostname on Kali

On Kali, edit `/etc/hosts` with `sudoedit /etc/hosts` and add one line using Ubuntu's host-only IP:

```text
192.168.126.132 dvwa.lab
```

Verify with `getent hosts dvwa.lab`. Remove stale entries for the same name. This is a local lab hostname, not a public DNS record.

## 2. Open the controlled baseline route

In a dedicated Kali terminal, replace `labuser` and the IP:

```bash
ssh -N -o ExitOnForwardFailure=yes \
  -L 127.0.0.1:18080:127.0.0.1:8081 labuser@192.168.126.132
```

Leave it running. The terminal normally remains blank after authentication. Kali's `http://127.0.0.1:18080` now goes through SSH to the origin, bypassing SafeLine intentionally. The first loopback address belongs to Kali; the second belongs to Ubuntu. Do not add `-g` or bind to `0.0.0.0`. Close the terminal with Ctrl+C when baseline testing is finished.

## 3. Start Burp and initialize DVWA

Open Burp Suite Community on Kali. If missing, install it from [PortSwigger](https://portswigger.net/burp/documentation/desktop/getting-started/download-and-install). Choose a temporary project with default settings. Confirm its proxy listener uses Kali `127.0.0.1:8080`.

Use **Proxy → Intercept → Open browser**. Burp's built-in browser is already configured for interception; leave **Intercept off** for normal navigation. This avoids Firefox's localhost proxy exceptions. [PortSwigger browser/proxy tutorial](https://portswigger.net/burp/documentation/desktop/getting-started/intercepting-http-traffic)

In that browser:

1. Open `http://127.0.0.1:18080/setup.php` and choose **Create / Reset Database**. If prompted, first use the DVWA training login `admin` / `password` and then open Setup / Reset DB. Reset only this lab database.
2. Log in to DVWA. Open **DVWA Security**, choose **Low**, and submit. Confirm the displayed level.
3. Browse normally, then check Burp's HTTP history for this host and port. A login redirect by itself is not authenticated access.
4. Add `http://127.0.0.1:18080` and `http://dvwa.lab:80` to Burp's target scope. Filter history to those targets; keep SafeLine administration outside the test scope. [Target scope](https://portswigger.net/burp/documentation/desktop/getting-started/setting-target-scope)

If using Firefox instead, configure its HTTP proxy as `127.0.0.1:8080` and ensure the local addresses are actually proxied; verify in Burp history. The built-in browser is the recommended route for this guide. The target uses HTTP, so installing a Burp CA certificate is unnecessary for the application tests.

## 4. Add DVWA to SafeLine

In a separate normal browser, open `https://192.168.126.132:9443` and sign in. Find website/application management and add a reverse-proxy site. Exact labels vary by SafeLine release; the values are:

| Setting | Value |
|---|---|
| Site name | `DVWA homelab` |
| Hostname/domain | `dvwa.lab` |
| HTTP listening port | `80` |
| Upstream/origin | `http://127.0.0.1:8081` |
| Host header | Preserve the incoming host/default behavior |
| Web attack protection | Enabled, enforcing/blocking action |

If scheme, host and port are separate fields, select **HTTP**, address **127.0.0.1**, port **8081**. Save/apply the site and confirm its running/enabled state. The vendor's [application configuration guide](https://docs.waf.chaitin.com/en/GetStarted/AddApplication) is the reference if the UI differs.

Record the actual protection mode, rule profile and software version. A monitor/log-only mode does not establish prevention. Avoid blanket IP allowlists, broad exclusions, anti-bot challenges or unrelated authentication gates during the core SQLi/XSS tests because they can obscure which control handled a request. Document any defaults you change. Leave optional rate-limit testing for a separate case.

Capture the site configuration without credentials or account secrets. If your edition does not expose a described control, record the available equivalent or mark it unavailable; do not invent a UI option.

## 5. Validate the protected route

On Kali:

```bash
curl --noproxy '*' --max-time 10 -sS -o /dev/null -w 'Protected HTTP %{http_code}\n' \
  http://dvwa.lab/login.php
```

In Burp's browser, open `http://dvwa.lab/login.php`, log in separately and set DVWA Security to **Low** again. The baseline and protected hostnames have separate session cookies. Confirm normal login, navigation and a harmless module input work. A default nginx page, 502, login loop or generic access error must be fixed before vulnerability testing.

## 6. Prove the origin is not directly reachable

On Kali, request Ubuntu's network IP on the origin port:

```bash
curl --noproxy '*' --connect-timeout 3 --max-time 5 -v \
  http://192.168.126.132:8081/login.php
```

Expected: connection refused or timeout, with **no HTTP application response**. Pair this with successful protected access to the same Ubuntu IP/host and successful origin access from Ubuntu. That establishes the difference between isolation and a server that is simply offline. Save the terminal proof as optional infrastructure evidence.

If this returns a page or any HTTP status from the origin, stop: check the loopback mapping, Docker version, old containers, VM port forwards and any custom routing. Do not continue with a claim that the origin is private until it is fixed.

## 7. Ready for tests

You now have two deliberate paths:

- Baseline: `http://127.0.0.1:18080/vulnerabilities/...` over the SSH tunnel.
- Protected: `http://dvwa.lab/vulnerabilities/...` through SafeLine.

Keep the DVWA image, database state and **Low** security level the same for both. Change only the route and its required host/session details when comparing payloads. Keep a UTC clock visible or record timestamps immediately. Continue to [paired testing](04-testing.md).
