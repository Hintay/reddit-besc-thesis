# Supervisor Comments — 20260527-JiefengLin-Thesis_MoodTrail-BD_TBD.pdf

- **Reviewer**: Shuntaro Yada (矢田 竣太郎)
- **Review Date**: 2026-05-27 (JST)
- **Total Annotations**: 26

---

## Page 1 — Title / Abstract / Affiliation

### #1 Highlight `[162, 460, 461, 479]`

- **Section**: Abstract
- **Paragraph**: 1

**Highlighted text:**
```
of state transitions that define BD clinically. We present a longitudinal
mood-state-labeled social media resource that provides annotations at two
granularities: per-post categorical mood state classification and 14-day
```

**Comment:**
> present a resource ではなく、 propose a few-shot prompt-based LLM method to analyse longitudinal bd mood trail の方向で。

- **Date**: 2026-05-26T23:51:12-07:00

### #2 Text (Reply to #1) `[162, 460, 461, 479]`

- **Section**: Abstract
- **Paragraph**: 1

**Comment:**
> BDのデータセットを作るのは大変なので、fine-tuningなしで実行できるfew-shot promptは応用範囲が広く、有用と考えられます。Introductionなどでそのように主張してみてください。

- **Date**: 2026-05-26T23:51:12-07:00

### #3 Highlight `[261, 574, 434, 586]`

- **Section**: Title block (affiliation)

**Highlighted text:**
```
1-1-1 Tennodai, Tsukuba, Ibaraki 305-8577,
.jiefeng.tkb_ge@u.tsukuba.ac.jp
```

**Comment:**
> 1-2, Kasuga, Tsukuba, Ibaraki 305-8550

- **Date**: 2026-05-26T23:32:46-07:00
- **Note**: 住所の修正指示。

### #4 Highlight `[160, 631, 470, 673]`

- **Section**: Title

**Highlighted text:**
```
MoodTrail-BD: A Longitudinal Mood-State-
Labeled Social Media Resource for Bipolar
Disorder
```

**Comment:**
> a longitudinal mood-state analysis
> bipolar disorder
> social media
> using large language model
> などのキーワードを含むようなタイトルにしましょう。システム名・データセット名みたいなもの（MoodTrail-BD）は今回は見送るのが良いと思います

- **Date**: 2026-05-26T23:40:41-07:00

---

## Page 2 — Introduction

### #5 Highlight `[135, 276, 491, 380]`

- **Section**: 1 Introduction
- **Location**: Contribution list (items 1–3)

**Highlighted text:**
```
1. A two-granularity annotation schema (per-post state + 14-day trend) with an
   LLM pipeline. Existing BD social media resources provide per-user or per-post
   labels; ours adds period-level mood trajectory annotations.
2. MoodTrail-BD comprises TBD self-identified BD users from BD-focused sub-
   reddits, TBD 14-day periods, TBD posts and comments spanning TBD, with
   mood and trend distributions consistent with clinical expectations.
3. External validation against the BD-Risk expert-labeled dataset on a held-out,
   author-disjoint, stratified evaluation subset, with macro F1 of 0.519 (87.9%
   depressive recall, 35.7% hypomanic recall, 6.7% manic recall) and six charac-
   terized failure modes.
```

**Comment:**
> 全体的に、BD-Riskを改変したデータで提案手法の性能を評価したことと、新規データセットでlongitudinal analysisをdemonstrationすることを区別しましょう。

- **Date**: 2026-05-27T00:01:59-07:00

### #6 Highlight `[133, 604, 151, 617]`

- **Section**: 1 Introduction
- **Location**: 末尾付近

**Highlighted text:**
```
but
```

**Comment:**
> 論文で but は避けましょう。

- **Date**: 2026-05-26T23:41:59-07:00

### #7 Highlight `[133, 581, 491, 602]`

- **Section**: 1 Introduction
- **Location**: "None offer post-level..." 付近

**Highlighted text:**
```
level risk scores. None offer post-level mood state labels tracked over time, which
limits computational research on mood trajectories.
Recent work has applied LLMs to mental health NLP tasks [8, 9], but whether
```

**Comment:**
> これはかなり強い主張で、証明するのが難しいです（全くないと言い切れない）。mood trajectoriesを計測できる手法が重要だ、という言い方にしましょう

- **Date**: 2026-05-26T23:43:29-07:00

### #8 Highlight `[350, 476, 456, 489]`

- **Section**: 1 Introduction
- **Location**: DSM-5 episode criteria 言及箇所

