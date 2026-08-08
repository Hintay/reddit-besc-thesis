# Comments from `20260708-JiefengLin-Midterm_Slides-Comments.pdf`

Source: `../report/slides/2026-midterm/archive/20260708-JiefengLin-Midterm_Slides-Comments.pdf`

Total annotations: **24**


---

## Page 2

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:08

**Location:**
> Page 2, approx. lines 15


**Highlighted text:**
> 完了した成果(1–4)と進行中・今後(5–6)の構成で報告します

**Context:**
> L14: 6
> L15: **完了した成果(1–4)と進行中・今後(5–6)の構成で報告します**
> L16: 1 / 17

**Comment:**
> 不要


---

## Page 3

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:10

**Location:**
> Page 3, approx. lines 4


**Highlighted text:**
> 鍵となるのは気分状態の「遷移」

**Context:**
> L3: 双極性障害(BD)とは
> L4: **鍵となるのは気分状態の「遷移」**
> L5: 単発の状態ではなく、時間経過に伴う 状態変化の監

**Comment:**
> 「鍵となるのは」は生成AIが好む日本語ですが、実際の研究発表ではあまり使われません。「〜が重要」と表現しましょう

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:11

**Location:**
> Page 3, approx. lines 9


**Highlighted text:**
> Reddit

**Context:**
> L8: ●世界人口の約 1–2% が罹患
> L9: **Reddit** には当事者コミュニティが存在
> L10: 誤診の問題

**Comment:**
> Reddit自体の簡単な紹介と、r/bipolarのスレッド実例を1つ示しましょう


---

## Page 4

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:12

**Location:**
> Page 4, approx. lines 11


**Highlighted text:**
> 標注。タスク特

**Context:**
> L10: ▼
> L11: 本研究のアプローチ: 臨床基準(DSM-5)をプロンプトに埋め込んだ few-shot LLM **標注。タスク特**
> L12: 化の学習もラベル付きデータも不要

**Comment:**
> 修士論文としては逆に、専用コーパスとモデルを作りたいのですから、この文章は誤解を招きます

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:11

**Location:**
> Page 4, approx. lines 5


**Highlighted text:**
> 標注コスト

**Context:**
> L4: ① ラベルの粒度
> L5: ② **標注コスト**
> L6: 二値診断ラベル(BD vs MDD)や投稿単位のスコアのみ。

**Comment:**
> 「標柱」→「アノテーション」


---

## Page 5

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:14

**Location:**
> Page 5, approx. lines 3


**Highlighted text:**
> 最終目的:

**Context:**
> L2: 研究目的と3 つの貢献
> L3: **最終目的:** SNS 上の双極性障害ユーザの状態トレンドを検出する手法を構築する
> L4: その第一段階として、気分状態を2 つの時間粒度で標注するLLM 手法を確立し、 検出モデルの教師データとなる縦

**Comment:**
> モデルをどんなことに役立てたいか、「目的」（モデル開発）と「意義」（モデルを何に役立てるか）に区別して記載すると良いように思います

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:20

**Location:**
> Page 5, approx. lines 12


**Highlighted text:**
> 投稿単位の状態+14 日間の期間トレン

**Context:**
> L11: 縦断コーパスの構築
> L12: **投稿単位の状態+14 日間の期間トレン**
> L13: BD-Risk データセットの保留145 投

**Comment:**
> 14日間のWindowが臨床的にも非常に重要だが、既存データセットはそこに着目されていないと言うことを強調しましょう

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:19

**Location:**
> Page 5, approx. lines 5


**Highlighted text:**
> 断的気分軌跡コーパスを構築する

**Context:**
> L4: その第一段階として、気分状態を2 つの時間粒度で標注するLLM 手法を確立し、 検出モデルの教師データとなる縦
> L5: **断的気分軌跡コーパスを構築する**
> L6: METHOD

**Comment:**
> 軌跡とトレンドをどう区別しますか？話を単純にするために、「トレンド」で統一するのがわかりやすいかもしれません

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:13

**Location:**
> Page 5, approx. lines 4


**Highlighted text:**
> その第一段階として、気分状態を

**Context:**
> L3: 最終目的: SNS 上の双極性障害ユーザの状態トレンドを検出する手法を構築する
> L4: **その第一段階として、気分状態を2** つの時間粒度で標注するLLM 手法を確立し、 検出モデルの教師データとなる縦
> L5: 断的気分軌跡コーパスを構築する

