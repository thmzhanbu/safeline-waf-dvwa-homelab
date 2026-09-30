# Troubleshooting and recovery

Use one layer at a time: VM reachability → origin → WAF routing → authenticated session → protection/logging. A failed attack request is not automatically a successful defense.

| Symptom | Check / correction |
|---|---|
| Kali cannot reach Ubuntu | Both host-only adapters must share a network; confirm actual addresses/routes and SSH service. NAT addresses may not be reachable from the other VM. |
| Port already in use | Inspect `sudo ss -ltnp` and `sudo docker ps`. Burp owns Kali 8080; origin is Ubuntu 8081; tunnel is Kali 18080. Resolve the specific conflict. |
| `.env` missing / interpolation error | Run `bash scripts/init-env.sh` from the repository. Never commit the generated file. |
| Database unhealthy | Check `sudo docker compose logs --tail=80 db` locally. Look for storage exhaustion, unsupported image architecture or initialization errors. Logs may contain secrets; do not publish them unreviewed. |
| DVWA cannot connect to database | Confirm db is healthy and `DB_PASSWORD` matches the database password used when its volume was created. Changing `.env` does not change an already-initialized MariaDB account. |
| Setup page says database absent | Open `/setup.php` on the baseline route and create/reset the lab database. Capture required evidence before resetting. |
| Origin works on Ubuntu, tunnel does not | Keep the SSH command open; confirm Kali 18080 is unused and SSH forwarding is permitted. Do not change the origin mapping to all interfaces to work around it. |
| Burp history is empty | Use Burp's built-in browser. Check scope/history filters. If Intercept is on, forward the held request or turn it off. |
| SafeLine returns 502 | Confirm Ubuntu can reach `127.0.0.1:8081/login.php` and tengine is in host mode. Upstream must be HTTP to port 8081. Check that DVWA is running after a reboot. |
| Default site / wrong application | Confirm Kali resolves `dvwa.lab` correctly and the SafeLine site's domain is exactly `dvwa.lab`; don't test by bare IP when the rule matches a hostname. |
| DVWA path gives 404 | Use `/vulnerabilities/sqli/`, not `/dvwa/vulnerabilities/sqli/`. This image serves the application at its web root. |
| Requests redirect to login | Log in independently on both hostnames. In Repeater, update session cookies and form tokens from that route's own authenticated request. Never publish their values. |
| XSS request shows reflected text but no alert | Repeater does not execute browser JavaScript. Test in the controlled browser and inspect output context. Record a reflection separately from confirmed execution. |
| Expected attack is allowed | Check mode, site, rule profile, allowlists and session. Save the observed response. A missed case is a result to investigate, not a reason to fabricate a block. |
| Denial appears but no WAF event | Inspect site/time filters, time zones, retention, logging status and request path. Distinguish anti-bot/rate-limit/auth gates from the web attack engine. Mark attribution unconfirmed without correlated evidence. |
| Normal traffic starts failing | Run the same harmless controls again. Inspect the corresponding event before changing one narrowly scoped rule. Record change and retest both normal and attack inputs. |
| Kali reaches Ubuntu :8081 directly | Verify exact Docker binding, Engine >=28, no stale containers/forwarders, and no custom direct-routing configuration. Fix exposure before resuming tests. |
| ARM installer/image issue | Record architecture and error; verify current vendor edition and image support. Do not claim the x86 procedure is validated on your ARM release. |

## Private diagnostics

Run on Ubuntu from the repository:

```bash
sudo docker compose ps
sudo docker compose logs --tail=80 dvwa db
sudo docker inspect safeline-tengine --format '{{.HostConfig.NetworkMode}}'
sudo docker logs --tail=80 safeline-tengine
sudo docker logs --tail=80 safeline-detector
```

SafeLine's vendor Compose persists nginx logs below its state directory's `logs/nginx` and detector logs under `logs/detector`. Filenames and log structure can vary; prefer the console event details for the report. Never attach a full `docker inspect`, `.env`, private log directory or Burp project without reviewing it for secrets.

## Resets

For a basic training reset, use DVWA's Setup / Reset DB button. This changes lab data and may invalidate sessions. Save evidence first.

For a completely fresh **DVWA database**, `sudo docker compose down --volumes` from this repository removes the project's containers and database volume. It permanently deletes that lab database. It does not remove SafeLine's separate state. Keep the existing `.env`, then start again and initialize DVWA. Do not run a machine-wide Docker prune.

For routine pause/resume, use `stop` and `up -d`, which retain data. Prefer reverting your dedicated clean VM snapshots for a whole-lab rebuild. Keep those snapshots and raw evidence private.
