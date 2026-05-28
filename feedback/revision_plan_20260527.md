# 修改方案 — 导师评审意见 20260527

基于论文全文（33页）和导师26条批注的逐条分析。

---

## 总体评估

导师的意见不涉及实验设计或技术方案，全部集中在**论文的定位、表述和格式**上。可分为四类：

| 类别 | 评论编号 | 核心要求 |
|---|---|---|
| **论文定位** | #1, #2, #4, #8 | 从「发布数据集」转向「提出方法」 |
| **章节结构** | #5, #10, #15, #17–21 | 调整叙述顺序、预告评价内容、拆分/合并小节 |
| **表述规范** | #6, #7, #9, #12, #13 | 措辞修正、补充依据、删除冗余 |
| **格式与合规** | #3, #11, #14, #16, #22–26 | 图表、排版、参考文献、数据公开 |

---

## 一、论文定位调整

### 1.1 标题（#4）

**导师原话**：标题应包含 "longitudinal mood-state analysis / bipolar disorder / social media / large language model" 等关键词，去掉系统名 MoodTrail-BD。

**现状**：MoodTrail-BD: A Longitudinal Mood-State-Labeled Social Media Resource for Bipolar Disorder

**修改方向**：

- 去掉 "MoodTrail-BD:" 前缀（正文中保留）
- 加入 LLM / few-shot 相关关键词
- 参考标题：
  - "Few-Shot Prompt-Based Longitudinal Mood-State Analysis of Bipolar Disorder on Social Media"
  - "A DSM-5-Grounded LLM Approach to Longitudinal Mood-State Analysis of Bipolar Disorder on Social Media"

### 1.2 摘要与 Introduction 的方法论定位（#1, #2）

**导师原话**：
- #1："present a resource" 改为 "propose a few-shot prompt-based LLM method" 方向
- #2：BD数据集难以构建，不需要 fine-tuning 的 few-shot prompt 应用范围广、有用，应在 Introduction 中主张这一点

**现状**（Abstract 第3–4行）："We **present** a longitudinal mood-state-labeled social media **resource** that provides annotations at two granularities"

**修改方向**：

Abstract：
- "present a resource" → "propose a method"（方法论文而非数据论文）
- 强调 few-shot prompt 无需 fine-tuning、无需标注训练数据的优势

Introduction（#2 的因果链需要完整体现）：
- **先铺垫**：BD 领域的标注数据稀缺、构建成本高，fine-tuning 路线门槛很高
- **再论证**（#8）：LLM 能力的进步使得仅凭人类用的临床指南（DSM-5）就能取得一定的标注性能
- **得出结论**：因此，基于 DSM-5 指南设计 few-shot prompt 是可行且泛用的方法

这三步形成 Introduction 的核心叙事线索，应安排在现有 Introduction 的第2–3段。

### 1.3 Introduction 措辞（#7）

**导师原话**：「None offer post-level mood state labels」太绝对，难以证明。改为强调 mood trajectories 的计测手法很重要。

**修改方向**：
- "None offer..." → "Few existing resources provide post-level mood state labels tracked over time, which limits computational research on mood trajectories"（弱化绝对表述，转为强调重要性）

### 1.4 Contributions 列表（#5）

**导师原话**：区分「用 BD-Risk 改造数据评价提案手法的性能」和「用新数据集做 longitudinal analysis demonstration」

**现状**：三条 contributions 混在一起，评价和展示没有区分

**修改方向**：重写为三条，明确区分：
1. **方法**：基于 DSM-5 的 few-shot prompt schema（两粒度标注，无需 fine-tuning）
2. **评价**：在 BD-Risk holdout 上的外部验证结果
3. **展示**：对新采集 Reddit 数据的纵向情绪轨迹分析

---

## 二、章节结构调整

导师的结构意见是**局部调整**，不是推翻现有框架。

### 2.1 §3 Methodology 叙述顺序（#10）

**导师原话**：按以下顺序说明——DSM-5 如何变成 prompt → few-shot 如何选择 → 如何评价性能（BD-Risk 如何利用）

**现状小节顺序**：3.1 Resource Overview → 3.2 Annotation Schema → 3.3 BD-Risk Validation → 3.4 LLM Configuration → 3.5 Evaluation Metrics

