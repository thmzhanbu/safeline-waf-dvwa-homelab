# Screenshot selection review

The folder contains 28 reviewed screenshots. None needs to be removed for security. For a recruiter-facing narrative, the images are grouped by how much they contribute to the technical story.

## Core evidence - keep and highlight

| Files | Reason |
|---|---|
| `05` | Proves the origin is not remotely reachable on port 8081 |
| `08` | Shows the SafeLine application and protected hostname |
| `10`–`11` | Establishes DVWA Low and the controlled baseline tunnel |
| `12`–`17` | Complete SQL injection and XSS origin/block/log triads |
| `18`–`24` | Shows the strongest finding: command injection audit-only behavior, upgrade, policy tuning, and final block |
| `25`–`27` | Complete local-file-inclusion origin/block/log triad |
| `28` | Demonstrates Burp interception without publishing session cookies |

## Supporting evidence - retain in the repository

| Files | Reason |
|---|---|
| `01`–`02` | Documents the Ubuntu and Kali platforms |
| `04` | Shows DVWA and MariaDB health plus loopback publication |
| `06`–`07` | Shows SafeLine containers and initial dashboard state |
| `09` | Confirms protected hostname resolution and an HTTP response |

These files are useful during an interview or detailed review but do not need to appear as large images in the main README.

## Optional evidence

| File | Recommendation |
|---|---|
| `03` | Keep for completeness, but it is a generic Docker `hello-world` proof and adds little to the WAF story |

## Useful additions for a future iteration

These are improvements rather than blockers for publication:

1. A single SafeLine site-detail screenshot showing `dvwa.lab`, listener port 80, upstream `127.0.0.1:8081`, and Defense mode together.
2. Same-session management CLI and dashboard version captures tied to the same server, to resolve the version discrepancy.
3. A harmless protected request after the attack tests to demonstrate that policy tuning did not break normal traffic.
4. Burp HTTP history showing one protected malicious request and its 403 response, with cookies and tokens removed.
5. WAF event-detail captures linking block-page request IDs to events, plus policy settings and synchronized UTC timestamps for the command-injection retest.
6. A small benign-traffic regression set and image digests for repeatability.
7. The passing GitHub Actions validation run after publication.

## Publication decision

The current evidence is sufficient for a professional portfolio because every tested vulnerability has an origin observation and a protected comparison, and every claimed block has supporting SafeLine telemetry, with exact request-ID joins still unverified. The limitations above are disclosed in the assessment instead of being hidden.
