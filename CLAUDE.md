# Thesis Writing Rules

## Language & Style

- **No "but" as a conjunction.** Use "however", "yet", "while", "although", or restructure the sentence. Exceptions: direct quotations from other systems, and "not only...but also" fixed pattern.
- **No colloquial expressions.** Avoid "apples-to-apples", "a lot", "pretty much", "kind of", "sort of", etc. Use formal alternatives ("directly comparable", "substantially", etc.).
- **No contractions.** Write "cannot" not "can't", "does not" not "doesn't", etc.
- **No informal "so" as a sentence connector.** Prefer "therefore", "thus", "consequently", or "accordingly" in formal argumentation. ", so" within a sentence is acceptable for causal clauses.
- **Avoid absolute claims about gaps in prior work.** Do not write "None offer X" or "No work has done X" — these are hard to prove and reviewers may challenge them. Instead, emphasize the importance of the capability: "Few resources offer X, which limits..." or "Methods for X remain underdeveloped." Exception: factual statements about the absence of a specific gold-standard dataset (e.g., "No existing dataset provides expert-annotated period-level mood trajectories") are acceptable when used to explain methodological constraints, not to claim novelty.

## Framing

- This is a **method paper**, not a dataset/resource paper. The primary contribution is the few-shot prompt-based LLM annotation method; the corpus is a product of applying the method.
- Use "we propose a method" / "our method" / "the proposed method", not "we present a resource" / "our dataset".
- When referring to the output corpus, use "our corpus" / "the corpus" / "the annotated dataset", not a system name like "MoodTrail-BD".

## Paper Structure

- **Every evaluation/validation in the Results section must be previewed in the Methods section.** If a subsection in Results reports an experiment (e.g., zero-shot baseline, cross-model probe), the Methods section must declare the intent and design of that experiment beforehand. The reader should never encounter a new experimental setup for the first time in Results. Exception: observational analyses of the main experiment's outputs (e.g., distribution of Uncertain labels) do not require a separate preview.

## References & Formatting

- Do not cite Japanese-language papers in international conference submissions.
- Appendix sections use A-Z numbering (A, B, C), not numeric (9.1, 9.2).
- Table headers that are too wide should use multi-row format.
- Twitter should be written as "Twitter (currently X)" on first mention, then "X" thereafter.
