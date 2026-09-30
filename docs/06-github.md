# 6. Maintain the published portfolio

The public repository is [thmzhanbu/safeline-waf-dvwa-homelab](https://github.com/thmzhanbu/safeline-waf-dvwa-homelab). GitHub hosts the documentation and evidence; the vulnerable application remains in the private lab.

## Review before committing

Keep `.env`, raw Burp exports, authenticated request captures, full service logs, private keys, and recovery material outside the public repository. Review screenshots as images as well as reviewing text changes. The included MIT license covers this project's original documentation and helper code; upstream products retain their own licenses.

Clone the repository once:

```bash
git clone https://github.com/thmzhanbu/safeline-waf-dvwa-homelab.git
cd safeline-waf-dvwa-homelab
```

After a new lab session, update the assessment, results, and evidence review. Record observations even when the WAF allows a request. If new screenshots are added, update the expected image count in `scripts/validate-project.py` after reviewing the new files.

```bash
python3 scripts/hash-evidence.py
python3 scripts/validate-project.py
git status --short
git diff
git add README.md docs reports evidence scripts
git diff --cached --stat
git diff --cached
git commit -m "Document new lab observations and reviewed evidence"
git push
```

`hash-evidence.py` records byte-level integrity; it does not authenticate the image content. The validator checks evidence count, links, test IDs, and hashes. Review image contents separately. Use your configured Git credential manager or SSH authentication; never embed a token in the remote URL.

## Check the published result

Verify the rendered README, architecture diagram, report links, evidence images, and Actions result. The workflow checks script syntax, Compose configuration, report links, and screenshot integrity. It does **not** deploy DVWA, install SafeLine, reproduce the attack tests, or certify WAF effectiveness.

The [Markdown assessment](../reports/ASSESSMENT.md) and [PDF report](../reports/SafeLine-DVWA-Assessment.pdf) describe the supplied evidence. Keep both synchronized when findings change. The [screenshot review](../evidence/EVIDENCE-REVIEW.md) lists useful additions and remaining evidence gaps.
