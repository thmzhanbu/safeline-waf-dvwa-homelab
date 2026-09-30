# Test DVWA with and without SafeLine

This procedure integrates the manual DVWA exercises from the supplied brief with a controlled SafeLine comparison. Kali runs Burp Suite and the browser; Ubuntu runs SafeLine and DVWA. Run these exercises only against these lab targets.

**Execution status: COMPLETE.** The procedure below was used as the test plan. The observed outcomes are recorded in the [completed assessment](../reports/ASSESSMENT.md), [results table](../reports/results.csv), and [reviewed evidence index](../evidence/README.md).

Complete [Ubuntu setup](02-ubuntu-setup.md) and [Kali and SafeLine setup](03-kali-and-safeline.md) first. See [architecture](01-architecture.md) for the full network design.

## 1. Know the two routes

| Route | URL opened on Kali | Path to DVWA | Purpose |
|---|---|---|---|
| Baseline | `http://127.0.0.1:18080` | Kali SSH tunnel → Ubuntu `127.0.0.1:8081` → DVWA | Observe application behavior without SafeLine |
| Protected | `http://dvwa.lab` | Ubuntu host-only address, port 80 → SafeLine → Ubuntu `127.0.0.1:8081` → DVWA | Observe application behavior with SafeLine |

The baseline tunnel is deliberately available only to Kali's loopback address. Leave its terminal open for the entire baseline test. Run this from Kali after replacing `YOUR_UBUNTU_USERNAME` with your Ubuntu username:

```bash
ssh -N -o ExitOnForwardFailure=yes -L 127.0.0.1:18080:127.0.0.1:8081 YOUR_UBUNTU_USERNAME@192.168.126.132
```

Do not use `http://192.168.126.132:8081` as the baseline. DVWA's port is bound to Ubuntu loopback and should not be reachable that way. Burp uses port **8080**, the baseline tunnel uses **18080**, and the Ubuntu backend uses **8081**.

## 2. Prepare an evidence record

1. Review the [completed assessment](../reports/ASSESSMENT.md), VM addresses, installed versions, and evidence references before publication.
2. Open [results.csv](../reports/results.csv). Leave a test `NOT RUN` until you have actually sent and inspected its requests.
3. On both VMs, run `date -u +'%Y-%m-%dT%H:%M:%SZ'` and check that their clocks agree. Record the timezone used by SafeLine's log viewer and convert event times to UTC in your report.
4. Record the DVWA image/revision, SafeLine version/edition, Burp version, and active SafeLine configuration. Record each change to protection mode, rule, threshold, or exception during the exercise.
5. Keep the DB, application version, payload, DVWA security level, and SafeLine configuration stable during a paired test. A change between baseline and protected requests makes that pair unsuitable for a direct comparison.

## 3. Prepare Burp and authenticate each route

1. Open Burp Suite Community Edition on Kali. Create a temporary project and confirm its proxy listener is `127.0.0.1:8080`.
2. Use **Proxy → Open browser** to use Burp's built-in browser. Menu wording can vary by version. Keep Intercept off during navigation and inspect Proxy HTTP history.
3. In one tab, open `http://127.0.0.1:18080`. Log in to DVWA, then set **DVWA Security → Low**. The initial training credentials are documented in the setup guide; do not put a login request or password in a published screenshot.
4. In a second tab, open `http://dvwa.lab`. Log in again and set **DVWA Security → Low** for this route too.
5. Verify that each route shows an authenticated DVWA page and the Low security level. The sites use different hostnames, so their session cookies are independent. Do not copy a baseline session cookie into a protected request.
6. Visit `/vulnerabilities/sqli/` and submit the harmless value `1` on each route. Confirm ordinary functionality, not just an HTTP status code. Capture `02-good-baseline.png` and `03-good-protected-before.png`.

Paths in this deployment start with `/vulnerabilities/`. There is **no `/dvwa` prefix**.

For Repeater tests, capture a fresh request from the relevant route and send that request to Repeater. Preserve its authenticated cookie, current token if the form uses one, HTTP method, and other form fields. Let Burp URL-encode parameters as needed. A login redirect, expired token, or application error is not proof of a WAF block.

## 4. Apply the same comparison method to each test

Use this sequence for SQL injection, reflected XSS, command injection, and file inclusion:

1. Record the case ID and UTC start time. Confirm DVWA Low for both sessions and note SafeLine's actual active mode.
2. Send the baseline request. Inspect the response body and browser behavior; record what actually happened. Save the request/response privately with its time.
3. Capture a fresh authenticated request for the protected route. Send the **same attack-bearing payload** using the same method and form parameters. Route-specific session cookies and any fresh CSRF token must remain route-specific.
4. Record the protected request's UTC time and complete observed result: application content, warning, challenge, denial, redirect, or error. Save its request/response privately.
5. Open SafeLine's event/log view. Filter by the relevant time window, source address, host and path. Correlate the event to the exact request, using the decoded parameter/payload when the log exposes it. Record the event/request ID, event UTC time, category/rule if available, **actual action**, and the configured mode.
6. Capture the baseline, protected response, and matching event screenshots listed in [the evidence guide](05-evidence.md). Redact session cookies and secrets in the public copies.
7. Update the result row. If the baseline did not demonstrate the expected vulnerability, mark the pair `INCONCLUSIVE` and diagnose the application/session before continuing. If no matching WAF event is available, record that fact; do not infer a block from a 403, a page title, or a changed response length.

### Result vocabulary

| Status | Use it when |
|---|---|
| `NOT RUN` | No complete observed result has been recorded. |
| `BASELINE OBSERVED` | The baseline response demonstrates the tested behavior. This alone says nothing about SafeLine. |
| `BLOCK CONFIRMED` | The protected request is correlated to a SafeLine event whose action indicates blocking, and the response is consistent with that action. State only what this request demonstrates. |
| `DETECTED ONLY` | A matching event records detection/observation without a blocking action. |
| `CHALLENGED` | A matching event and response show a challenge. This is distinct from a confirmed block. |
| `ALLOWED / OBSERVED` | The protected request returned the relevant application behavior. Record whether a corresponding allow/detection event exists. |
| `INCONCLUSIVE` | Session, token, connectivity, insufficient logs, or other uncertainty prevents a supported conclusion. |
| `NOT TESTED` | An optional case was deliberately omitted. |

An observed successful response with no event can support “the payload reached the application and produced this result,” but it does not explain why SafeLine allowed it. A matching block event establishes SafeLine's recorded handling of that request; it does not establish complete coverage of that vulnerability class or prove that all backend processing was prevented.

## 5. SQL injection — `SQLI-01`

**Path:** `/vulnerabilities/sqli/`  
**Input:** `id` / User ID  
**Main comparison payload:**

```text
1' UNION SELECT version(), database()-- -
```

First submit `1` as the control. On the baseline, you may submit a single quote (`'`) to observe error handling, but a database-looking error alone is not a completed extraction finding. The main payload attempts to display the lab database version and database name in the two output columns.

Submit the main payload through the form, inspect the request in Burp, and then repeat it on the protected route. Record the actual returned values or the actual failure. Do not assume success from the payload syntax.

The supplied brief also includes this optional exercise:

```text
1' UNION SELECT user, password FROM users-- -
```

Use it only against DVWA's synthetic lab records. It exposes hashes in the training database; redact them from public evidence. If you run it, add a separate result row and evidence references because it is a different payload. The version/database comparison is sufficient for the core lab and avoids publishing credential material. Do not describe a limited extraction as proven access to every table or as a complete database compromise.

**Capture:** `04-sqli-baseline.png`, `05-sqli-protected.png`, `06-sqli-waf-event.png`.

**Application remediation to explain in the report:** parameterized queries, least-privileged database accounts, and safe error handling. SafeLine is an additional control; it does not change DVWA's vulnerable query.

## 6. Reflected XSS — `XSS-01`

**Path:** `/vulnerabilities/xss_r/`  
**Input:** `name`  
**Comparison payload:**

```html
<script>alert(1)</script>
```

Submit through the browser on each route. Browser execution matters: Repeater showing the payload in an HTML response does not by itself establish script execution. For a successful baseline, capture the alert and visible lab URL. Inspect Burp's response to identify the reflection context and record any escaping or filtering you actually see.

Use only a local `alert(1)` demonstration. The source brief's external cookie-redirect example is unnecessary for proving XSS and is not part of this procedure.

**Capture:** `07-xss-baseline.png`, `08-xss-protected.png`, `09-xss-waf-event.png`.