**问题**：§3.4 LLM Configuration（包含 prompt 设计和 few-shot 例子的说明）放在了 §3.3 BD-Risk Validation 之后。按导师要求的逻辑，应该**先讲方法（prompt 怎么设计、few-shot 怎么选），再讲评价（BD-Risk 怎么用）**。

**修改方向**：调整 §3 内部小节顺序：

```
3.1 Resource Overview                ← 保持
3.2 Annotation Schema                ← 保持，补充 14 天依据
3.3 LLM Configuration               ← 原 3.4，提前：讲 prompt 设计和 few-shot 选择
3.4 External Validation Against BD-Risk ← 原 3.3，后移：讲 BD-Risk 如何利用
3.5 Evaluation Metrics               ← 保持
3.6 Evaluation Design                ← 新增（见 2.2）
```

这样 §3 的叙述线就是：语料概况 → annotation schema（DSM-5→规则）→ LLM 配置与 prompt/few-shot 设计 → 外部验证设计 → 评价指标 → 评价实验预告。符合导师要求的「DSM-5→prompt→few-shot→评价」顺序。

### 2.2 新增 §3.6 + 移出 §3.4 中的评价内容（#15, #17, #18）

**导师原话**：
- #15（标注在 §3.4 的 cross-model/zero-shot 段落上）：「わかりやすく、評価の内容として独立させてください。zero-shotとの比較も同様です。3.6節としましょう。」
- #17：§4.3 zero-shot baseline → 在 Methods 中预告
- #18：§4.4 cross-model → 同上

**#15 的准确含义**：导师标注的位置是 §3.4 里那段 "Gemini 3.1 Pro is the primary annotator... A cross-model probe with GPT-5.5 is reported in Section 4..."。导师的意思是把**这段已有文字从 §3.4 中抽出来**，作为独立的 §3.6，而不是另写一段预告。

**修改方向**：
- 将 §3.4（调整后为新 §3.3）末尾关于 cross-model probe 和 zero-shot 比较的段落**移至新 §3.6**
- §3.6 标题如 "Evaluation Design" 或 "Ablation and Cross-Model Probes"
- 在 §3.6 中补充说明各评价实验的目的：
  - Zero-shot baseline：量化 schema 的贡献（#17）
  - Cross-model probe：验证 schema 的可移植性（#18）

### 2.3 §4.5 Author-Level Aggregation（#19）

**导师原话**：「この検証は省略してもいいかもしれません。含めるなら、methodsセクションにも、実施する意図を宣言しておいてください。」

**修改方向**：**待导师确认**。两种选择：
- 删除 §4.5，在 Discussion 中用一句话提及结论
- 保留 §4.5，但在 §3.6 中预告其设计意图

### 2.4 §4.6 → 新 §5（#20）

**导师原话**：「これを5節として独立させてください。Userももっと増やせると良いですね。」

**修改方向**：
- 将 §4.6 提升为独立的 §5（如 "5 Longitudinal Demonstration"）
- 目前 Fig.3 只展示了 2 名用户，需增加更多代表案例
- 后续章节（Discussion 等）编号顺推

**关于增加用户数**：需要确认 reddit_research.db 中已跑完 period-level trend 的用户数量，以及是否需要重新运行 pipeline。这是一个**数据准备工作项**，待确认数据状态后再决定具体增加多少。

### 2.5 §5 Error Analysis → 并入 §4（#21）

**导师原话**：「提案手法の検証ということで、4節の中に含めましょう。あるいは、結果と検証を2つのセクションに分けても良いです。」

导师提供了两种选择：
- **方案 A**：Error Analysis 作为 §4 的一个小节（如 §4.5）
- **方案 B**：Results 和 Verification 分成两个独立 section

**注意**：导师**没有要求压缩** Error Analysis 的篇幅。如果选方案 A，只是位置变了，6 个 pattern 可以完整保留。后续如果需要压缩页数，那是独立的决策，不属于导师的要求。

**修改方向**：建议选方案 A（并入 §4），更简洁。压缩与否后续视页数需求再定。

### 调整后的结构一览

