# Comments from `20260611-JiefengLin-Thesis_Draft.pdf`

Source: `archive\20260611-JiefengLin-Thesis_Draft.pdf`

Total annotations: **2**


---

## Page 4

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-06-13 00:48

**Highlighted text:**
> Posting to a mental-health-related subreddit is a necessary yet insufficient signal of a BD diagnosis: many such posts come from clinicians, family members, or general community participants. To screen the candidate pool, we apply an LLM three-tier classifier (Gemini 3.1 Pro, separate prompt) that scans each author’s full posting history and returns v verified (explicit first-person diagnostic statements, e.g., “I was diagnosed with bipolar II in 2019”, or specific treatment/ hospitalization narratives), p probable (consistent self-identification through symp­ toms, medication, or community-membership tone without an explicit diagnosis statement), or unverified (no diagnostic signal). Only the verified and probable tiers are admitted to the annotation cohort; this matches the inclusion model used in prior BD social-media datasets [7, 14] with stricter per-user evidence gating than a one-post membership rule.

**Context:**
> annotation schema.
> **Posting to a mental-health-related subreddit is a necessary yet insufficient**
> **signal of a BD diagnosis: many such posts come from clinicians, family members,**
> **or general community participants. To screen the candidate pool, we apply an**
> **LLM three-tier classifier (Gemini 3.1 Pro, separate prompt) that scans each**
> **author’s full posting history and returns (explicit first-person diagnostic verified**
> **statements, e.g., “I was diagnosed with bipolar II in 2019”, or specific treatment/**
> **hospitalization narratives), (consistent self-identification through symp­ probable**
> **toms, medication, or community-membership tone without an explicit diagnosis**
> **statement), or (no diagnostic signal). Only the and unverified verified probable**
> **tiers are admitted to the annotation cohort; this matches the inclusion model used**
> **in prior BD social-media datasets [7, 14] with stricter per-user evidence gating**
> **than a one-post membership rule.**

**Comment:**
> これは最後のデモ実験におけるデータ収集の話ではないかと思いますので、Section 5に移す方が良いです。

### **[Text]** by Shuntaro Yada (矢田 竣太郎) — 2026-06-13 00:48
**Comment:**
> BD-Riskでも同じ処理をしているのか、読者が混乱します。また、Methodologyのセクションにこの説明があると、このverificationが提案手法にとって必須の前処理であるようにも読まれてしまいます。