**Optional separate application exercise:** after completing all Low-versus-Low WAF comparisons, set the **baseline session only** to DVWA Medium. Try the same payload and, optionally, a local alert variant such as `<img src=x onerror=alert(1)>`. Label these `DVWA Medium application-filter tests`; they do not measure SafeLine effectiveness. Record the actual result without assuming that Medium is secure or that a variant works. Restore Low before any further paired comparison.

**Application remediation:** context-appropriate output encoding, safe templating, and a restrictive Content Security Policy as defense in depth.

## 7. Command injection — `CMD-01`

**Path:** `/vulnerabilities/exec/`  
**Input:** `ip` / IP address  
**Comparison payload:**

```text
127.0.0.1; id
```

Use `127.0.0.1` as a harmless control. The appended `id` command prints the identity of the account running the command in the DVWA container. It does not establish execution on the Ubuntu host. If the response contains `uid=...`, record exactly what it shows; if it does not, record the actual response and investigate without inventing output.

**Capture:** `10-command-baseline.png`, `11-command-protected.png`, `12-command-waf-event.png`.

**Application remediation:** avoid shell execution for this feature; use a fixed executable and a safe argument API when execution is required, validate input as an IP address, and run the application with least privilege.

## 8. Local file inclusion/read — `LFI-01`

**Path:** `/vulnerabilities/fi/`  
**Input:** `page` in the URL query  
**Comparison payload:**

```text
../../../../../../etc/passwd
```

Open a normal File Inclusion module link first so Burp captures the correct request. Change only its `page` value to the payload. If you use Repeater, preserve the authenticated route-specific session.

The payload attempts to display `/etc/passwd` **inside the DVWA container**. The file is an account listing and is not a plaintext-password file. Record only what is visible. A successful read of this file does not establish host filesystem access, arbitrary code execution, or access to every file.

**Capture:** `13-lfi-baseline.png`, `14-lfi-protected.png`, `15-lfi-waf-event.png`.

**Application remediation:** map a small set of allowed page IDs to fixed files; avoid user-controlled include paths and restrict the application's filesystem access.

## 9. Bounded authentication demonstration — optional `AUTH-01`

**Path:** `/vulnerabilities/brute/`  
**Scope:** the training form inside your authenticated DVWA session; use synthetic DVWA credentials only.

This is a five-request demonstration, not a password-cracking exercise. Use the DVWA seeded `admin` account only if it still has the known training password. The five candidate values can be `lab-wrong-01`, `lab-wrong-02`, `lab-wrong-03`, `lab-wrong-04`, and the known training password. Replace the last candidate if you changed that password. Keep all values private in published artifacts.

1. Capture one form submission in Burp; send it to Repeater. The outer DVWA session must still be authenticated.
2. Send at most five attempts for this one account, one at a time, at least two seconds apart. Alternatively, use Community Intruder with exactly those five values and a single concurrent request if your installed version supports that setting. Do not load `rockyou.txt` or another broad wordlist.
3. Inspect the response body for the application's success/failure message. A length or status difference is a lead, not a confirmed successful login.
4. If comparing routes, use the identical five candidates and spacing on the protected route with its own authenticated session. This is at most ten attempts total across the pair.
5. Record results and any correlated SafeLine events. Record rate-limit/challenge settings if configured. Generic injection filtering does not establish protection against weak passwords, credential guessing, missing lockouts, or other authentication logic defects.
6. If a rate limit blocks or challenges the traffic, stop the sequence and record how many requests were actually sent. Do not keep guessing to work around the control.

The optional row is initially `NOT RUN`. Mark it `NOT TESTED` if you omit it. Document credential values privately and publish only redacted request/response evidence. Application remediation includes strong authentication, MFA where appropriate, and carefully designed rate limiting and account-abuse monitoring.

## 10. Verify ordinary traffic after the tests

1. Return to the protected SQL Injection module and submit `1` again. Confirm the authenticated application still works.
2. Compare with the ordinary request captured before testing. Capture `16-good-protected-after.png`.
3. If you encounter a block, challenge, login redirect, or rate limit, record it. Do not disable a control simply to make the final screenshot look successful. Explain the observed state and any later configuration change.
4. Complete [the evidence release checks](05-evidence.md), then update the completed report with the results from your new test session.

A sound conclusion can be “these two payloads were blocked, one was allowed, and one was inconclusive.” Publishing a limitation with evidence is better than claiming universal protection from a few requests.
