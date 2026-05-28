"""Extract PDF annotations (supervisor comments) into a Markdown digest.

Built for the workflow where Yada-sensei returns an annotated PDF and
we mine it for revision notes. PyMuPDF (`fitz`) is the right tool here
because annotations are stored as separate PDF objects, not in the
text stream — `pdfplumber` / `pdftotext` cannot see them.

Handles three common forms:
  - Highlight (rectangular yellow swipe + optional pop-up comment)
  - Text     (yellow "sticky-note" callout with a comment)
  - Underline / StrikeOut (treated the same as Highlight)

The script is forgiving about quad layout: a highlight that spans
multiple lines is decoded one quad at a time so the extracted text
matches what the eye sees, not the bounding rectangle.

Usage:
    python scripts/extract_pdf_comments.py PDF [--output OUT.md] [--author NAME]

Examples:
    # default: write feedback/<pdf-basename>.comments.md
    python scripts/extract_pdf_comments.py archive/20260527-...TBD.pdf

    # stdout
    python scripts/extract_pdf_comments.py archive/X.pdf --output -

    # only one author (case-insensitive substring match on annot.title)
    python scripts/extract_pdf_comments.py archive/X.pdf --author yada
"""
from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime

import fitz  # PyMuPDF


# Annotation type names PyMuPDF returns that carry a textual highlight
# we want to quote alongside the comment.
HIGHLIGHT_TYPES = {"Highlight", "Underline", "StrikeOut", "Squiggly"}


def parse_pdf_date(s: str) -> str:
    """Convert a PDF-style date (e.g. ``D:20260526235112-07'00'``) to ISO."""
    if not s:
        return ""
    raw = s.replace("D:", "").split("-")[0].split("+")[0]
    try:
        dt = datetime.strptime(raw[:14], "%Y%m%d%H%M%S")
        return dt.isoformat(sep=" ", timespec="minutes")
    except Exception:
        return s


def extract_quad_text(page: fitz.Page, vertices) -> str:
    """Concatenate the text covered by each 4-point quad in a highlight.

    `vertices` is a flat list of (x, y) tuples, four per quad. Falls
    back to the annotation bounding rect if vertices are missing or
    malformed (which happens with some non-Adobe annotators).
    """
    if not vertices or len(vertices) % 4 != 0:
        return ""
    lines = []
    for i in range(0, len(vertices), 4):
        quad = fitz.Quad(vertices[i:i + 4])
        text = page.get_textbox(quad.rect).strip()
        if text:
            lines.append(text)
    # De-duplicate consecutive lines (rare but happens with overlapping quads)
    deduped = []
    for ln in lines:
        if not deduped or deduped[-1] != ln:
            deduped.append(ln)
    return " ".join(deduped)


def collect_annotations(pdf_path: str, author_filter: str | None = None):
    pdf = fitz.open(pdf_path)
    records = []
    for page_idx, page in enumerate(pdf):
        for ann in (page.annots() or []):
            info = ann.info
            author = info.get("title", "") or ""
            if author_filter and author_filter.lower() not in author.lower():
                continue
            type_name = ann.type[1]
            highlighted = ""
            if type_name in HIGHLIGHT_TYPES:
                highlighted = extract_quad_text(page, ann.vertices)
                if not highlighted:
                    highlighted = page.get_textbox(ann.rect).strip()
            records.append({
                "page": page_idx + 1,
                "type": type_name,
                "author": author,
                "modified": parse_pdf_date(info.get("modDate", "")),
                "highlighted": highlighted,
                "comment": (info.get("content") or "").strip(),
            })
    pdf.close()
    return records


def render_markdown(records, pdf_path: str) -> str:
    out = []
    base = os.path.basename(pdf_path)
    out.append(f"# Comments from `{base}`\n")
    out.append(f"Source: `{pdf_path}`\n")
    out.append(f"Total annotations: **{len(records)}**\n")
    if not records:
        out.append("\n_(no annotations found)_\n")
        return "\n".join(out)

    # Group by page for easy navigation; within a page keep PDF order.
    current_page = None
    for r in records:
        if r["page"] != current_page:
            current_page = r["page"]
            out.append(f"\n---\n\n## Page {current_page}\n")
        header_bits = [f"**[{r['type']}]**"]
        if r["author"]:
            header_bits.append(f"by {r['author']}")
        if r["modified"]:
            header_bits.append(f"— {r['modified']}")
        out.append("### " + " ".join(header_bits))
        if r["highlighted"]:
            quoted = "\n".join("> " + line for line in r["highlighted"].splitlines())
            out.append(f"\n**Highlighted text:**\n{quoted}\n")
        if r["comment"]:
            quoted = "\n".join("> " + line for line in r["comment"].splitlines())
            out.append(f"**Comment:**\n{quoted}\n")
        if not r["highlighted"] and not r["comment"]:
            out.append("_(empty annotation)_\n")
    return "\n".join(out)


def default_output_path(pdf_path: str) -> str:
    """Default sink: <repo>/feedback/<basename>.comments.md.

    Falls back to a sibling file next to the PDF if the feedback/
    directory doesn't exist (e.g. running this script outside the
    thesis repo layout).
    """
    base = os.path.basename(pdf_path)
    stem, _ = os.path.splitext(base)
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    feedback_dir = os.path.join(repo_root, "feedback")
    if os.path.isdir(feedback_dir):
        return os.path.join(feedback_dir, f"{stem}.comments.md")
    return os.path.join(os.path.dirname(os.path.abspath(pdf_path)), f"{stem}.comments.md")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("pdf", help="Path to the annotated PDF.")
    parser.add_argument("--output", "-o", default=None,
                        help="Output Markdown path. Use '-' for stdout. "
                             "Defaults to feedback/<basename>.comments.md.")
    parser.add_argument("--author", default=None,
                        help="Case-insensitive substring filter on annotation author.")
    args = parser.parse_args()

    if not os.path.isfile(args.pdf):
        sys.exit(f"PDF not found: {args.pdf}")

    records = collect_annotations(args.pdf, author_filter=args.author)
    md = render_markdown(records, args.pdf)

    if args.output == "-":
        sys.stdout.write(md)
        return

    out_path = args.output or default_output_path(args.pdf)
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(md)
    print(f"Extracted {len(records)} annotations → {out_path}")


if __name__ == "__main__":
    main()