**Highlighted text:**
```
DSM-5 episode criteria
...We validate the pos
```

**Comment:**
> 「LLM (Generative AI)の性能向上により、人間向けに書かれたガイドラインだけでも一定の性能が見込めるはずなので、BDの一般的なガイドラインに即してpromptを設計すれば良いと考えた。」みたいなストーリーも検討してみてください。

- **Date**: 2026-05-26T23:53:09-07:00

---

## Page 3 — Related Work / Methods Overview

### #9 Highlight `[250, 555, 288, 566]`

- **Section**: 2 Related Work
- **Subsection**: 2.2 Social Media in Mental Health Detection
- **Paragraph**: 1

**Highlighted text:**
```
Twitter.
```

**Comment:**
> Twitter (currently called X)

- **Date**: 2026-05-26T23:49:10-07:00

### #10 Highlight `[153, 284, 235, 298]`

- **Section**: 3 Methodology（見出し自体）

**Highlighted text:**
```
Methodology
```

**Comment:**
> DSM-5をいかにpromptにしたか、few-shotをいかに選んだか、どうやって性能評価するか（BD-Riskをどのように利活用したか）を順番に説明しましょう

- **Date**: 2026-05-26T23:57:16-07:00

---

## Page 4 — Method

### #11 Highlight `[166, 463, 314, 474]`

- **Section**: 3 Methodology
- **Subsection**: 3.1 Resource Overview
- **Location**: Figure 1 キャプション付近

**Highlighted text:**
```
MoodTrail-BD construction pipeline.
used subreddits and filtered to those
```

**Comment:**
> llmへのpromptと、llmの出力を図にしてください

- **Date**: 2026-05-26T23:55:12-07:00

---

## Page 5 — Method (cont.)

### #12 Highlight `[248, 376, 430, 389]`

- **Section**: 3 Methodology
- **Subsection**: 3.2 Annotation Schema
- **Location**: 14-day period 設定の説明箇所

**Highlighted text:**
```
fixed-length period modelings (default: 14 days).
rst post (day 0) and advance in strict ha
```

**Comment:**
> これはDSMや医師の推奨で設定している、ということを記載してください

- **Date**: 2026-05-27T00:00:29-07:00

---

## Page 6 — Method (cont.)

### #13 Highlight `[134, 331, 487, 352]`

- **Section**: 3 Methodology
- **Subsection**: 3.3 External Validation Against BD-Risk
- **Paragraph**: 1

**Highlighted text:**
```
the clinically validated BD-Risk dataset introduced by Lee et al. [1] at NAACL
2024. Period-level trend analysis is not externally validated in this paper, as no
existing dataset provides expert-annotated mood trajectories at the period level.
```

**Comment:**
> 引用すれば十分なので、こういうことは普通書きません

- **Date**: 2026-05-26T23:59:21-07:00

---

## Page 7 — Method / Results

### #14 Highlight `[119, 417, 174, 427]`

- **Section**: 3 Methodology
- **Subsection**: 3.5 Evaluation（見出し自体）

**Highlighted text:**
```
Evaluation
```

**Comment:**
> なんか文字が左に飛び出していますね

- **Date**: 2026-05-27T00:02:28-07:00
- **Note**: レイアウト不具合。見出し "Evaluation" が左マージンからはみ出している。

---

## Page 8 — Results

### #15 Highlight `[133, 511, 487, 544]`

- **Section**: 3 Methodology
- **Subsection**: 3.4 LLM Configuration

**Highlighted text:**
```
Gemini 3.1 Pro is the primary annotator throughout this paper. A cross-model
probe with GPT-5.5 is reported in Section 4 to characterize schema portability and
the impact of provider-level content-policy differences on annotation feasibility.
```

**Comment:**
> わかりやすく、評価の内容として独立させてください。zero-shotとの比較も同様です。3.6節としましょう。

- **Date**: 2026-05-27T00:06:19-07:00

---

## Page 9 — Results (cont.)

### #16 Highlight `[136, 335, 196, 347]`

- **Section**: 4 Results
- **Subsection**: 4.1 Post-Level Validation Against BD-Risk
- **Location**: 混同行列の表ヘッダー

**Highlighted text:**
```
Gold \ Pred.
Depressive
```

**Comment:**
> こういう時は見出し行を2段にします。

- **Date**: 2026-05-27T00:03:00-07:00
- **Note**: 表のヘッダー行が長い場合は2行にする。

---

## Page 10 — Validation

