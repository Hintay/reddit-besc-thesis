# 修改方案 — 导师评审意见 20260529

整合本轮两份反馈：
- **PDF 内批注** 10 条 → [`20260529-JiefengLin-Thesis_Draft.comments.md`](20260529-JiefengLin-Thesis_Draft.comments.md)
- **Slack 讨论**（含 ModernBERT baseline 的实验设计决策）→ [`20260529-slack_discussion.md`](20260529-slack_discussion.md)

> 与上一版 [`revision_plan_20260527.md`](revision_plan_20260527.md) 的关系：上一版 26 条意见（定位 / 结构 / 表述 / 格式）多数已落实于当前 `bd-risk.typ`。本轮为第二轮反馈，核心是**两件大事**——① 进一步的节构成重组（validation 与 demonstration 彻底分开）；② 新增 ModernBERT fine-tuning baseline。标 🆕 的为本轮全新项。
>
> 论文为 **Typst** 源（`bd-risk.typ`）：`=` 为一级节，`==` 为二级节，`===` 为三级节。

---

## 总体评估

老师评价"相当不错"。本轮意见分四类：

| 类别 | 来源 | 核心要求 |
|---|---|---|
| **节构成重组** | PDF #1 #3 #5 #6 #7 #8 | validation 独立成节、Results 并入、demonstration 数据后置、子节嵌套 |
| **🆕 新增实验** | PDF #2 + Slack | ModernBERT fine-tuning baseline，逐档训练规模，与 LLM few-shot 比较 |
| **图表与格式** | PDF #4 #9 | Fig.1 放大；Appendix prompt 格式微调 |
| **合规与流程** | PDF #10 + Slack | 逐条核查 bibliography 幻觉、换正式发表版；投稿系统先试登记 |

---

## 一、节构成重组

### 当前结构（`bd-risk.typ`，老师 0529 审阅版，实测节标题）

```
= Introduction
= Related Work
  == Longitudinal Mood Monitoring in BD
  == Social Media in Mental Health Detection
  == LLMs for Clinical NLP and Mental Health
= Methodology
  == Method Overview
  == Annotation Schema
       === Post-Level State Classification
       === Period-Level Trend Analysis
       === Few-Shot Example Construction
  == LLM Configuration
  == External Validation Against BD-Risk
       === The BD-Risk Dataset / Gold State Derivation / Evaluation Set Construction
  == Evaluation Metrics
  == Evaluation Design
= Results
  == Post-Level Validation Against BD-Risk
  == The Uncertain Label as Quality Control
  == Schema Contribution: Comparison with a Zero-Shot Baseline
  == Cross-Model Annotation Feasibility
  == Error Analysis
= Longitudinal Demonstration: Period-Level Mood Trends   ← 已是独立一级节
= Discussion / = Limitations / = Conclusion / = Ethical Considerations
= Appendix: Annotation Prompts
```

> 说明：Demonstration 已是独立一级节（非 Results 子节），故 PDF #1/#3 主要是把 **Data collection / Method Overview 里的演示数据描述**后移到该节，并确保摘要中的自有数据集结果排在 validation 之后。`Evaluation Design` 节为上一版 #15/#17/#18 落实的成果。

### 老师本轮的结构指示（逐条）

**PDF #5（p7，highlight "LLM Configuration"）** 🆕
> ここからは 4. Validation Experiments として独立させましょう。このLLM configuration自体は、4節のなかの最後に移動させてください。
- 新建独立的 **`= Validation Experiments`** 一级节。
- **LLM Configuration 本身移到设计类子节的末位**（从 Methodology 移出，排在 Evaluation Design 之后、结果子节之前）。

**PDF #6（p9，highlight "Results"）** 🆕
> このセクションは取り外し、4.1以降を、新しく作るValidation Experiments 節の中に含めてはどうでしょう。
- **取消独立的 `= Results` 节**，把其下小节并入新的 Validation Experiments 节。

