import unittest

import fitz

from scripts import extract_pdf_comments


class FakePage:
    def get_text(self, mode):
        if mode == "dict":
            return {
                "blocks": [
                    {
                        "type": 0,
                        "lines": [
                            {
                                "bbox": (10, 10, 200, 20),
                                "spans": [{"text": "Previous sentence explains the setup."}],
                            },
                            {
                                "bbox": (10, 30, 200, 40),
                                "spans": [{"text": "Highlighted sentence carries the comment."}],
                            },
                            {
                                "bbox": (10, 50, 200, 60),
                                "spans": [{"text": "Following sentence gives more context."}],
                            },
                        ],
                    }
                ]
            }
        if mode == "words":
            return [
                (10, 10, 55, 20, "Previous", 0, 0, 0),
                (60, 10, 105, 20, "sentence", 0, 0, 1),
                (110, 10, 150, 20, "explains", 0, 0, 2),
                (155, 10, 175, 20, "the", 0, 0, 3),
                (180, 10, 200, 20, "setup.", 0, 0, 4),
                (10, 30, 55, 40, "Highlighted", 0, 1, 0),
                (60, 30, 100, 40, "sentence", 0, 1, 1),
                (105, 30, 140, 40, "carries", 0, 1, 2),
                (145, 30, 160, 40, "the", 0, 1, 3),
                (165, 30, 200, 40, "comment.", 0, 1, 4),
                (10, 50, 55, 60, "Following", 0, 2, 0),
                (60, 50, 105, 60, "sentence", 0, 2, 1),
                (110, 50, 130, 60, "gives", 0, 2, 2),
                (135, 50, 160, 60, "more", 0, 2, 3),
                (165, 50, 200, 60, "context.", 0, 2, 4),
            ]
        raise ValueError(f"unexpected mode: {mode}")


class AnnotationContextTests(unittest.TestCase):
    def test_extract_annotation_context_reports_line_numbers_and_neighbors(self):
        context = extract_pdf_comments.extract_annotation_context(
            FakePage(),
            [fitz.Rect(60, 30, 160, 40), fitz.Rect(165, 30, 200, 40)],
            context_lines=1,
        )

        self.assertEqual(context["line_range"], "2")
        self.assertEqual(
            context["lines"],
            [
                {
                    "number": 1,
                    "text": "Previous sentence explains the setup.",
                    "rendered_text": "Previous sentence explains the setup.",
                    "highlighted": False,
                },
                {
                    "number": 2,
                    "text": "Highlighted sentence carries the comment.",
                    "rendered_text": "Highlighted **sentence carries the comment.**",
                    "highlighted": True,
                },
                {
                    "number": 3,
                    "text": "Following sentence gives more context.",
                    "rendered_text": "Following sentence gives more context.",
                    "highlighted": False,
                },
            ],
        )

    def test_render_markdown_hides_line_numbers_by_default(self):
        markdown = extract_pdf_comments.render_markdown(
            [
                {
                    "page": 2,
                    "type": "Highlight",
                    "author": "Koichiro Watanabe",
                    "modified": "2026-06-01 01:42",
                    "line_range": "10-11",
                    "highlighted": "Highlighted sentence carries the comment.",
                    "context": [
                        {
                            "number": 9,
                            "text": "Previous sentence explains the setup.",
                            "rendered_text": "Previous sentence explains the setup.",
                            "highlighted": False,
                        },
                        {
                            "number": 10,
                            "text": "Highlighted sentence carries the comment.",
                            "rendered_text": "Highlighted **sentence carries the comment.**",
                            "highlighted": True,
                        },
                        {
                            "number": 11,
                            "text": "Following sentence gives more context.",
                            "rendered_text": "Following sentence gives more context.",
                            "highlighted": False,
                        },
                    ],
                    "comment": "Please make the relation explicit.",
                }
            ],
            "archive/example.pdf",
        )

        self.assertIn("**Context:**", markdown)
        self.assertIn("> Previous sentence explains the setup.", markdown)
        self.assertIn("> Highlighted **sentence carries the comment.**", markdown)
        self.assertIn("> Following sentence gives more context.", markdown)
        self.assertNotIn("**Location:**", markdown)
        self.assertNotIn("> L9:", markdown)

    def test_render_markdown_can_include_line_numbers(self):
        markdown = extract_pdf_comments.render_markdown(
            [
                {
                    "page": 2,
                    "type": "Highlight",
                    "author": "Koichiro Watanabe",
                    "modified": "2026-06-01 01:42",
                    "line_range": "10-11",
                    "highlighted": "Highlighted sentence carries the comment.",
                    "context": [
                        {
                            "number": 9,
                            "text": "Previous sentence explains the setup.",
                            "rendered_text": "Previous sentence explains the setup.",
                            "highlighted": False,
                        },
                        {
                            "number": 10,
                            "text": "Highlighted sentence carries the comment.",
                            "rendered_text": "Highlighted **sentence carries the comment.**",
                            "highlighted": True,
                        },
                    ],
                    "comment": "Please make the relation explicit.",
                }
            ],
            "archive/example.pdf",
            show_line_numbers=True,
        )

        self.assertIn("**Location:**\n> Page 2, approx. lines 10-11", markdown)
        self.assertIn("> L9: Previous sentence explains the setup.", markdown)
        self.assertIn("> L10: Highlighted **sentence carries the comment.**", markdown)


if __name__ == "__main__":
    unittest.main()