**Comment:**
> 第2段階も示して、修士論文としてのOverviewを説明してください


---

## Page 6

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:17

**Location:**
> Page 6, approx. lines 27


**Highlighted text:**
> 投稿レベル

**Context:**
> L26: → 縦断要件で105 名
> L27: **投稿レベル** — その瞬間の状態
> L28: 期間レベル(14 日) — 軌跡の要約

**Comment:**
> 「投稿単位」・「期間単位」という表現に固定しましょう。「レベル」だとわかりづらいです


---

## Page 7

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:17

**Location:**
> Page 7, approx. lines 4


**Highlighted text:**
> 主要ルール(エラー分析から逆算した設計)

**Context:**
> L3: 状態カテゴリ(4+1)
> L4: **主要ルール(エラー分析から逆算した設計)**
> L5: Behavior Over Tone — 語調より記述された行動の臨

**Comment:**
> 「今回詳しく紹介しないが、予備実験をして、そのエラー分析に基づいてプロンプトを次のように改善した」と説明してください


---

## Page 8

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:21

**Location:**
> Page 8, approx. lines 11


**Highlighted text:**
> 保留評価用

**Context:**
> L10: (−3〜+3)
> L11: **保留評価用** 145 投稿 — 報告する全指標はここか
> L12: ●専門家間一致度 Krippendorff’s α = 0.87

**Comment:**
> 単に「評価サブセット」と表現してください

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:22

**Location:**
> Page 8, approx. lines 5, 7, 9


**Highlighted text:**
> プロンプト設計・失敗分析に のみ使用 (報告数値には一切不使用)

**Context:**
> L4: 評価サブセットの設計
> L5: 開発用 314 投稿 — **プロンプト設計・失敗分析に**
> L6: ●Reddit 7,346 投稿・1,025 ユーザー
> L7: **のみ使用**
> L8: ●精神科医の指導下で付与された7 段階気分ラベル
> L9: **(報告数値には一切不使用)**
> L10: (−3〜+3)

**Comment:**
> 次の行の小さいフォントのブロックにしてください

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:21

**Location:**
> Page 8, approx. lines 11


**Highlighted text:**
> 報告する全指標はここか

**Context:**
> L10: (−3〜+3)
> L11: 保留評価用 145 投稿 — **報告する全指標はここか**
> L12: ●専門家間一致度 Krippendorff’s α = 0.87

**Comment:**
> すごく生成AIっぽい表現です。削除しましょう

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:20

**Location:**
> Page 8, approx. lines 2


**Highlighted text:**
> BD-Risk

**Context:**
> L1: 3 · 検証実験
> L2: 検証設計 — **BD-Risk** による外部検証
> L3: ゴールドスタンダード: BD-Risk (Lee et al., 2024)

**Comment:**
> よく似たデータセットとしてBD-Riskを見つけた。すでに医師による類似のラベリングがされているが、主な違いはラベルの粒度と14日間Windowなので、提案手法のラベルにマッピングした、というような説明があるとわかりやすいです


---

## Page 9

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:23

**Location:**
> Page 9, approx. lines 3


**Highlighted text:**
> 0.519

**Context:**
> L2: 検証結果 — 極性による明確な非対称性
> L3: **0.519**
> L4: State

**Comment:**
> 欧米のビジネスプレゼンみたいに、数字を大きくするのは、研究発表では非推奨です。削除してください。このような方法ではなく、表の数値を太字にしたり色をつけたりすることで強調しましょう


---

## Page 10

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:23

**Location:**
> Page 10, approx. lines 4, 9-10, 14-15


**Highlighted text:**
> 0.398 → F E W - S H O T ・教師デー タなし 0.519

**Context:**
> L3: 例
> L4: **F E W - S H O T ・教師デー**
> L5: 手法
> L6: 学習データ
> L7: Macro F1
> L8: 教師あり( 3 1 4 例)
> L9: **タなし**
> L10: **→**
> L11: ModernBERT
> L12: n = 50
> L13: 0.306 ± 0.022
> L14: **0.519**
> L15: **0.398**
> L16: ModernBERT

**Comment:**
> ビジネススタイルです、やめましょう。


---

## Page 11

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:24

**Location:**
> Page 11, approx. lines 24


**Highlighted text:**
> 躁極の床は全モデル共通(0–20%)

