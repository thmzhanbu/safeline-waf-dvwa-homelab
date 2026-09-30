# Evidence workflow and release review

**Evidence review: completed for the supplied set.** The final set contains 28 live lab screenshots. The [evidence index](../evidence/README.md) records the authoritative filenames and interpretations, while [SHA256SUMS.txt](../evidence/SHA256SUMS.txt) records file integrity.

## Capture and correlation method

- Capture enough context to identify the route, module, payload, response, and relevant WAF action.
- Preserve both successful origin behavior and the protected comparison.
- Correlate protected requests using host/path, payload, source IP, displayed time, and event ID when available.
- Describe `Audited` as detected but allowed. Describe prevention only when the client receives a block and the WAF records a matching blocked event.
- Keep the private origin reachable only through the temporary SSH loopback tunnel.
- Use flattened PNGs and inspect every public copy for authentication material and unrelated content.

## Evidence coverage

| Gate | Evidence | Status |
|---|---|---|
| Network isolation | Loopback binding plus refused direct Kali connection | PASS |
| Environment record | Platform captures available; WAF version discrepancy and image digests unresolved | PARTIAL |
| Correct routing | SSH baseline tunnel and `dvwa.lab` protected path shown | PASS |
| Comparable sessions | DVWA Low shown; per-request policy/session snapshots incomplete | PARTIAL |
| SQL injection pair | Origin success, WAF block, and matching event | PASS |
| Reflected XSS pair | Origin execution, WAF block, and matching event | PASS |
| Command injection pair | Origin/allow/block observations shown; exact policy/version attribution incomplete | PARTIAL |
| Local file inclusion pair | Origin success, WAF block, and matching event | PASS |
| Burp interception | Cookie-free protected request captured | PASS |
| Public evidence review | All 28 images opened and reviewed | PASS |
| Report consistency | Markdown report and CSV checked against evidence | PASS |

## Public review outcome

The published screenshots contain no passwords, private keys, API tokens, recovery codes, QR codes, or reusable session-cookie values. Local usernames and private RFC 1918 addresses are retained to explain the topology. The screenshots should still be re-reviewed if they are edited or replaced.

## Known evidence constraints

- Displayed times were not proven to use a single timezone across every component.
- The SafeLine list view does not expose an event ID for every audited command-injection row.
- Screenshot `20` reports management-container version `9.4.2`; later dashboard captures still show `9.1.0-lts`. The available evidence does not establish why they differ or independently link every test to the upgraded instance. Exact test-version attribution remains unverified.
- One representative payload per vulnerability class validates the control behavior but is not exhaustive bypass testing.

The complete interpretation is in the [assessment](../reports/ASSESSMENT.md).
