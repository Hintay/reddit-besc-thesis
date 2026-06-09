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
                                           [--context-lines N] [--line-numbers]

Examples:
    # default: write feedback/<pdf-basename>.comments.md
    python scripts/extract_pdf_comments.py archive/20260527-...TBD.pdf

    # stdout
    python scripts/extract_pdf_comments.py archive/X.pdf --output -

    # only one author (case-insensitive substring match on annot.title)
    python scripts/extract_pdf_comments.py archive/X.pdf --author yada

    # include two PDF text lines before and after each highlight
    python scripts/extract_pdf_comments.py archive/X.pdf --context-lines 2

    # also include approximate PDF visual line numbers
    python scripts/extract_pdf_comments.py archive/X.pdf --line-numbers
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


def extract_quad_rects(vertices) -> list[fitz.Rect]:
    """Return one rectangle per highlight quad."""
    if not vertices or len(vertices) % 4 != 0:
        return []
    return [fitz.Quad(vertices[i:i + 4]).rect for i in range(0, len(vertices), 4)]


def extract_page_lines(page: fitz.Page) -> list[dict]:
    """Extract approximate visual text lines from a PDF page."""
    lines = []
    for block in page.get_text("dict").get("blocks", []):
        if block.get("type") != 0:
            continue
        for line in block.get("lines", []):
            text = "".join(span.get("text", "") for span in line.get("spans", [])).strip()
            if not text:
                continue
            lines.append({"bbox": fitz.Rect(line["bbox"]), "text": text})
    lines.sort(key=lambda item: (round(item["bbox"].y0, 1), item["bbox"].x0))
    for idx, line in enumerate(lines, start=1):
        line["number"] = idx
    return lines


def extract_page_words(page: fitz.Page) -> list[dict]:
    """Extract page words with bounding boxes for word-level highlight marks."""
    words = []
    for item in page.get_text("words"):
        if len(item) < 5:
            continue
        x0, y0, x1, y1, text = item[:5]
        if not text:
            continue
        words.append({"bbox": fitz.Rect(x0, y0, x1, y1), "text": text})
    words.sort(key=lambda item: (round(item["bbox"].y0, 1), item["bbox"].x0))
    return words


def rects_overlap(a: fitz.Rect, b: fitz.Rect) -> bool:
    """Return whether two rectangles overlap enough to treat them as the same text line."""
    return not (a.x1 < b.x0 or b.x1 < a.x0 or a.y1 < b.y0 or b.y1 < a.y0)


def render_line_with_word_highlights(line: dict, words: list[dict], rects: list[fitz.Rect]) -> str:
    """Return a line with contiguous highlighted word runs wrapped in Markdown bold."""
    line_words = [word for word in words if rects_overlap(word["bbox"], line["bbox"])]
    if not line_words:
        return line["text"]

    tokens = []
    in_highlight = False
    for word in line_words:
        text = word["text"]
        is_highlighted = any(rects_overlap(rect, word["bbox"]) for rect in rects)
        if is_highlighted and not in_highlight:
            tokens.append("**" + text)
            in_highlight = True
        elif not is_highlighted and in_highlight:
            tokens[-1] = tokens[-1] + "**"
            tokens.append(text)
            in_highlight = False
        else:
            tokens.append(text)
    if in_highlight:
        tokens[-1] = tokens[-1] + "**"
    return " ".join(tokens)


def format_line_range(numbers: list[int]) -> str:
    """Format one or more line numbers as compact ranges."""
    if not numbers:
        return ""
    ranges = []
    start = prev = numbers[0]
    for number in numbers[1:]:
        if number == prev + 1:
            prev = number
            continue
        ranges.append(str(start) if start == prev else f"{start}-{prev}")
        start = prev = number
    ranges.append(str(start) if start == prev else f"{start}-{prev}")
    return ", ".join(ranges)


def extract_annotation_context(page: fitz.Page, rects, context_lines: int = 2) -> dict:
    """Find approximate page lines touched by an annotation and include neighbors."""
    page_lines = extract_page_lines(page)
    page_words = extract_page_words(page)
    highlight_numbers = [
        line["number"]
        for line in page_lines
        if any(rects_overlap(rect, line["bbox"]) for rect in rects)
    ]
    if not highlight_numbers:
        return {"line_range": "", "lines": []}

    context_start = max(1, min(highlight_numbers) - context_lines)
    context_end = max(highlight_numbers) + context_lines
    highlighted = set(highlight_numbers)
    context = [
        {
            "number": line["number"],
            "text": line["text"],
            "rendered_text": render_line_with_word_highlights(line, page_words, rects),
            "highlighted": line["number"] in highlighted,
        }
        for line in page_lines
        if context_start <= line["number"] <= context_end
    ]
    return {"line_range": format_line_range(highlight_numbers), "lines": context}


def collect_annotations(pdf_path: str, author_filter: str | None = None, context_lines: int = 0):
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
            context = {"line_range": "", "lines": []}
            if type_name in HIGHLIGHT_TYPES:
                rects = extract_quad_rects(ann.vertices)
                highlighted = extract_quad_text(page, ann.vertices)
                if not highlighted:
                    highlighted = page.get_textbox(ann.rect).strip()
                    rects = [ann.rect]
                if context_lines >= 0 and rects:
                    context = extract_annotation_context(page, rects, context_lines=context_lines)
            records.append({
                "page": page_idx + 1,
                "type": type_name,
                "author": author,
                "modified": parse_pdf_date(info.get("modDate", "")),
                "line_range": context["line_range"],
                "highlighted": highlighted,
                "context": context["lines"],
                "comment": (info.get("content") or "").strip(),
            })
    pdf.close()
    return records


def render_markdown(records, pdf_path: str, show_line_numbers: bool = False) -> str:
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
        if show_line_numbers and r.get("line_range"):
            out.append(f"\n**Location:**\n> Page {r['page']}, approx. lines {r['line_range']}\n")
        if r["highlighted"]:
            quoted = "\n".join("> " + line for line in r["highlighted"].splitlines())
            out.append(f"\n**Highlighted text:**\n{quoted}\n")
        if r.get("context"):
            context_lines = []
            for line in r["context"]:
                text = line.get("rendered_text", line["text"])
                if show_line_numbers:
                    context_lines.append(f"> L{line['number']}: {text}")
                else:
                    context_lines.append(f"> {text}")
            out.append("**Context:**\n" + "\n".join(context_lines) + "\n")
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
    parser.add_argument("--context-lines", type=int, default=1,
                        help="PDF text lines to include before and after each highlighted line. "
                             "Use 0 to show only highlighted lines in context.")
    parser.add_argument("--line-numbers", action="store_true",
                        help="Show approximate PDF visual line numbers in the Markdown output.")
    args = parser.parse_args()

    if not os.path.isfile(args.pdf):
        sys.exit(f"PDF not found: {args.pdf}")

    records = collect_annotations(
        args.pdf,
        author_filter=args.author,
        context_lines=max(0, args.context_lines),
    )
    md = render_markdown(records, args.pdf, show_line_numbers=args.line_numbers)

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
