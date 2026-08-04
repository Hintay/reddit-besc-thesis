# 渡邊先生コメントへの対応

渡邊先生

お忙しい中、原稿を丁寧にお読みいただき、17件のコメントをいただきありがとうございました。以下、各コメントへの対応をまとめました。

---

## Page 1

### コメント1：セミコロン `scores; few`

> このセミコロンで表現しようとした関係を明示的に書いた方が良いです。`Although`などでしょうか?

**対応：採用しました。**

ご指摘の通り、`Although` を用いて論理関係を明示しました。

> Although existing social media datasets for BD research provide binary diagnostic labels or per-post mood scores, few capture how mood states evolve over time.

---

## Page 2

### コメント2：スラッシュ表記 `35.7%/6.7%`

> スラッシュの解釈で読むのが大変なので、スラッシュなしで書いた方が分かりやすいかと思います。

**対応：採用しました。**

Abstract と Introduction の2箇所をそれぞれ修正しました。

- Abstract: `lower manic-pole recall (35.7% hypomanic, 6.7% manic)`
- Introduction: `87.9% depressive recall, 35.7% hypomanic recall, and 6.7% manic recall`

### コメント3：subreddit の URL を脚注に載せる

> 引用文献には載せないまでも、注でURLを載せた方がいいかなと思いました。他の論文でも特に参照なしで書いているなら問題ないですが。

**対応：不採用としました。**

同分野の先行研究（Sekulić et al.、Jagfeld et al.、Cohan et al. など）を確認したところ、いずれもサブレディット名のみで URL を付記していないため、分野の慣例に従い脚注は省略しました。

### コメント4：既存のラベルやスコアでは何が把握できないのか

> 2値ラベルでもスコアでも時系列的な変化を追えるので、現状のラベルやスコアだと何が把握できないのかを書いてもらえるとこの研究が解決する問題が素人にも分かります。

**対応：採用しました。**

ご指摘の通り、既存ラベルが per-user の一回限りの判定であり、投稿ごとの気分状態の変遷を記録していない点を明示しました。

> yet existing datasets provide only per-user binary diagnosis labels (BD vs. MDD) or aggregate user-level risk scores, neither of which records how individual mood states evolve across posts.

渡邊先生のご理解（「この研究で提案したものがよりよくそれを把握できると主張したい」）は正確です。本手法は per-post の気分状態ラベルと14日間の period-level トレンドを提供するもので、既存の per-user ラベルでは不可能な縦断的な気分状態の追跡を可能にします。

---

## Page 3

### コメント5：Section 2.2・2.3 が列挙にとどまっている

> 2.2と2.3、特に2.2では個々の研究の列挙に留まり、2.1との情報の非対称性が気になります。他についても、先行研究を概観して何か本研究との繋がりを書けるとよいです。

**対応：採用しました。**

各セクションの冒頭に、先行研究全体を概観する総括文を追加しました。

- Section 2.2: `Social media mental health research has progressed from population-level depression signals to individual diagnostic classification across multiple conditions, yet most datasets lack post-level mood-state granularity.`
- Section 2.3: `The emergence of LLMs has expanded the scope of clinical NLP; however, their application to fine-grained BD mood-state classification has received limited attention.`

各セクションの末尾には本研究との接続がすでにあるため（2.2: BD-Risk を gold standard として使用、2.3: 診断予測ではなく annotation 手法としての差別化）、冒頭の総括文を加えることで「総—分—総」の構成に近づけました。

---

## Page 4

### コメント6：Fig. 1 の箱が操作とモノの混在

> この図のそれぞれの箱の意味付けが、verificationのような操作とpromptのようなモノのいずれとも対応しており、できれば分けた方が良いです。promptを入れる先はLLMですよね?

**対応：採用しました。**

「LLM prompts」と「Gemini 3.1 Pro」の2つの箱を統合し、「DSM-5-guided annotation (Gemini 3.1 Pro)」という1つの操作ステージにまとめました。プロンプトはその内部のサブコンポーネントとして表示されます。これにより、パイプライン上の箱がすべて操作（verification → annotation）を表すようになり、プロンプトがLLMへの入力であることも図内で自明になりました。

### コメント7：矢印の出どころがない

> 矢印の出どころがないのですが、これは図がはみ出していたりしますか?

**対応：採用しました。**

ご推察の通り、矢印の起点がページの外にはみ出していました。「User posting history」を他の箱と同じスタイル（枠線付き）のノードとして追加し、起点を明確にしました。

### コメント8：矢印の位置と間距

> 矢印の出どころを真ん中寄りにし、矢印と箱の上下の空間を空けると見やすいです

**対応：採用しました。**

ノード間の水平間隔を拡大し、箱の統合（コメント6）と合わせて全体のレイアウトを調整しました。

