"""Compile every paper source to build/<basename>.pdf.

The canonical convention for this repo: generated PDFs live under
build/ (which is gitignored), source .typ files live at the root. Run
this script instead of calling `typst compile` directly so the output
path is never forgotten — the .gitignore will only catch root-level
strays defensively.

Before compiling, the script syncs the engineering repo's prompts/
into thesis/prompts/ (gitignored) so the bd-risk.zh appendix's
``read("prompts/...")`` calls resolve inside the project root.

Usage:
    uv run python scripts/build.py            # all sources
    uv run python scripts/build.py bd-risk    # one source (with or without .typ)
    uv run python scripts/build.py --watch    # rebuild on save
"""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

# Force UTF-8 stdout on Windows so the status banner doesn't choke on
# emoji when the active codepage is GBK / CP936.
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
PROMPTS = ROOT / "prompts"

# Every .typ at repo root is treated as a paper source. Add deliberate
# excludes here (templates, includes) if any appear later.
EXCLUDE_STEMS: set[str] = set()


def sync_prompts() -> None:
    """Copy <engineering-repo>/prompts/*.md into thesis/prompts/.

    Required because bd-risk.zh.typ embeds the production prompts via
    ``read("prompts/...")``. The canonical copies live in the
    engineering repo; we mirror them here so typst stays self-contained
    inside the project root.

    Lookup order:
      1. $MOODTRAIL_REPO/prompts  (explicit override)
      2. ../prompts                (nested layout: thesis/ inside engineering repo)
      3. ../reddit/prompts         (sibling layout after thesis is split out)
    """
    env_override = os.environ.get("MOODTRAIL_REPO")
    candidates = []
    if env_override:
        candidates.append(Path(env_override).resolve() / "prompts")
    candidates.append((ROOT.parent / "prompts").resolve())
    candidates.append((ROOT.parent / "reddit" / "prompts").resolve())

    src_dir = next((p for p in candidates if p.is_dir()), None)
    if src_dir is None:
        tried = "\n  ".join(str(p) for p in candidates)
        sys.exit(
            "Engineering repo prompts not found. Tried:\n  "
            + tried
            + "\nSet MOODTRAIL_REPO=/path/to/reddit to point at it explicitly."
        )

    PROMPTS.mkdir(exist_ok=True)
    copied = 0
    for f in src_dir.glob("*.md"):
        target = PROMPTS / f.name
        # Skip unchanged files so typst's incremental build cache
        # doesn't invalidate on every script run.
        if target.exists() and target.read_bytes() == f.read_bytes():
            continue
        target.write_bytes(f.read_bytes())
        copied += 1
    if copied:
        print(f"[sync] copied {copied} prompt file(s) from {src_dir} -> prompts/")
    else:
        print(f"[sync] prompts/ already up to date (source: {src_dir})")


def _strip_typ_suffix(name: str) -> str:
    """Strip only the final ``.typ`` so 'bd-risk.zh' and
    'bd-risk.zh.typ' both resolve to the source stem 'bd-risk.zh'.
    Path.stem would chew off the locale tag too."""
    return name[:-4] if name.endswith(".typ") else name


def discover_sources(filters: list[str] | None) -> list[Path]:
    candidates = sorted(p for p in ROOT.glob("*.typ") if p.stem not in EXCLUDE_STEMS)
    if not filters:
        return candidates
    wanted = {_strip_typ_suffix(f) for f in filters}
    matched = [p for p in candidates if p.stem in wanted]
    missing = wanted - {p.stem for p in matched}
    if missing:
        sys.exit(f"No such source(s): {', '.join(sorted(missing))}")
    return matched


def compile_one(src: Path, watch: bool = False) -> int:
    out = BUILD / f"{src.stem}.pdf"
    cmd = ["typst", "watch" if watch else "compile", str(src.name), str(out.relative_to(ROOT))]
    print(f"$ {' '.join(cmd)}")
    return subprocess.call(cmd, cwd=str(ROOT))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("sources", nargs="*",
                        help="Source stems (e.g. 'bd-risk' or 'bd-risk.typ'). "
                             "Default: every .typ at repo root.")
    parser.add_argument("--watch", action="store_true",
                        help="Pass to `typst watch` so each save triggers a rebuild. "
                             "Only meaningful with a single source.")
    parser.add_argument("--no-sync", action="store_true",
                        help="Skip mirroring prompts/ from the engineering repo. "
                             "Use when you've already synced or want to compile "
                             "with a frozen local copy.")
    args = parser.parse_args()

    if shutil.which("typst") is None:
        sys.exit("typst not found on PATH. Install from https://typst.app/")

    if not args.no_sync:
        sync_prompts()

    BUILD.mkdir(exist_ok=True)
    sources = discover_sources(args.sources)
    if not sources:
        sys.exit("No .typ sources found at repo root.")

    if args.watch and len(sources) > 1:
        sys.exit("--watch needs exactly one source (got "
                 f"{', '.join(p.stem for p in sources)}).")

    failed = []
    for src in sources:
        rc = compile_one(src, watch=args.watch)
        if rc != 0:
            failed.append(src.stem)

    if failed:
        print(f"\n[FAIL] {', '.join(failed)}")
        return 1
    print(f"\n[OK] Built {len(sources)} source(s) -> {BUILD}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
