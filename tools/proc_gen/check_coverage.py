#!/usr/bin/env python3
"""
Compares constraints.md (the intent catalog) against constraints.py (the code
registry) and reports gaps. Exit code 1 if any constraint in the MD is missing
from the code.
"""

import re
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

MD_PATH = PROJECT_ROOT / "tools" / "proc_gen" / "constraints.md"


def parse_md_ids(path: Path) -> set:
    """Extract constraint IDs from the markdown file.

    Looks for section headers like:
        ### R01 — Exit reachable from player via jump graph
        ### J02 — Vertical jump up ≤ 4 tiles on critical path
    """
    ids = set()
    id_re = re.compile(r"^###\s+([RJHPSO]\d{2})\s+—")
    for line in path.read_text(encoding="utf-8").splitlines():
        m = id_re.match(line.strip())
        if m:
            ids.add(m.group(1))
    return ids


def load_registry() -> dict:
    """Import constraints.py and return its registry dict."""
    from tools.proc_gen import constraints
    return constraints.get_registry()


def main() -> int:
    md_ids = parse_md_ids(MD_PATH)
    registry = load_registry()
    code_ids = set(registry.keys())

    missing_in_code = md_ids - code_ids
    missing_in_md = code_ids - md_ids

    # "Implemented" means the MD demands a code equivalent AND the entry is
    # marked as actually implemented (not a stub).
    implemented_in_code = {cid for cid, info in registry.items() if info.get("implemented", True)}
    implemented_count = len(md_ids & implemented_in_code)

    stubs = {cid for cid, info in registry.items() if not info.get("implemented", True)}

    total_md = len(md_ids)

    print(f"Constraints in catalog:        {total_md}")
    print(f"Constraints in code registry:  {len(code_ids)}")
    print(f"Implemented in code:           {implemented_count}/{total_md}")

    if missing_in_code:
        print(f"\nMissing in code (need implementation):")
        for cid in sorted(missing_in_code):
            print(f"  - {cid}")

    if stubs:
        print(f"\nRegistered but still stubs:")
        for cid in sorted(stubs):
            print(f"  - {cid}")

    if missing_in_md:
        print(f"\nIn code but not in constraints.md (stale or undocumented):")
        for cid in sorted(missing_in_md):
            print(f"  - {cid}")

    if not missing_in_code and not stubs and not missing_in_md:
        print("\nCoverage: 100% (every catalog constraint has a real implementation)")

    return 1 if (missing_in_code or stubs) else 0


if __name__ == "__main__":
    sys.exit(main())
