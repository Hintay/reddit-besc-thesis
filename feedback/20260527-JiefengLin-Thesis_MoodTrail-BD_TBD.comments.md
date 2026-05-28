# Comments from `20260527-JiefengLin-Thesis_MoodTrail-BD_TBD.pdf`

Source: `D:/Work/Tsukuba/research/reddit/thesis/archive/20260527-JiefengLin-Thesis_MoodTrail-BD_TBD.pdf`

Total annotations: **26**


---

## Page 1

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:51

**Highlighted text:**
> We present a longitudinal mood-state-labeled social media resource

**Comment:**
> present a resource ではなく、 propose a few-shot prompt-based LLM method to analyse longitudinal bd mood trail の方向で。

### **[Text]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:51
**Comment:**
> BDのデータセットを作るのは大変なので、fine-tuningなしで実行できるfew-shot promptは応用範囲が広く、有用と考えられます。Introductionなどでそのように主張してみてください。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:32

**Highlighted text:**
> 1-1-1 Tennodai, Tsukuba, Ibaraki 305-8577, 
> jiefeng.tkb_ge@u.tsukuba.ac.jp

**Comment:**
> 1-2, Kasuga, Tsukuba, Ibaraki 305-8550

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:40

**Highlighted text:**
> A Longitudinal Mood-State- Labeled Social Media Resource for Bipolar Disorder

**Comment:**
> a longitudinal mood-state analysis
> bipolar disorder
> social media
> using large language model
> などのキーワードを含むようなタイトルにしましょう。システム名・データセット名みたいなもの（MoodTrail-BD）は今回は見送るのが良いと思います


---

## Page 2

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:01

**Highlighted text:**
> A two-granularity annotation schema (per-post state + 14-day trend) with an LLM pipeline. Existing BD social media resources provide per-user or per-post labels; ours adds period-level mood trajectory annotations. 2. MoodTrail-BD comprises TBD self-identified BD users from BD-focused sub­ reddits, TBD 14-day periods, TBD posts and comments spanning TBD, with mood and trend distributions consistent with clinical expectations. 3. External validation against the BD-Risk expert-labeled dataset on a held-out, author-disjoint, stratified evaluation subset, with macro F1 of 0.519 (87.9% depressive recall, 35.7%

**Comment:**
> 全体的に、BD-Riskを改変したデータで提案手法の性能を評価したことと、新規データセットでlongitudinal analysisをdemonstrationすることを区別しましょう。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:41

**Highlighted text:**
> but 
> leve

**Comment:**
> 論文で but は避けましょう。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:43

**Highlighted text:**
> None offer post-level mood state labels tracked over time, which limits computational research on mood trajectories.
> Recent work has applied LLMs to mental health N

**Comment:**
> これはかなり強い主張で、証明するのが難しいです（全くないと言い切れない）。mood trajectoriesを計測できる手法が重要だ、という言い方にしましょう

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:53

**Highlighted text:**
> DSM-5 episode criteria 
> Pro). We validate the po

**Comment:**
> 「LLM (Generative AI)の性能向上により、人間向けに書かれたガイドラインだけでも一定の性能が見込めるはずなので、BDの一般的なガイドラインに即してpromptを設計すれば良いと考えた。」みたいなストーリーも検討してみてください。


---

## Page 3

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:49

**Highlighted text:**
> Twitter.

**Comment:**
> Twitter (currently called X)

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:57

**Highlighted text:**
> Methodology

**Comment:**
> DSM-5をいかにpromptにしたか、few-shotをいかに選んだか、どうやって性能評価するか（BD-Riskをどのように利活用したか）を順番に説明しましょう


---

## Page 4

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:55

**Highlighted text:**
> MoodTrail-BD construction pipeline.

**Comment:**
> llmへのpromptと、llmの出力を図にしてください


---

## Page 5

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:00

**Highlighted text:**
> fixed-length periods (default: 14 days). 
> rst post (day 0) and advance in strict ha

**Comment:**
> これはDSMや医師の推奨で設定している、ということを記載してください


---

## Page 6

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-26 23:59

**Highlighted text:**
> at NAACL 2024.

**Comment:**
> 引用すれば十分なので、こういうことは普通書きません


---

## Page 7

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:02

**Highlighted text:**
> Evaluation

**Comment:**
> なんか文字が左に飛び出していますね


---

## Page 8

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:06

**Highlighted text:**
> Gemini 3.1 Pro is the primary annotator throughout this paper. A cross-model probe with GPT-5.5 is reported in Section 4 to characterize schema portability and the impact of provider-level content-policy differences on annotation feasibility.

**Comment:**
> わかりやすく、評価の内容として独立させてください。zero-shotとの比較も同様です。3.6節としましょう。


---

## Page 9

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:03

**Highlighted text:**
> Gold \ Pred. 
> Depressive

**Comment:**
> こういう時は見出し行を2段にします。


---

## Page 10

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:04

**Highlighted text:**
> 4.3
> Schema Contribution: Comparison with a Zero-Shot Baseline

**Comment:**
> このvalidationをする、ということも、methodsセクションに簡単に書いて、予告しておくように。


---

## Page 11

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:05

**Highlighted text:**
> 4.4
> Cross-Model Annotation Feasibility

**Comment:**
> 4.3と同じく、evaluationの項目として先に予告しておいてください


---

## Page 12

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:09

**Highlighted text:**
> 4.5
> Author-Level Aggregation of Per-Post Predictions

**Comment:**
> この検証は省略してもいいかもしれません。含めるなら、methodsセクションにも、実施する意図を宣言しておいてください。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:10

**Highlighted text:**
> 4.6
> Resource Annotation: Period-Level Mood Trends

**Comment:**
> これを5節として独立させてください。Userももっと増やせると良いですね。


---

## Page 14

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:11

**Highlighted text:**
> 5
> Error Analysis

**Comment:**
> 提案手法の検証ということで、4節の中に含めましょう。あるいは、結果と検証を2つのセクションに分けても良いです。


---

## Page 21

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:12

**Highlighted text:**
> 9
> Appendix: Annotation Prompts

**Comment:**
> Appendixには1-9の番号をつけません。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:12

**Highlighted text:**
> 9.1
> Post-Level Annotation Prompt (Full Schema)

**Comment:**
> A. Post-level ... など、Appendixの節はA-Zで付番されます。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:13

**Highlighted text:**
> For each post, you must determine: 1. **state**: The primary categorical mood state (MANIC, HYPOMANIC, DEPRESSIVE, STABLE, or UNCERTAIN) 2. **opposite_pole_symptoms**: Explicit list of clear opposite-pole symptoms extracted from the post before deciding mixed features deciding mixed features
> 3. **specifiers**: DSM-5 modifiers (currently: "with_mixed_features"). 
> 4. **confidence**: Your confidence level (High, Medium, Low)

**Comment:**
> プロンプト全文は収まらないので、匿名のサイトでデータとして公開することにしてください。方法は任せますが、double blind peer reviewなので、我々であることがわからないような方法でお願いします（GitHubはNG）。


---

## Page 32

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:14

**Highlighted text:**
> References

**Comment:**
> Referenceを含めて20ページ以内ということなので、最後に本文のボリュームは調整しましょう


---

## Page 33

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-27 00:14

**Highlighted text:**
> 矢田竣太郎, 小林和馬, 伊藤沙紀子, 小田悠介, 相澤彰子: 大規模言語モデルによる臨 矢田竣太郎, 小林和馬, 伊
> 床テキストの非識別化. 
> 3998 (2026).

**Comment:**
> 国際学会では日本語の論文は引用できません。
