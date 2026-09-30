#!/usr/bin/env python3
"""Hash the reviewed public PNG evidence deterministically."""
import hashlib
from pathlib import Path

root = Path(__file__).resolve().parents[1]
evidence = root / "evidence"
paths = sorted(path for path in evidence.glob("*.png") if path.is_file())
manifest = evidence / "SHA256SUMS.txt"
if not paths:
    raise SystemExit("No public PNG evidence found.")
lines = [f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}" for path in paths]
manifest.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Hashed {len(paths)} files into {manifest.relative_to(root)}")
print("Hashes reveal file changes; they do not independently establish authenticity.")
