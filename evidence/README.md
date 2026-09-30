# Reviewed evidence index

Status: **complete**. All 28 screenshots were visually reviewed before inclusion.

The review found no passwords, recovery codes, private keys, API tokens, session-cookie values, QR codes, or unrelated application content. Local usernames and RFC 1918 addresses remain visible because they document the lab topology and contain no reusable authentication secret.

| Files | What they establish |
|---|---|
| `01`–`06` | Ubuntu and Kali environments, Docker/DVWA deployment, origin isolation, and SafeLine containers |
| `07`–`11` | SafeLine dashboard and application configuration, protected route, DVWA Low security, and SSH baseline tunnel |
| `12`–`14` | SQL injection succeeds at the origin and is blocked and logged through SafeLine |
| `15`–`17` | Reflected XSS succeeds at the origin and is blocked and logged through SafeLine |
| `18`–`24` | Command injection origin success, allowed protected tests, upgrade record, Strict setting, and blocked tests; attribution limits are disclosed |
| `25`–`27` | Local file inclusion succeeds at the origin and is blocked and logged through SafeLine |
| `28` | Burp Suite Community intercepts a cookie-free request to the protected hostname |

## Complete file list

1. `01-ubuntu-environment.png`
2. `02-kali-environment.png`
3. `03-docker-installation-done.png`
4. `04-dvwa-running.png`
5. `05-origin-isolation.png`
6. `06-safeline-running.png`
7. `07-safeline-dashboard.png`
8. `08-safeline-application-config.png`
9. `09-protected-route.png`
10. `10-dvwa-security-low.png`
11. `11-origin-tunnel.png`
12. `12-sqli-origin-success.png`
13. `13-sqli-waf-block.png`
14. `14-sqli-safeline-event.png`
15. `15-xss-origin-alert.png`
16. `16-xss-waf-block.png`
17. `17-xss-safeline-log.png`
18. `18-command-origin-success.png`
19. `19-command-waf-bypass-before-fix.png`
20. `20-safeline-upgraded-9.4.2.png`
21. `21-command-waf-bypass-after-upgrade.png`
22. `22-semantic-analysis-set-to-strict.png`
23. `23-command-waf-block-strict.png`
24. `24-command-safeline-log.png`
25. `25-file-inclusion-origin-success.png`
26. `26-file-inclusion-waf-block.png`
27. `27-file-inclusion-safeline-log.png`
28. `28-burp-intercept-dvwa.png`

## Interpretation notes

- The command-injection sequence shows allowed requests, a recorded upgrade, a Strict policy setting, and subsequent blocked requests. This supports policy tuning as the working remediation. The version discrepancy and missing request-level policy snapshots prevent attributing the change solely to the upgrade or to a single configuration change.
- Screenshot `20` reports management-container version `9.4.2`; later dashboard captures still show `9.1.0-lts`. The available evidence does not establish why they differ or independently link every test to the upgraded instance. Exact test-version attribution remains unverified.
- Times are recorded as displayed by each VM or application. The screenshots do not establish that every component used the same timezone.
- `SHA256SUMS.txt` records the exact evidence files included in this deliverable.