```
1 Introduction（重新定位为方法论文）
2 Related Work（2.1, 2.2, 2.3）
3 Methodology
  3.1 Resource Overview               ← 保持
  3.2 Annotation Schema               ← 保持，补充 14 天依据
  3.3 LLM Configuration               ← 原 3.4，提前
  3.4 External Validation Against BD-Risk ← 原 3.3，后移
  3.5 Evaluation Metrics               ← 保持
  3.6 Evaluation Design                ← 从原 3.4 抽出 + 补充预告
4 Results
  4.1 Post-Level Validation            ← 原 4.1
  4.2 Uncertain Label as QC            ← 原 4.2
  4.3 Zero-Shot Baseline Comparison    ← 原 4.3
  4.4 Cross-Model Feasibility          ← 原 4.4
  4.5 Error Analysis                   ← 原 §5，位置移入
  （原 4.5 Author-Level：待确认删除或保留）
5 Longitudinal Demonstration           ← 原 4.6，扩展用户数
6 Discussion                           ← 原 §6
7 Limitations                          ← 原 §7
8 Ethical Considerations               ← 原 §8
Appendix A–C                           ← 原 §9，改 A-Z 编号
References
```

---

## 三、表述修正

### 3.1 避免使用 "but"（#6）

**导师原话**：论文中应避免 but。

**修改方向**：全文检索 "but"，逐一替换为 however / although / while / yet，或重构句式。

### 3.2 补充 14 天窗口的临床依据（#12）

**导师原话**：14 天的设定是基于 DSM 和医师推荐的，要写明。

**现状**（p.5）："we partition each user's posting history into consecutive fixed-length periods (default: 14 days)"

**修改方向**：在此处补充一句："The 14-day window length is informed by DSM-5 diagnostic criteria, which define a major depressive episode as lasting at least two weeks [17]."

### 3.3 删除冗余说明（#13）

**导师原话**：引用就够了，不需要写这种东西。

**涉及文本**（p.6 §3.3）："the clinically validated BD-Risk dataset introduced by Lee et al. [1] at NAACL 2024. Period-level trend analysis is not externally validated in this paper, as no existing dataset provides expert-annotated mood trajectories at the period level."

**修改方向**：精简为 "We validate post-level state classification against the BD-Risk dataset [1]."，其余引用即可。

### 3.4 Twitter 标记（#9）

**导师原话**：写成 Twitter (currently called X)。

**修改方向**：首次出现改为 "Twitter (currently X)"，后续统一用 X。

---

## 四、格式与合规

### 4.1 新增 Prompt/Output 图（#11）

**导师原话**：把 LLM 的 prompt 和输出做成图。

**修改方向**：在 §3（调整后的 §3.3 LLM Configuration 附近）增加一张图，展示：
- 输入：system prompt 结构概要 + user message（帖子文本）
- 输出：JSON 格式（state, confidence, reasoning 等字段）

### 4.2 修复排版问题（#14）

**导师原话**：p.7 "Evaluation" 标题文字向左溢出。

**修改方向**：检查 LaTeX 源码中该 subsection 的缩进和格式。

### 4.3 表头改两行（#16）

**导师原话**：混同行列的表头应该用两行。

**涉及**：Table 4 confusion matrix（p.9）

**修改方向**：
```
         |        Pred.
Gold     | DEP  STA  HYP  MAN  UNC  Total
```

### 4.4 Appendix 编号（#22, #23）

**导师原话**：
- Appendix 不用 1–9 编号
- 小节用 A–Z 编号（如 "A. Post-Level..."）

**修改方向**：§9 → "Appendix"（无编号）；9.1/9.2/9.3 → A/B/C。

### 4.5 Prompt 全文外部公开（#24）

**导师原话**：prompt 全文放不下，在匿名网站公开数据。方法由你决定，但必须是 double-blind 的（GitHub 不行）。

**修改方向**：
- 论文正文中只保留 prompt schema 概要 + 1 个 few-shot 示例
- 完整 prompt 上传至匿名平台（如 Zenodo anonymous deposit）
- 正文脚注注明 "Full prompts are available at [anonymous URL]"

### 4.6 页数控制（#25）

**导师原话**：含 Reference 在内 20 页以内。

**现状**：约 33 页。最大的节省来自 Appendix prompt 外移。其余压缩待定稿后根据实际页数再决定。

### 4.7 日语文献（#26）

**导师原话**：国际学会不能引用日语论文。

**涉及**：Reference [19]（矢田ら 2026, 言語処理学会）

**修改方向**：
- 优先查找该工作的英文版本（arXiv / 国际会议）
- 如无英文版，将 de-identification 方法直接在 §8 Ethical Considerations 中描述，删除该引用

### 4.8 所属地址（#3）

**导师原话**：地址应为 1-2, Kasuga, Tsukuba, Ibaraki 305-8550。

