# Comments from `20260601-JiefengLin-Thesis_Draft.pdf`

Source: `archive\20260601-JiefengLin-Thesis_Draft.pdf`

Total annotations: **17**


---

## Page 1

### **[Highlight]** by Koichiro Watanabe — 2026-06-01 01:24

**Highlighted text:**
> scores; few

**Context:**
> research typically provide only binary diagnostic labels or per-post mood
> **scores; few** capture mood trajectories. Because expert annotation is costly
> and fine-tuning requires scarce labeled data, we propose a few-shot prompt-

**Comment:**
> このセミコロンで表現しようとした関係を明示的に書いた方が良いです。
> `Although`などでしょうか?


---

## Page 2

### **[Highlight]** by Koichiro Watanabe — 2026-06-01 01:42

**Highlighted text:**
> 35.7%/6.7% recall on hypomania/mania. 
> ects both a known model property (manic

**Context:**
> out, author-disjoint, stratified subset of 145 posts, achieving macro F1 of 0.519
> with 87.9% depressive recall and **35.7%/6.7% recall on hypomania/mania.** The
> recall asymmetry across poles **reflects both a known model property (manic-side**
> states often manifest through described behaviors rather than affective tone) and a

**Comment:**
> 細かいですが、`35.7%/6.7%`はスラッシュの解釈で読むのが大変なので、スラッシュなしで書いた方が分かりやすいかと思います。

### **[Highlight]** by Koichiro Watanabe — 2026-06-01 01:40

**Highlighted text:**
> Reddit 
> 2), targe

**Context:**
> mood-state analysis of BD on social media and demonstrates its application to
> a Reddit cohort. We collect **Reddit** posts from BD-focused subreddits (r/bipolar,
> r/BipolarReddit, **r/bipolar2), targeting** users who self-identify as having a BD
> diagnosis, and annotate them at two granularities: (1) per-post mood state

**Comment:**
> 引用文献には載せないまでも、注でURLを載せた方がいいかなと思いました。他の論文でも特に参照なしで書いているなら問題ないですが。

### **[Highlight]** by Koichiro Watanabe — 2026-06-01 01:36

**Highlighted text:**
> user-level risk scores.

**Context:**
> 7], yet existing datasets provide only binary diagnosis labels (BD vs. MDD) or
> **user-level risk scores.** Few resources offer post-level mood state labels tracked over
> time, limiting computational research on mood trajectories and, in turn, on BD

**Comment:**
> 2値ラベルでもスコアでも時系列的な変化を追えるので、現状のラベルやスコアだと何が把握できないのかを書いてもらえるとこの研究が解決する問題が素人にも分かります。
> ちなみに`Few resources...`以下で時系列的な把握が難しいことが課題であり、この研究で提案したものは何らかの形(これが知りたいです)でよりよくそれを把握できると主張したいと読んだのですが、それは合っていますか。


---

## Page 3

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 00:41

**Highlighted text:**
> Social media offers a complementary unobtrusive source of passive, naturally produced language over months to years for users already discussing their condition; however, public corpora with period- level mood-trajectory annotations remain limited, constraining longitudinal BD method development.

**Context:**
> apps [11, 12], which yield dense mood signals yet require active enrollment and
> consent, limiting cohort size and external use. **Social media offers a complementary**
> **unobtrusive source of passive, naturally produced language over months to years**
> **for users already discussing their condition; however, public corpora with period-**
> **level mood-trajectory annotations remain limited, constraining longitudinal BD**
> **method development.**
> 2.2

**Comment:**
> この部分はよく書けていると思います。
> 一方で、2.2と2.3、特に2.2では個々の研究の列挙に留まり、2.1との情報の非対称性が気になります。他についても、先行研究を概観して何か本研究との繋がりを書けるとよいです。


---

## Page 4

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 00:58

**Highlighted text:**
> Fig. 1. Annotation pipeline producing structured mood-state labels at two temporal granularities (post-level and 14-day period-level).

**Context:**
> }
> **Fig. 1. Annotation pipeline producing structured mood-state labels at two temporal**
> **granularities (post-level and 14-day period-level).**
> Posting to a mental-health-related subreddit is a necessary yet insufficient signal

**Comment:**
> この図のそれぞれの箱の意味付けが、verificationのような操作とpromptのようなモノのいずれとも対応しており、できれば分けた方が良いです。
> 
> promptを入れる先はLLMですよね?

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 00:42

**Highlighted text:**
> user posting history

**Context:**
> 14-day trend
> **user posting**
> "confidence": "...", "reasoning": "...", }
> verification
> verified
> }
> prompt
> prompt
> 3.1 Pro
> **history**
> cohort

**Comment:**
> 矢印の出どころがないのですが、これは図がはみ出していたりしますか?

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 00:51

**Highlighted text:**
> Posting to a mental-health-related subreddit is a necessary yet insufficient signal of a BD diagnosis: many such posts come from clinicians, family members, or general community participants.

**Context:**
> granularities (post-level and 14-day period-level).
> **Posting to a mental-health-related subreddit is a necessary yet insufficient signal**
> **of a BD diagnosis: many such posts come from clinicians, family members, or**
> **general community participants.** To screen the candidate pool, we apply an LLM
> three-tier classifier (Gemini 3.1 Pro, separate prompt) that scans each author’s