### #17 Highlight `[133, 640, 472, 652]`

- **Section**: 4 Results
- **Subsection**: 4.3 Schema Contribution: Comparison with a Zero-Shot Baseline（見出し自体）

**Highlighted text:**
```
4.3 Schema Contribution: Comparison with a Zero-Shot Baseline
```

**Comment:**
> このvalidationをする、ということも、methodsセクションに簡単に書いて、予告しておくように。

- **Date**: 2026-05-27T00:04:36-07:00

---

## Page 11 — Validation (cont.)

### #18 Highlight `[133, 640, 343, 652]`

- **Section**: 4 Results
- **Subsection**: 4.4 Cross-Model Annotation Feasibility（見出し自体）

**Highlighted text:**
```
4.4 Cross-Model Annotation Feasibility
```

**Comment:**
> 4.3と同じく、evaluationの項目として先に予告しておいてください

- **Date**: 2026-05-27T00:05:09-07:00

---

## Page 12 — Cross-version / Demonstration

### #19 Highlight `[133, 550, 416, 562]`

- **Section**: 4 Results
- **Subsection**: 4.5 Author-Level Aggregation of Per-Post Predictions（見出し自体）

**Highlighted text:**
```
4.5 Author-Level Aggregation of Per-Post Predictions
```

**Comment:**
> この検証は省略してもいいかもしれません。含めるなら、methodsセクションにも、実施する意図を宣言しておいてください。

- **Date**: 2026-05-27T00:09:44-07:00

### #20 Highlight `[133, 181, 412, 191]`

- **Section**: 4 Results
- **Subsection**: 4.6 Resource Annotation: Period-Level Mood Trends（見出し自体）

**Highlighted text:**
```
4.6 Resource Annotation: Period-Level Mood Trends
```

**Comment:**
> これを5節として独立させてください。Userももっと増やせると良いですね。

- **Date**: 2026-05-27T00:10:21-07:00

---

## Page 14 — Discussion / Additional Validation

### #21 Highlight `[134, 375, 244, 389]`

- **Section**: 5 Error Analysis（見出し自体）

**Highlighted text:**
```
5 Error Analysis
```

**Comment:**
> 提案手法の検証ということで、4節の中に含めましょう。あるいは、結果と検証を2つのセクションに分けても良いです。

- **Date**: 2026-05-27T00:11:12-07:00

---

## Page 21 — Appendix

### #22 Highlight `[134, 631, 348, 644]`

- **Section**: 9 Appendix: Annotation Prompts（見出し自体）

**Highlighted text:**
```
9 Appendix: Annotation Prompts
```

**Comment:**
> Appendixには1-9の番号をつけません。

- **Date**: 2026-05-27T00:12:18-07:00

### #23 Highlight `[134, 569, 392, 582]`

- **Section**: 9 Appendix: Annotation Prompts
- **Subsection**: 9.1 Post-Level Annotation Prompt (Full Schema)（見出し自体）

**Highlighted text:**
```
9.1 Post-Level Annotation Prompt (Full Schema)
```

**Comment:**
> A. Post-level ... など、Appendixの節はA-Zで付番されます。

- **Date**: 2026-05-27T00:12:50-07:00

### #24 Highlight `[133, 484, 470, 515]`

- **Section**: 9 Appendix: Annotation Prompts
- **Subsection**: 9.1 Post-Level Annotation Prompt (Full Schema)
- **Paragraph**: 1（prompt 本文冒頭）

**Highlighted text:**
```
For each post, you must determine:
1. **state**: The primary categorical mood state (MANIC, HYPOMANIC, DEPRESSIVE,
   STABLE, or UNCERTAIN)
2. **opposite_pole_symptoms**: Explicit list of clear opposite-pole symptoms extracted
   from the post before deciding mixed features
3. **specifiers**: DSM-5 modifiers (currently: "with_mixed_features"). Return empty
   array [] if none apply.
4. **confidence**: Your confidence level (High, Medium, Low)
```

**Comment:**
> プロンプト全文は収まらないので、匿名のサイトでデータとして公開することにしてください。方法は任せますが、double blind peer reviewなので、我々であることがわからないような方法でお願いします（GitHubはNG）。

- **Date**: 2026-05-27T00:13:41-07:00

---

## Page 32 — References

### #25 Highlight `[146, 354, 212, 365]`

- **Section**: References（見出し自体）

**Highlighted text:**
```
References
```

**Comment:**
> Referenceを含めて20ページ以内ということなので、最後に本文のボリュームは調整しましょう