**PDF #7（p10，highlight "Post-Level Validation Against BD-Risk"）** 🆕
> Validation Results としましょう。あとで記載する、Jiefengさんデータセットでのdemonstrationと区別できます。
- "Post-Level Validation Against BD-Risk" 改名 **"Validation Results"**，与后面用 Jiefeng 数据集做的 demonstration 区分。

**PDF #8（p10，highlight "The Uncertain Label as Quality Control"）** 🆕
> ここから4.5までをInterpretation of Validation Resultsなどとして、1つのサブセクションにまとめてしまってください。subsectionをsubsubsectionにして、入れ子にしてみてください。
- 把 Uncertain Label → Error Analysis 之间的解释性小节合并为**一个二级节** "Interpretation of Validation Results"，原各 `==` 降级为 **`===` 嵌套**。
- 经核对当前 `bd-risk.typ`：Results 下的四个子节（Uncertain / Zero-Shot / Cross-Model / Error Analysis，L466–551）已是**连续**的解释性内容，中间并无夹杂 demonstration（demonstration 早已是独立一级节 L552）。故本条为直接的"四合一 + 降级嵌套"操作，无需额外抽离。

**PDF #1（p1，highlight 摘要中 Gemini 3.1 Pro 结果）** 🆕
> これはJiefengさんのデータセットでの結果のことで合っていますか？であれば、BD-Riskでのvalidationの話の後に言及しましょう。
- **这是一个带前提的指令**：老师先问"这是否是你自有数据集（demonstration）的结果？"，*确认为是*之后才要求移到 BD-Risk validation 叙述之后。
- 经核对，`bd-risk.typ` 中该句（"apply the method to 105 self-identified BD users…"，L70 附近）确属 demonstration 数据的结果 → 前提成立，**应执行移动**：摘要 / 引言里这部分结果排到 BD-Risk validation 之后再提。

**PDF #3（p4，highlight "Data collection."）**
> デモンストレーションで使うデータの話は、BD-Riskによるvalidationの後ろに持っていきましょう。手法のセクションに書くのも不自然です（このデータがなければ成立しない手法というわけではないでしょうから）
- 演示用 Reddit 数据的描述移到 BD-Risk validation **之后**；不放在方法节（方法不依赖这批数据）。

### 目标结构

```
= Methodology
  == Method Overview        (保留方法框架总览；仅移出"演示数据"专属描述)  [PDF #3]
  == Annotation Schema      (=== Post-Level / Period-Level / Few-Shot)
= Validation Experiments                                     [PDF #5/#6]
  == External Validation Against BD-Risk      (设计：BD-Risk / Gold / Eval Set)
  == Evaluation Metrics
  == Evaluation Design      ← 随 3.3 起的内容一并并入（含 🆕 BERT 设计预告） [PDF #5]
  == LLM Configuration      ← 设计类子节的末位，排在结果之前 [PDF #5]
  == Validation Results                       ← 原 "Post-Level Validation" 改名 [PDF #7]
  == BERT Fine-Tuning Baseline                🆕 见第二节
  == Interpretation of Validation Results     ← 合并嵌套 [PDF #8]
       === The Uncertain Label as Quality Control
       === Zero-Shot Baseline Comparison
       === Cross-Model Feasibility Probe
       === Error Analysis
= Longitudinal Demonstration: Period-Level Mood Trends        [PDF #1/#3]
  (演示数据 / Data collection 描述置于本节开头)
= Discussion / = Limitations / = Conclusion / = Ethical Considerations
= Appendix                                                    [PDF #9]
  == A. Annotation Prompts
```