**Comment:**
> これは図の前からは段落を改めて、データの話に移っていますか?
> 
> そうであればインデントしましょう。

### **[Text]** by Koichiro Watanabe — 2026-06-03 00:51
**Comment:**
> アノテーションスキーマと
> LLMを使ってアノテーションをしたというのがこの論文の主なポイントだと読んでいます。
> 
> なのでデータについてセクションをわざわざ設けるべきかというのは考えないといけないのですが、データの話が唐突に始まるので、アノテーションするデータの収集について記述していることを何らかの方法で明示するとよいです。
> 
> `The annotated data was collected ...`みたいな形で書き始めるといいかな、と。
> 
> `posting`、しかも`the`や指示語なしだとデータとして扱うpostingなのだとは読みにくいです。

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 00:44

**Highlighted text:**
> Gemini 3.1 Pro DSM-5-guided DSM-5-guided
> annotation

**Context:**
> "specifiers": "...", "confidence": "...", "reasoning": "...",
> **Gemini**
> Single-post
> 14-day trend
> user posting
> "confidence": "...", "reasoning": "...", }
> verification
> verified
> }
> prompt
> prompt
> **3.1 Pro**
> history
> cohort
> • Task:
> • Task:
> classify each post
> analyze each 14-
> independently
> day period
> LLM evidence
> • Rules:
> • Rules:
> Period-level output
> **DSM-5-guided**
> 3-tier
> DSM-5, safety
> whole-period
> **annotation**
> {

**Comment:**
> 矢印の出どころを真ん中寄りにし、矢印と箱の上下の空間を空けると見やすいです


---

## Page 7

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 01:02

**Highlighted text:**
> The full BD-Risk dataset exhibits a heavily skewed mood distribution (89.0% of posts < 0). Because the deployment task is BD risk detection rather than general mood classification, we deliberately oversample manic-pole posts so that per-class metrics on the underrepresented classes are computed with sufficient support.
> We separate the labeled posts into two disjoint subsets. A development subs

**Context:**
> features
> **The full BD-Risk dataset exhibits a heavily skewed mood distribution (89.0% of**
> **posts < 0). Because the deployment task is BD risk detection rather than general**
> **mood classification, we deliberately oversample manic-pole posts so that per-class**
> **metrics on the underrepresented classes are computed with sufficient support.**
> **We separate the labeled posts into two disjoint subsets. A development subset**
> (314 posts) is used during prompt design and failure-mode analysis. A held-out

**Comment:**
> インデントが必要ですかね?


---

## Page 11

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 01:09

**Highlighted text:**
> Dep Rec
> Hyp Rec
> Man Rec

**Context:**
> Macro F1
> **Dep Rec**
> **Hyp Rec**
> **Man Rec**
> Unc

**Comment:**
> まぁ`Recall`だろうな、とはわかるのですが、なんの断りもなくいきなり`Rec`と略すのは良くないです。おそらくここまでの表では`Recall`は`Recall`と書いていますし、記号を導入する場合はそれと対応する概念を明記しましょう。略称として使うなら`Rec.`のようにピリオドを入れないと少なくとも略なのかどうかも判断がしにくいdす


---

## Page 12

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 01:14

**Highlighted text:**
> directly

**Context:**
> than the clinical significance of the described behaviors, and predicts Depressive.
> The schema’s Behavior Over Tone rule **directly** targets this conflation; however,
> it remains the dominant residual error on the held-out subset, indicating that

**Comment:**
> これがなぜ`directly`なのかよく分からなかったです。

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 01:12

**Highlighted text:**
> clinical significance of the described behaviors,

**Context:**
> remorse or self-blame, the LLM anchors on the current emotional tone rather
> than the **clinical significance of the described behaviors,** and predicts Depressive.
> The schema’s Behavior Over Tone rule directly targets this conflation; however,

**Comment:**
> これはなぜイタリックになっていますか?

### **[Text]** by Koichiro Watanabe — 2026-06-03 01:12
**Comment:**
> `Depressive`はラベルなのでイタリックにしたのだなと分かります


---

## Page 14

### **[Highlight]** by Koichiro Watanabe — 2026-06-03 01:24

**Highlighted text:**
> 5
> Longitudinal Demonstration: Period-Level Mood Trends

**Context:**
> effective on the held-out subset: no crisis-level posts were classified as Uncertain.
> **5**
> **Longitudinal Demonstration: Period-Level Mood**
> **Trends**
> We continuously crawl three BD-focused subreddits (r/bipolar, r/BipolarReddit,

**Comment:**
> この分析の結果、
> - 双極性障害について、何を知見として得ることができるのか
> - そのなかで、これまで提案された枠組みではどこが分からないのか
> を書けるとよいです。
> 今は一旦統計量が書いてあるにとどまるのかな、と。

### **[Text]** by Koichiro Watanabe — 2026-06-03 01:24
**Comment:**
> というのは`6 Discussion`に書いてあるのかもしれませんが、さらにもう一押し、この分類から医療現場などでの応用でこういうことができるようになる、というところまで書いてもらえると意義が分かりやすいです。
> 
> 今はラベルの分布についての知見で、それが応用先でどうなるのかについてまで到達していない?
