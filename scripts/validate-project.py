#!/usr/bin/env python3
"""Validate the public portfolio structure, evidence links, CSV, and checksums."""
from __future__ import annotations

import csv
import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
EXPECTED_TESTS = {"SQLI-01", "XSS-01", "CMD-01A", "CMD-01B", "CMD-01C", "LFI-01", "BURP-01"}
errors: list[str] = []

pngs = sorted((ROOT / "evidence").glob("*.png"))
if len(pngs) != 28:
    errors.append(f"expected 28 evidence PNGs, found {len(pngs)}")

with (ROOT / "reports/results.csv").open(newline="", encoding="utf-8") as stream:
    rows = list(csv.DictReader(stream))
ids = {row["test_id"] for row in rows}
if ids != EXPECTED_TESTS:
    errors.append(f"unexpected test IDs: {sorted(ids ^ EXPECTED_TESTS)}")
for row in rows:
    for column in ("baseline_evidence", "protected_evidence", "waf_evidence"):
        target = row[column]
        if target and not (ROOT / "reports" / target).resolve().exists():
            errors.append(f"missing CSV evidence: {row['test_id']} {target}")

for markdown in ROOT.rglob("*.md"):
    for target in LINK_RE.findall(markdown.read_text(encoding="utf-8")):
        if target.startswith(("http://", "https://", "#", "mailto:")):
            continue
        clean = target.split("#", 1)[0]
        if clean and not (markdown.parent / clean).resolve().exists():
            errors.append(f"broken link in {markdown.relative_to(ROOT)}: {target}")

manifest = ROOT / "evidence/SHA256SUMS.txt"
recorded: dict[str, str] = {}
for line in manifest.read_text(encoding="utf-8").splitlines():
    digest, filename = line.split("  ", 1)
    recorded[filename] = digest
for image in pngs:
    actual = hashlib.sha256(image.read_bytes()).hexdigest()
    if recorded.get(image.name) != actual:
        errors.append(f"checksum mismatch: {image.name}")
if set(recorded) != {image.name for image in pngs}:
    errors.append("checksum manifest and PNG set differ")

if errors:
    print("Validation failed:")
    print("\n".join(f"- {error}" for error in errors))
    sys.exit(1)
print(f"Validation passed: {len(pngs)} images, {len(rows)} result rows, links and checksums verified.")