> ⚠️ 关键约束：
> - **切口在原 3.3 LLM Configuration**：PDF #5 原话「**ここからは** 4. Validation Experiments として独立させましょう」="从这里(3.3)起独立成节"。因此原 3.3 及其之后的全部内容（LLM Config / External Validation / Evaluation Metrics / **Evaluation Design**）都并入 Validation Experiments。
>   - 这同时消除了前一版方案的内部不一致：`External Validation`、`Evaluation Metrics`、`Evaluation Design` 同属"设计/设置"内容，应同进同出，不能两搬一留。
> - **LLM Config 排在设计类子节的末位、结果子节之前**：PDF #5「最後に移動」的"最後"解读为设计/设置类子节中的末位（导师写 #5 时 Results 尚未并入本节；核心意图是不让 LLM Config 排在节首，而非刻意制造"结果先于设置"的阅读顺序）。这保持了"设置 → 结果 → 解释"的自然阅读顺序。
> - **`Method Overview` 不整段搬走**：它承担全文方法框架的开篇，只移出其中"应用于 Reddit 自有数据"这类演示数据描述（L70 句 + L269 `*Data collection.*`），方法总览句保留。
> - **Methods-preview 规则仍满足**（见 `CLAUDE.md`）：`Evaluation Design` 现位于 Validation Experiments 节内、且排在各结果子节（Validation Results / BERT / Interpretation）**之前**，因此"先预告设计、再报告结果"的读者保护目的依然成立——预告只是从 Methodology 节移到了 Validation Experiments 节首。新增的 BERT baseline 设计预告也写在此处。

> 小节先后可微调，但有两条**硬约束不可动**：(a) 切口在原 3.3，3.3 起的内容（含 Evaluation Design）整体并入 Validation Experiments；(b) LLM Config 排在设计类子节末位、结果子节之前（不排节首，也不越过结果排绝对末位）。其余须满足：① Validation Experiments 独立成节并吸纳原 Results；② Post-Level Validation 改名 Validation Results；③ 解释性内容合并为 `===` 嵌套；④ demonstration（已是一级节）的数据描述后置、摘要结果次序调整。

---

## 二、🆕 新增 ModernBERT fine-tuning baseline

> 来源：PDF #2（p2）+ Slack 20:06 / 20:42（两轮确认）。**本轮工作量最大的新增项，上一版 plan 完全未涉及。**
>
> ⚠️ 语气定位：老师措辞为「私が提案しておいて…おこがましいですが、**もし可能であれば**」「土壇場で申し訳ない」——这是一个**尽力而为的请求（可选项）**，而非硬性要求。真正硬性的是结构调整与投稿系统试登记。不过 Jiefeng 已在 Slack 明确答应实施，且其工作量与不确定性最大，故在执行排序上仍按"结构优先、BERT 在后"安排（与老师 Slack 21:01 的先后一致）。

### 目的
- 证明 **LLM few-shot 与 BERT 微调 comparable** 即可；即使 BERT 更高也无妨——要点是"标几百条数据通常非常费力"，LLM few-shot 能打平就足以支撑论点。
- 当前论文只有 LLM 之间比较，读者会想知道"少量数据微调是否就胜过 LLM"。

### 数据划分（已定）
- **测试集**：固定为共享 **hold-out 145 件**（BERT 与 Gemini 同一套测试集，便于直接比较）。
- **训练集**：从 **314 件**训练池中切分（现有 459 = 314 + 145 框架内，**不另取外部数据**）。

### 实验档位（逐步增加训练规模，给 3–4 档）
```
Gemini few-shot            (现有)
Gemini zero-shot           (现有)
BERT (50 labelled)         🆕
BERT (100 labelled)        🆕
BERT (… labelled)          🆕   ← 档位数与具体值由 Jiefeng 定
BERT (314 labelled, 全量)  🆕
```
- 老师举例提到 50 / 100 / 1000，但已确认训练数据在 **314 件内**，故最大档为 314（或近似取整）。具体档位 Jiefeng 自定。

### 资源
- 若用云服务，老师**可代垫付款**（实验室服务器远程访问困难）。

### 论文写法
- BERT baseline 属 validation → 写入新 `= Validation Experiments` 节。
- 需在该节的 `Evaluation Design` 子节**预告**实验设计（遵循 `CLAUDE.md`："每个评价实验须先有设计预告、再报告结果"）；Evaluation Design 排在 BERT 结果子节之前，先后成立。

---

## 三、图表与格式