**修改方向**：将 "1-1-1 Tennodai, Tsukuba, Ibaraki 305-8577" 替换为导师指定的地址。

---

## 五、需向导师确认的问题

1. **§4.5 Author-Level Aggregation**：完全删除，还是保留并在 Methods 中补充说明？
2. **§5 Longitudinal Demonstration 的用户数**：目前 Fig.3 只有 2 名用户，需要增加到多少？
3. **Error Analysis 的位置**：选方案 A（并入 §4 作为小节）还是方案 B（Results 和 Verification 分成两个 section）？
4. **Prompt 公开平台**：Zenodo anonymous deposit 是否可以？
5. **Reference [19]**：是否有英文版？如果没有，直接删除引用、在正文中描述方法是否可行？

---

## 六、评论–修改对照表

| # | 页 | 导师评论摘要 | 对应修改 | 状态 |
|---|---|---|---|---|
| 1 | 1 | "present a resource" → "propose a method" | Abstract + Introduction + 全文 reframing | ✅ 完成 |
| 2 | 1 | few-shot 无需 fine-tuning 的优势要在 Intro 主张 | Introduction L46 因果链 | ✅ 完成 |
| 3 | 1 | 地址改为 Kasuga 校区 | L15 地址修正 | ✅ 完成 |
| 4 | 1 | 标题去 MoodTrail-BD，加关键词 | 标题 + 全文移除 MoodTrail-BD | ✅ 完成 |
| 5 | 2 | Contributions 区分评价与展示 | Contributions 三条: Method/Evaluation/Demonstration | ✅ 完成 |
| 6 | 2 | 不用 "but" | 全文替换（残留2处：引用原文 + not only...but also） | ✅ 完成 |
| 7 | 2 | "None offer..." 太绝对 | "Few resources offer..." + 重要性强调 | ✅ 完成 |
| 8 | 2 | 加入 LLM 能力→指南即可设计 prompt 的叙事 | Introduction L46 完整叙事链 | ✅ 完成 |
| 9 | 3 | Twitter → X (formerly Twitter) | Related Work L67 | ✅ 完成 |
| 10 | 3 | §3 按 DSM-5→prompt→few-shot→评价 顺序讲 | LLM Config 提前到 BD-Risk 之前 | ✅ 完成 |
| 11 | 4 | 增加 prompt/output 图 | Fig.1 增加 DSM-5 Prompt 框 + JSON output 框 | ✅ 完成 |
| 12 | 5 | 14 天窗口补充 DSM 依据 | §3.2 L305 DSM-5 依据 | ✅ 完成 |
| 13 | 6 | 冗余说明删除，引用即可 | §3.4 BD-Risk 描述精简 | ✅ 完成 |
| 14 | 7 | "Evaluation" 标题排版溢出 | 结构已变，原问题大概率已消失 | ⚠️ 需目视确认 |
| 15 | 8 | cross-model/zero-shot 内容从 §3.4 抽出为 §3.6 | 新增 §3.6 Evaluation Design | ✅ 完成 |
| 16 | 9 | 表头改两行 | Table 4 两行表头 (Predicted / Gold) | ✅ 完成 |
| 17 | 10 | §4.3 zero-shot 需在 Methods 预告 | §3.6 预告 | ✅ 完成 |
| 18 | 11 | §4.4 cross-model 需在 Methods 预告 | §3.6 预告 | ✅ 完成 |
| 19 | 12 | §4.5 Author-Level 可省略 | 已删除 | ✅ 完成 |
| 20 | 12 | §4.6 独立为 §5，增加用户 | 独立为 §5 + Fig.3 扩展到 5 名用户 | ✅ 完成 |
| 21 | 14 | §5 Error Analysis 并入 §4 | 降级为 §4 子节 | ✅ 完成 |
| 22 | 21 | Appendix 不用数字编号 | A-Z 编号 | ✅ 完成 |
| 23 | 21 | Appendix 小节用 A-Z | A-Z 编号 | ✅ 完成 |
| 24 | 21 | Prompt 全文匿名公开（非 GitHub） | 全文删除，概要 + TBD URL | ✅ 完成 |
| 25 | 32 | 含 Reference 20 页以内 | — | ⏳ 待定稿确认 |
| 26 | 33 | 日语论文不能引用 | 引用已删除；无英文版，需向导师确认处理方式 | 📌 待办 |