**Context:**
> L23: 7
> L24: ② **躁極の床は全モデル共通(0–20%)** → 構造的
> L25: GLM-5.1

**Comment:**
> 『双極の「床」』という表現の意味がわからないです。

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:24

**Location:**
> Page 11, approx. lines 8


**Highlighted text:**
> 棄権

**Context:**
> L7: Manic Rec.
> L8: **棄権**
> L9: ① 可搬性: 5 社5 モデルが拒否ゼロで構造化出

**Comment:**
> 「拒否」


---

## Page 12

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:25

**Location:**
> Page 12, approx. lines 2


**Highlighted text:**
> 躁極の低再現率の

**Context:**
> L1: 3 · 検証実験
> L2: エラー分析 — **躁極の低再現率の2** つの要因
> L3: 要因1 · モデル特性

**Comment:**
> 「躁極」→「躁状態」？


---

## Page 13

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:26

**Location:**
> Page 13, approx. lines 1


**Highlighted text:**
> 縦断適用

**Context:**
> L1: 4 · **縦断適用**
> L2: 縦断コーパスの構築 — 105 ユーザー・7 年分

**Comment:**
> BESC論文と同様に、これは単なるデモンストレーションであり、LLMのアノテーション結果は人手評価が必要だということがわかるように説明を組み替えてください


---

## Page 16

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:28

**Location:**
> Page 16, approx. lines 5


**Highlighted text:**
> ゼロからの標注ではなく、LLM の標注結果を医師が確認・修正

**Context:**
> L4: 直接分類方式 — 1 期間4 問
> L5: **ゼロからの標注ではなく、LLM の標注結果を医師が確認・修正**
> L6: 主要気分状態(5 択)

**Comment:**
> そもそも医師のアノテーションが必要な理由（＝LLMアノテーション性能のより正確な評価）を説明しましょう。そしてその後の、専用コーパス・モデル開発の計画も振り返りましょう

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:26

**Location:**
> Page 16, approx. lines 1-2


**Highlighted text:**
> 5  ·  進行中
> 医師向けレビューシステム(Argilla v2)

**Context:**
> L1: **5 · 進行中**
> L2: **医師向けレビューシステム(Argilla v2)**
> L3: 方式: LLM 出力の確認・修正ベース

**Comment:**
> Argillaを使っているといった実装レベルの情報は不要です


---

## Page 19

### **[Highlight]** by Shuntaro Yada (矢田 竣太郎) — 2026-07-07 23:28

**Location:**
> Page 19, approx. lines 5, 7, 9, 11, 13, 15, 18, 20


**Highlighted text:**
> 手法 — DSM-5 準拠 few-shot スキーマ(学習不要・ 合成8 例)で 投稿状態+14 日トレンドの2 粒度の標 注 検証 — BD-Risk 保留145 件で macro F1 0.519。 教師あり基線を上回り、5 モデルで可搬性を確認。 躁極の限界は構造的要因と特定 適用 — 105 ユーザー・1,794 期間・15,423 投稿の 縦断気分軌跡コーパスを構築

**Context:**
> L4: 進行中・今後
> L5: **手法 — DSM-5 準拠 few-shot スキーマ(学習不要・**
> L6: 医師によるHuman-in-the-loop 検証 — Argilla レ
> L7: **合成8 例)で 投稿状態+14 日トレンドの2 粒度の標**
> L8: ビューシステム構築済み。 パイロット → 本標注 →
> L9: **注**
> L10: IAA → 再標注 → 修士論文
> L11: **検証 — BD-Risk 保留145 件で macro F1 0.519。**
> L12: 検出モデルの構築 — 検証済みコーパスを教師データ
> L13: **教師あり基線を上回り、5 モデルで可搬性を確認。**
> L14: に、 凍結エンコーダ+時系列ヘッドの軽量モデルを学
> L15: **躁極の限界は構造的要因と特定**
> L16: 習し、 API 非依存・ローカル実行可能な14 日トレ
> L17: ンド検出モデルを構築
> L18: **適用 — 105 ユーザー・1,794 期間・15,423 投稿の**
> L19: 倫理: 筑波大学研究倫理委員会 承認番号 25-188。 公開時は
> L20: **縦断気分軌跡コーパスを構築**
> L21: LLM ベース匿名化(5 カテゴリPII)+相対時間オフセット+ 公開前

**Comment:**
> BESCに投稿したことを報告すると良いです