### 3.1 Fig.1 放大（PDF #4，p4）🆕
> 拡大しても文字を読み取るのに苦労するので、レイアウトを工夫するなどして、画像をもう少し大きくできると良いです。
- Fig.1（three-tier 流程图）放大仍难读清，需调整布局把图做大。

### 3.2 Appendix Annotation Prompts 格式（PDF #9，p19）
> 形式がちょっと惜しいです。（批注中附了改进示例代码块）
- Appendix prompt 呈现格式微调，参照老师批注示例。详见 comments.md 第 9 条。

---

## 四、合规与流程

### 4.1 Bibliography 幻觉核查（PDF #10，p19）🆕
> 念の為、Hallucinationがないか、1つ1つ確認してください。ArXivの論文は、できる限り、会議や雑誌に採択された正式バージョンの方を探してください。ArXiv論文をそのまま引用することはできるだけ避けてください。
- **逐条核查** `refs.bib` 是否存在幻觉条目。
- arXiv 论文尽量替换为**会议 / 期刊正式发表版**，避免直接引用 arXiv。

### 4.2 🆕 投稿系统先行试登记（Slack 21:01）
> BERTの結果を組み込む前に、節構成の変更ができたら、一度投稿システムから論文を登録してみてください。
- **在并入 BERT 结果之前**，先完成节构成调整 → 到投稿系统**试登记一次**。
- 目的：提前摸清论文外需填写的信息；截止前可覆盖重投，避免临近 DL 手忙脚乱。

---

## 五、执行顺序（老师隐含优先级）

1. **节构成重组**（第一节）—— validation / demonstration 分离，Results 并入，子节嵌套。
2. **投稿系统试登记**（4.2）—— 用重构后的稿件走一遍流程。
3. **ModernBERT baseline 实验**（第二节）—— 出结果后并入论文。
4. **图表 / 格式 / bibliography**（第三、四节）—— 可与上述并行。

---

## 六、意见–修改对照表

| # | 来源 | 页/时间 | 意见摘要 | 对应修改 | 新增? | 状态 |
|---|---|---|---|---|---|---|
| 1 | PDF | p1 | Gemini 3.1 Pro 结果移到 BD-Risk validation 后 | §一 摘要/引言调整 | 🆕 | ✅ 完成 |
| 2 | PDF | p2 | 加 ModernBERT 微调 baseline | §二 全节 | 🆕 | ✅ 完成 |
| 3 | PDF | p4 | Data collection 移到 validation 后、出方法节 | §一 demonstration 数据后置 | — | ✅ 完成 |
| 4 | PDF | p4 | Fig.1 放大 | §3.1 | 🆕 | ✅ 完成 |
| 5 | PDF | p7 | 独立 Validation Experiments；LLM Config 移至设计类末位 | §一 目标结构 | 🆕 | ✅ 完成 |
| 6 | PDF | p9 | 取消 Results 节，小节并入 Validation Experiments | §一 目标结构 | 🆕 | ✅ 完成 |
| 7 | PDF | p10 | Post-Level Validation 改名 Validation Results | §一 目标结构 | 🆕 | ✅ 完成 |
| 8 | PDF | p10 | 解释性小节合并为 Interpretation 子节、嵌套 | §一 目标结构 | 🆕 | ✅ 完成 |
| 9 | PDF | p19 | Appendix prompt 格式微调 | §3.2 | — | ✅ 完成 |
| 10 | PDF | p19 | Bibliography 逐条核查幻觉、换正式版 | §4.1 | 🆕 | ✅ 完成 |
| S1 | Slack | 20:06/20:42 | BERT 数据划分：test=145 hold-out，train⊂314 | §二 数据划分 | 🆕 | ✅ 已定 |
| S2 | Slack | 21:01 | 云服务可代垫付款 | §二 资源 | 🆕 | ℹ️ 信息 |
| S3 | Slack | 21:01 | 并入 BERT 前先到投稿系统试登记 | §4.2 | 🆕 | 📌 待办 |
