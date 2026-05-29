# Comments from `20260529-JiefengLin-Thesis_Draft.pdf`

Source: `archive/20260529-JiefengLin-Thesis_Draft.pdf`

Total annotations: **10**


---

## Page 1

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:37

**Highlighted text:**
> Using Gemini 3.1 Pro, we apply the method to 105 self- identified BD users on BD-focused subreddits (1,794 14-day periods, 15,423 posts and comments, April 2019–May 2026), observing depressive-pole predominance broadly consistent with clinical expectations for BD-related online discussion. 
> BD-Risk dataset

**Comment:**
> これはJiefengさんのデータセットでの結果のことで合っていますか？　であれば、BD-Riskでのvalidationの話の後に言及しましょう。


---

## Page 2

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 04:00

**Highlighted text:**
> without task-specific fine-tuning or labeled training data, making the method directly applicable to new BD corpora.
> Recent work has applied LLMs to mental health NLP tasks [

**Comment:**
> 私が提案しておいて言うのもおこがましいですが、もし可能であれば、シンプルなModernBERTで良いので、BD-Riskの残りデータを使ったfine-tuningとの比較も含めてみてください。現状ではLLM間の比較しかしていないと思います。たとえ少ないデータでもfine-tuningする方がLLMより良いのかどうか、読者は気になると思います。


---

## Page 4

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:42

**Highlighted text:**
> Data collection.

**Comment:**
> デモンストレーションで使うデータの話は、BD-Riskによるvallidationの後ろに持っていきましょう。手法のセクションに書くのも不自然です（このデータがなければ成立しない手法というわけではないでしょうから）

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:40

**Highlighted text:**
> Fig. 1. 
> (three-t

**Comment:**
> 拡大しても文字を読み取るのに苦労するので、レイアウトを工夫するなどして、画像をもう少し大きくできると良いです。


---

## Page 7

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:44

**Highlighted text:**
> 3.3
> LLM Configuration

**Comment:**
> ここからは 4. Validation Experiments として独立させましょう。このLLM configuration自体は、4節のなかの最後に移動させてください。


---

## Page 9

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:49

**Highlighted text:**
> 4
> Results

**Comment:**
> このセクションは取り外し、4.1以降を、新しく作るValidation Experiments 節の中に含めてはどうでしょう。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:49

**Highlighted text:**
> 4.1
> Post-Level Validation Against BD-Risk

**Comment:**
> Validation Results としましょう。あとで記載する、Jiefengさんデータセットでのdemonstrationと区別できます。


---

## Page 10

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:50

**Highlighted text:**
> 4.2
> The Uncertain Label as Quality Control

**Comment:**
> ここから4.5までをInterpretation of Validation Resultsなどとして、1つのサブセクションにまとめてしまってください。subsectionをsubsubsectionにして、入れ子にしてみてください。


---

## Page 19

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:55

**Highlighted text:**
> A
> Appendix: Annotation Prompts

**Comment:**
> 形式がちょっと惜しいです。
> ```
> Appendix \n(←Section)
> A. Annotation Prompts \n (←Subsection)
> Three system prompts ... (←Body)
> ```
> みたいな感じです。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-05-29 03:56

**Highlighted text:**
> Bibliography

**Comment:**
> 念の為、Hallucinationがないか、1つ1つ確認してください。ArXivの論文は、できる限り、会議や雑誌に採択された正式バージョンの方を探してください。ArXiv論文をそのまま引用することはできるだけ避けてください。