### コメント9・10・11：図の後の段落（インデント／データの話の始まり方／`posting` の冠詞）

> これは図の前からは段落を改めて、データの話に移っていますか? そうであればインデントしましょう。

> データの話が唐突に始まるので、アノテーションするデータの収集について記述していることを何らかの方法で明示するとよいです。

> `posting`、しかも`the`や指示語なしだとデータとして扱うpostingなのだとは読みにくいです。

**対応：コメント10を採用し、9と11は現状維持としました。**

図の直後に以下の導入文を追加し、セクションの残りが各パイプラインステージの説明であることを明示しました。

> The remainder of this section describes each pipeline stage. We first detail the patient verification step that determines the annotation cohort, then present the annotation schema.

インデント（コメント9）については、`*Patient verification.*` のボールド見出しが LNCS フォーマットにおける段落開始の標準的な表記であるため、追加のインデントは不要と判断しました。

`Posting` の冠詞（コメント11）については、この文は「メンタルヘルス関連のサブレディットへの投稿は、BD 診断の必要条件ではあるが十分条件ではない」という一般的な事実の記述（patient verification の動機付け）であり、本研究のデータを特定して指す文ではないため、`The` や指示語なしの表記が英語として適切と判断しました。上記の導入文により、この文の役割（verification の必要性の説明）がより明確になっています。

---

## Page 7

### コメント12：インデント

> インデントが必要ですかね?

**対応：現状維持としました。**

「The full BD-Risk dataset...」は Section 4.1.3 (Evaluation Set Construction) の最初の段落であり、LNCS フォーマットではセクション見出し直後の段落はインデントしない規則になっています。2段落目（「We separate...」）には自動的にインデントが入ります。

---

## Page 11

### コメント13：`Rec` の略称

> なんの断りもなくいきなり `Rec` と略すのは良くないです。

**対応：確認しました。**

現在のソースファイルでは、すべての表で `Recall` と完全表記しており、`Rec` の略称は使用していません。渡邊先生がレビューされた PDF の表示と現在のソースに差異がある可能性があります。いずれにせよ、ご指摘の方針（略称を使うなら事前に定義する）は今後も遵守いたします。

---

## Page 12

### コメント14：`directly`

> これがなぜ `directly` なのかよく分からなかったです。

**対応：採用しました。**

ご指摘の通り、直後に「dominant residual error のままである」と述べているため、`directly targets` は効果を過大に示唆していました。`is designed to address` に修正し、設計意図と実際の効果のギャップを正確に表現しました。

### コメント15・16：非ラベルテキストのイタリック

> これはなぜイタリックになっていますか?（`clinical significance of the described behaviors`）
> `Depressive`はラベルなのでイタリックにしたのだなと分かります

**対応：採用しました。**

ご指摘の通り、イタリックの用途を mood state ラベル（`_Depressive_`、`_Stable_` など）に限定し、強調目的のイタリック（`_current emotional tone_`、`_clinical significance of the described behaviors_`）を削除しました。これにより、イタリック＝ラベル名という一貫した表記規則になります。

---

## Page 14

### コメント17：Section 5 に知見と応用の記述が不足

> - 双極性障害について、何を知見として得ることができるのか
> - そのなかで、これまで提案された枠組みではどこが分からないのか
> を書けるとよいです。

> この分類から医療現場などでの応用でこういうことができるようになる、というところまで書いてもらえると意義が分かりやすいです。

**対応：採用しました。**

Section 5 の末尾（Discussion の直前）に、以下の3層を含む段落を追加しました。

1. **既存手法との対比：** 従来の per-user/per-post の手法は静的なスナップショットにとどまり、数週間〜数ヶ月にわたる状態の遷移を捉えられない。
2. **知見の具体例：** User B（躁状態へのエスカレーション → エピソード発症のパターン）、User D（混合特徴の高頻度出現 → 急速交代型と整合的）。
3. **臨床応用の方向性：** エピソード発症・エスカレーション・サイクリングのシグナルは、臨床早期警告システムや患者のセルフモニタリングツールへの入力となりうる。ただし、臨床的有用性は専門家によるperiod-levelのアノテーションで検証する必要がある。

---

## その他

### 引用アンカーの書式（Slack でのご質問）

> `De Choudhury, M. et al. [13]` のような書き方は、このスタイルを採用しているのか確認したく。

これは LNCS（Springer Lecture Notes in Computer Science）の標準的な引用形式です。fine-lncs テンプレートが自動的にこの形式で出力します。

### 著者情報

渡邊先生を共著者として追加いたしました（Lin → Watanabe → Yada の順）。ORCID `0000-0002-3543-2159` を登録済みです。

---

以上です。ご確認いただけますと幸いです。ご不明な点がございましたら、いつでもお知らせください。