- **Date**: 2026-05-27T00:14:16-07:00

---

## Page 33 — References (cont.)

### #26 Highlight `[151, 268, 487, 288]`

- **Section**: References

**Highlighted text:**
```
矢田竣太郎, 小林和馬, 伊藤沙紀子, 小田悠介, 相澤彰子: 大規模言語モデルによる臨
床テキストの非識別化. In: 言語処理学会 第32回年次大会 発表論文集. pp. 3993–
3998 (2026).
```

**Comment:**
> 国際学会では日本語の論文は引用できません。

- **Date**: 2026-05-27T00:14:29-07:00

---

## Paper Structure (as submitted)

| Section | Subsections | Pages |
|---|---|---|
| Title / Abstract | — | 1 |
| 1 Introduction | — | 1–2 |
| 2 Related Work | 2.1, 2.2, 2.3 | 2–3 |
| 3 Methodology | 3.1 Resource Overview, 3.2 Annotation Schema, 3.3 External Validation Against BD-Risk, 3.4 LLM Configuration, 3.5 Evaluation | 3–8 |
| 4 Results | 4.1 Post-Level Validation, 4.2 Uncertain Label as QC, 4.3 Zero-Shot Baseline, 4.4 Cross-Model Feasibility, 4.5 Author-Level Aggregation, 4.6 Period-Level Mood Trends | 8–14 |
| 5 Error Analysis | — | 14–? |
| 6 Discussion | 6.1, 6.2 | ?–? |
| 7 Limitations | — | ? |
| 8 Ethical Considerations | — | 20 |
| 9 Appendix | 9.1 Post-Level Prompt, 9.2 ?, 9.3 Period-Level Prompt | 21–31 |
| References | — | 32–33 |

---

## Summary of Key Action Items

| Category | Action Items | Related Section | Comments |
|---|---|---|---|
| **タイトル** | キーワード駆動のタイトルに変更、MoodTrail-BD を外す | Title | #4 |
| **定位 (Framing)** | "present a resource" → "propose a few-shot prompt-based LLM method"；few-shot の汎用性・有用性を Introduction で主張 | Abstract, §1 | #1, #2 |
| **Contribution list** | 性能評価 vs longitudinal demonstration を区別して記述 | §1 Introduction | #5 |
| **Methodology 構成** | DSM-5→prompt、few-shot選定、BD-Risk利活用の順に説明；evaluation 項目を Methods で予告 | §3 Methodology | #10, #17, #18 |
| **評価の独立節化** | cross-model probe / zero-shot 比較を 3.6節として独立 | §3.4 → 新§3.6 | #15 |
| **新セクション** | §4.6 Period-Level Mood Trends を §5 として独立；User数を増やす | §4.6 → 新§5 | #20 |
| **Error Analysis** | §5 を §4 に統合、あるいは結果と検証の2セクション構成 | §5 → §4 内 | #21 |
| **表現・文体** | "but" を避ける；"None offer..." の強い主張を弱める；引用で済む説明は削除 | §1, §3.3 | #6, #7, #13 |
| **ストーリー** | LLM性能向上 → ガイドラインだけで prompt 設計可能、という論理を検討 | §1 Introduction | #8 |
| **記述追加** | 14-day period が DSM/医師推奨に基づく設定であることを明記 | §3.2 Annotation Schema | #12 |
| **表記** | Twitter → Twitter (currently called X) | §2.2 | #9 |
| **住所** | 1-1-1 Tennodai → 1-2, Kasuga, 305-8577 → 305-8550 | Affiliation | #3 |
| **図表** | LLM の prompt と output を図にする | §3.1 Resource Overview | #11 |
| **表書式** | 混同行列の見出し行を2段にする | §4.1 Table | #16 |
| **レイアウト** | "Evaluation" 見出しが左に飛び出し → 修正 | §3.5 | #14 |
| **省略検討** | §4.5 Author-Level Aggregation は省略可能（含めるなら Methods に宣言） | §4.5 | #19 |
| **Appendix** | 番号を 9→削除、小節を A-Z 付番に変更 | §9 Appendix | #22, #23 |
| **Prompt 公開** | 全文は匿名サイトで公開（double-blind、GitHub NG） | §9.1 | #24 |
| **ページ制限** | Reference 含め 20 ページ以内に調整 | 全体 | #25 |
| **References** | 日本語論文（矢田ら 2026）は引用不可、英語文献に差し替え | References | #26 |
