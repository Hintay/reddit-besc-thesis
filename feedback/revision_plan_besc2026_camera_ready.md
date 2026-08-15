# BESC 2026 Camera-Ready 修改计划（基于 CMT 审稿意见）

- 论文: Few-Shot Prompt-Based Longitudinal Mood-State Analysis of Bipolar Disorder on Social Media (Paper ID 96)
- 结果: **Full Paper 录用**（20/76 = 26.3%）。评分: R1 Accept(信心低) / R2 Weak Accept(中) / R3 Weak Accept(高) / R4 Weak Reject(高)
- Camera-ready 截止: **2026-08-15 (AOE, firm)**；注册截止 8/25
- 约束: Main Track 上限 **20 页**（含参考文献）。**当前状态（8/5 两系统完全合并后）：22 页、8 表**——审稿对应阶段（8/7–8/9）需在完整底本上有意识地删回 20 页。

---

## 0. 审稿意见甄别（已对照 6/14 提交版 PDF 逐条核实）

> 核实依据: `thesis/archive/Submission_files_...pdf`（审稿人所见版本）全文提取 + git 谱系分析 + 三版本（提交版 / camera-ready LaTeX / 远程最新 Typst）交叉比对。

### 0.1 提交版事实：交叉模型评估未包含在提交版中

**提交版只含 GPT-5.5 单模型探针**（run-in 小节 "Cross-Model Annotation Feasibility"）。穷举检索确认：Flash / Claude / Opus / DeepSeek / GLM / "five providers" / 0.564 / 0.432 在提交版中零命中；提交版 Conclusion 甚至把 "cross-model probes" 明确列为未来工作。

原因（git 谱系）：5 模型评估于 6/1 提交至**本地分支**（`be98a6a`，从未 push）；6/14 的投稿 PDF 由**远程分支**（另一台机器，不含该 commit）产出。因此：

| 意见 | 出处 | 判定 |
|---|---|---|
| "Limited cross-model comparison...only GPT-5.5 probe" | R1-W2 | **对提交版是正当批评，非漏读**。camera-ready（含 5 家 6 模型评估 + Table 5）已自然回应 |
| "unclear why GPT-5.5, not others; diverse alternatives could be evaluated" | R2-W4 | 同上——提交版确实只测了 GPT-5.5 一家替代 provider |
| "reproducibility across other LLM providers considering safety policies?" | R3-W5 | 提交版仅有 GPT-5.5 拒答分析（单一 provider，不足以回答复数 provider 的问题）；camera-ready 的 5 模型评估才是完整回答 |

→ 三条意见**无需新实验**（camera-ready 已含），但定性是"投稿后改稿已覆盖"，不是"审稿人漏读"。

**A8（保留，动机改写）**：当前 LaTeX 摘要确实未提跨模型结果（仅贡献 2 有）。在摘要补一句 "schema portability confirmed across five additional LLMs (macro F1 0.432–0.564)"——动机是**把投稿后新增的重要结果反映进摘要**。约 +2 行，需页数对冲。

### 0.2 妥当性低 / 定型化指摘（低成本回应）

| 意见 | 判定 | 回应 |
|---|---|---|
| R3-W2: 缺少与 instruction-tuned LLM、RAG 提示法的比较 | 部分不成立：camera-ready 对比的 6 个模型全部是 instruction-tuned（提交版仅 2 个）；RAG 对无检索语料的标注任务不适用 | 不加实验。一句话界定范围 → **A13** |
| R3-D: 缺少 "Ablation Study" 章节 | 部分不成立：zero-shot vs full schema 就是 schema 整体消融（提交版 Table 5 / LaTeX Table 4） | 在正文明示该比较的 ablation 定位，不新设章节 → **A12** |
| R3-D: "organization requires improvement / logical progression weak" | **有具体依据的可能性**：提交版存在 5 处指向不存在编号的断链引用 "Section 4.7.4"（4.7 下的 run-in 小节不编号）+ 1 处空引用 "(Section )"。LaTeX 版已改用 \ref 修复 | → 新增 A11：付印前全文交叉引用检查 |

### 0.3 准确且重要（R4 为主，优先处理）

R4 是唯一 Weak Reject，也是唯一做了实际数字核算的审稿人（16.1% = 2,476/15,423、43.2% = 775/1,794，均从提交版 Table 6/7 精确复算成立），其指摘基本全部成立，是修改主轴。**注意 R4 在 Strengths 中点名称赞了提交版 Table 3 混淆矩阵**（"provides the complete confusion matrix rather than reporting only an aggregate score"）——该表在当前 LaTeX 中已被删（见 §0.4/A9）。

### 0.4 论文源分叉的经纬与统合（8/5 已完全合并）

**分叉经纬**（组会说明用）：6/1 讨论后的改稿（5 模型交叉评估 + 20 页压缩）在 **Mac** 上完成但**忘记 push**；其后 **Windows** 上基于旧底本做了渡邊先生 17 条意见的对应并于 6/14 投稿。结果：**审稿人评审的提交版不含交叉模型评估**（R1/R2/R3 的该项指摘因此是正当批评），而 Mac 的 20 页压缩又删掉了提交版里审稿人看到并称赞的内容（混淆矩阵等）——两边各缺对方的一部分。

两条谱系（**8/5 已按并集完全合并到 LaTeX**，commit `3408195`）：

| 谱系 | 内容 | 状态 |
|---|---|---|
| **本地**（camera-ready LaTeX 之源）| 5 模型交叉评估、20 页压缩（6/1）、两作者（Lin, Yada）| 本机，`be98a6a`+`843a93d` 未 push |
| **远程**（提交版直系）| 提交版全部内容 + 今日新增：blind-review 开关、llncs 版面对齐、**三作者（Lin, Watanabe, Yada）** | origin/main，今日 02:10 push |

**已恢复的提交版内容**（6/1 压缩时被删，8/5 合并时全部恢复完毕）：

1. ✅ **Table 3 混淆矩阵**（R4 点名称赞）→ 已恢复（A9 完成）
2. ✅ **Table 8 帖子/评论分布原始计数**（R4 的 16.1% 由此算出；B2 的衔接基础）→ 已恢复（A10 完成）
3. ✅ GPT-5.5 细节：reasoning_effort="high"、Gemini 同 42 帖对照 0.649、Manic recall 2/4 vs 1/4
4. ✅ §5 末尾轨迹解读段（User B/D 个案）——恢复时已按 R4 要求以 "unvalidated hypotheses" 措辞重写（A3 的该部分同步完成）
5. ✅ NO_TREND 的 DSM-5 病程时长论证（躁≥1周、轻躁≥4天、重郁≥2周）
6. ✅ §4.1/§4.7 小节标题、§4.2 术语定义段、zero-shot "Three observations" 完整解读、ModernBERT low-resource 论证、Limitations/Ethics/Appendix 完整版、全部图表 caption 完整版

**作者名单**：远程版三作者含 Koichiro Watanabe（渡邊先生回复文档明确记载"共著者として追加、ORCID 0000-0002-3543-2159 登録済み"，顺序 Lin → Watanabe → Yada）。**LaTeX 作者块与版权表已更新为三人（8/5）**；提交前请与 CMT 登记名单最终核对一次（录用后不得变更）。

**合并策略（8/5 已确定并部分执行）**：以 camera-ready LaTeX 为唯一主线，Windows 谱系独有内容并入 LaTeX；Typst 两线的 git 合并**不做文本合并**，推迟至 8/15 后以最终 camera-ready 内容为准回灌。已执行（8/5）：渡邊采纳项全部 port（Although 句、去斜杠、Intro per-user 句、Related Work 两句总起、§3.1 导入句、"is designed to address"、去强调斜体、§5 结尾段含 R4 要求的 unvalidated hypotheses 措辞）+ 三作者 + 图1 渡邊认可版重导出（SVG/PDF）+ 版权表三作者。编译后仍 20 页、零溢出。待执行：A9 混淆矩阵恢复、A10 计数恢复（8/7，与页数统筹绑定）。git 保全：本地 commit 建议 push 到备份分支（命令见下），未经确认不执行：

```bash
cd /Volumes/Working/Git/RedditBipolarDetection/thesis && git add bd-risk.typ bd-risk.zh.typ fig_timeline.svg && git commit -m "wip: local polish before lineage merge" && git push https://github.com/Hintay/reddit-besc-thesis.git main:mac-crossmodel-backup
```

---

## 1. A 类：正文修正（必做）

| # | 指摘 | 修改位置与内容 |
|---|---|---|
| A1 | R4-W4: "no labeled data" 说法误导——schema 在 314 条带标签开发集上迭代 | ① Contributions 第 1 条 "requiring no fine-tuning or labeled training data" 加限定：标注时仅用 8 条合成示例，schema 开发用了 314 条开发集做错误分析；② §4.6 末句 "...no manual labeling" 补 "at annotation time; schema development drew on the 314-post development subset" |
| A2 | R4-D3: BD-Risk 标签地位被夸大。**已对照原文核实（8/5，原文 §3.2/§3.3/Table 3）**：全部 7,346 条标签由 3 名研究者标注（精神科医生指导、冲突时按医生意见裁决）；专家（精神科医生 E1 + 临床心理学家 E2）仅验证随机 **150 条（来自 120 名用户，占 2.0%）** | ① Related Work "validated by a psychiatrist and a clinical psychologist" → "annotated by trained researchers under psychiatric guidance, with a psychiatrist and a clinical psychologist validating a random 150-post subset"；② "expert-labeled"（Contributions 贡献2、Limitations）→ "expert-validated"/"psychiatrist-guided"；③ Limitations 补一句：无法确认 145 条评估集与专家验证子集的重叠；④ **新增（核实中发现）**：我们 Limitations 写的 "inter-expert Krippendorff's α = 0.87" 不精确——原文 Table 3 的 α=0.87 是 E1+E2+标注者三方在 150 条上的整体一致性（严格的专家间一致性是 Cohen's κ(E1,E2)=0.69）→ 改为 "agreement among the two experts and the annotators on a 150-post validation subset (Krippendorff's α = 0.87)" |
| A3 | R1-D2 & R4-D1: period 级分析定位为 exploratory | §5 首段、Discussion、Conclusion 加 exploratory 限定。现存目标句（已核实）：§3.2 "allows observation of manic-episode onset and progression"、Fig.3 caption "frequent manic transitions / rapid cycling"、Discussion 观察(1) "mark episode onset" 与(2) "rapid cycling" → 改为 "unvalidated hypotheses" 措辞；恢复 §5 个案解读段时同步执行（见 0.4-4） |
| A4 | ✅ **已完成（8/5）**：R1-D4 Gemini 引用过时。Google 未给 3.1 Pro 发论文，核实后改引**官方 Model Card**（DeepMind, 2026-02-19 发布, deepmind.google/models/model-cards/gemini-3-1-pro/），§4.4 引用已替换、2024 家族报告自动移出文献表，编译验证通过 | — |
| A5 | R1-D3: "broadly consistent with clinical expectations" 需引用 | **大部分已完成**：LaTeX Discussion 已写 "broadly match long-term BD cohort studies \cite{grande2016bipolar}"。剩余：核对摘要中该措辞（摘要惯例不带引用，可保留或微调） |
| A6 | R4-D2: period prompt 输入与 dominant state 操作化未说明（两版均缺，已核实） | §3.2 Period-Level Trend Analysis 补一句：period prompt 接收窗口内**原始帖子文本**（不含 post 级预测），dominant state 由 LLM 按提示规则跨帖聚合判断（非多数投票） |
| A7 | R4-D2: 1,794 之外无 NO_DATA 计数（两版均缺，已核实） | §5 补报：总窗口数（含 NO_DATA）、非空窗口 1,794、每窗口帖数分布。从 DB/pipeline 统计，无 API 成本 |
| A8 | 摘要未反映跨模型结果（已核实成立） | 摘要补一句 portability 结果（macro F1 0.432–0.564）。动机=反映投稿后新增的主要结果 |
| **A9** | ✅ **已完成（8/5 合并时）**：混淆矩阵表恢复（现 Table 3，含 "plus the confusion matrix" 回填） | — |
| **A10** | ✅ **已完成（8/5 合并时）**：帖子/评论原始计数表恢复（现 Table 8） | — |
| **A11** | 交叉引用完整性（提交版有 5 处 "Section 4.7.4" 断链 + 1 处空引用，或为 R3 结构批评的来源） | camera-ready 付印前全文 \ref/\label 检查（LaTeX 已修复大部分，需最终确认） |
| **A12** | R3-D: 缺 "Ablation Study" 章节（§0.2 的对应工作项化） | 在 zero-shot 比较小节明示一句该比较即 full schema 的 ablation（如 "This comparison constitutes an ablation of the full schema."），不新设章节 |
| **A13** | R3-W2: 缺与 RAG 等提示法的比较（§0.2 的对应工作项化，**任意**） | Related Work 或 Discussion 加一句界定：RAG 以检索语料为前提，对本标注任务不适用；六个对比模型均为 instruction-tuned |

## 2. B 类：追加分析（无新 API 调用，2–3 天）

| # | 指摘 | 工作内容 | 产出 |
|---|---|---|---|
| B1 | R2-D3 & R4-W3: 报告 CI，尤其 Manic n=15 | 145 条 held-out 预测 bootstrap（1000 次），各类 P/R/F1 与 macro F1 的 95% CI | Table 2 加 CI 或表注；Limitations 的 "±approximately 13pp" 替换为正式 CI |
| B2 | R4-D2: 16.1%→43.2% 转换需 contingency 分析 | 现有 post 级 × period 级标注交叉表：dominant state × 窗口内 post 状态构成（与 A10 的计数衔接） | §5 或 §6 一小段 + 可选小表 |
| B3 | R2-D2: patient verification 无验证（**组会决策**） | 115 名中分层抽 30 名，人工核对 LLM 证据 | §3.1 或 Limitations 一句抽查精度；约半天人工 |
| B4 | R3-W4: few-shot 数量依据/消融（可选） | 低成本：补一句"8 条由错误分类学 A–H 导出，非调参"；实验则 {0,4,8}×145 条（0 档已有） | 一句话；实验可选 |

**页数削减（22 → 20 页，8/7–8/9 与 A/B 类同步执行）**：合并后为 22 页完整底本，删减在其上有意识进行（每一刀知道删的是什么）。**保持不动**：混淆矩阵（R4 称赞）、GPT-5.5 段（R1 关注点、已含恢复细节）、交叉模型表。**削减候选**（按优先序）：① error analysis 六个 pattern 的 synthetic case 描述精简（约 0.5 页）；② Ethics 第二三段压缩（PII 例示保留类别名、细节移注）；③ Related Work 收敛；④ 表格紧凑化（混淆矩阵与 Table 2 并排、字号下调）；⑤ Limitations 连接语精简。加上 A8+B1+B2 的少量增量，目标净删 2+ 页，逐项试排版。

## 3. C 类：不可行于 camera-ready → 修论/期刊版对应

| # | 指摘 | 理由 | 后续安排 |
|---|---|---|---|
| C1 | R1/R2/R4 共同最大诉求: period 级专家验证（R4-D1 给出完整设计：分层抽样 × 多标注者 × agreement + model-vs-consensus + change point 容差指标） | 8/15 前无法完成 | **与进行中的医師 Argilla 标注对接**（设计高度一致）。修论/期刊版按 R4-D1 指标报告；camera-ready 在 Limitations 是否写 "underway" 待组会确认 |
| C2 | R3-W3 & R4-D2: 窗口长度/锚点敏感性 | 需全量重新标注 | Future work 明记；恢复 NO_TREND 的 DSM-5 时长论证（0.4-5）强化 14 天依据 |
| C3 | R4-D3: 在原始 7 点序数任务上评估 | 任务定义不同 | Future work |
| C4 | R3-W1: 跨数据集/语言/领域泛化 | 无第二个可用 BD 语料 | Limitations 微调措辞 |

## 4. 时间线（今天 8/5）

> ⚠️ **日程约束（8/5 核实）**：筑波大学 2026 夏季休業 = 8/8–9/30（春学期课程 8/6 结束、8/7 预备日）；**一斉休業（全校停摆，お盆）= 8/10（月）–8/14（金）**，部分单位延至 8/15。共著者确认必须赶在 8/7（金）前送达；休業周只能在 Slack 上"期限内无异议即提交"。校内打印/扫描设备休業周不可用 → 版权表签名扫描提前到 8/6–8/7 完成。

| 日期 | 内容 |
|---|---|
| 8/5 周三（今天） | 组会 → 说明统合结果；**当天定死全部方针**（20 页删减、B3、B4、C1 写法）；作者名单与 CMT 照合 |
| 8/6–8/7 周四–周五 | A 类文字修改 + 22→20 页调整主体；**版权表打印→手写签名→扫描（趁校园设施可用）**；**8/7 傍晚前把改稿版发给共著者**，注明"8/12（水）前如有意见请在 Slack 指出，无意见则 8/14 提交" |
| 8/8–8/12 周六–周三 | 本人作业（不依赖他人）：B1 bootstrap CI、B2 contingency、A7 统计、（若做）B3 抽查、全文校对与 A11 引用检查 ※8/10–14 一斉休業 |
| 8/13 周四 | 反映共著者 Slack 意见（如有）、最终化 |
| 8/14 周五 | 打包（PDF + 签名版权表 + source/）上传 CMT（线上操作，不受休業影响） |
| 8/15 周六 (AOE) | 截止（留一天余量） |

## 5. 组会需要决策的点

1. **20 页删减方针**：合并后 22 页，删减候选清单（§2 末尾）是否认可；混淆矩阵/GPT-5.5 段/交叉模型表保持不动
2. **C1 写法**：Limitations 里能否写医師标注 "underway"
3. **B3**：patient verification 人工抽查是否纳入（约半天）
4. **B4**：few-shot 数量消融做不做实验
5. （基本解决，最终照合）**作者名单**：已按渡邊先生回复文档统一为三人（Lin → Watanabe → Yada，LaTeX + 版权表均已更新）；提交前与 CMT 登记做最终核对
6. （已解决）标题连字符：论文四版一致为 "Mood-State"（提交版 PDF 的换行断字是排版产物）；仅 CMT 元数据为 "Mood State"，提交时顺手更新元数据即可
7. （已执行）谱系合并：8/5 已按并集合并到 LaTeX（commit `3408195`，备份分支 `mac-crossmodel-backup`）；Typst 侧 8/15 后回灌

---

## 0.5 文言基准方针（2026-08-09 确定）

**规则：除以下四类外，本文一律以投稿版（6/14）文言为准**：①查读意见对应（跨模型一式等）②矢田/渡邊要求 ③数值・事实修正 ④出版要件（匿名解除・Disclosure・引用修复）。

依据（git 考证）：与投稿版的文体差异几乎全部来自 Mac 系未经确认的改稿——`843a93d`(6/1 压缩润色)、`be98a6a`(6/1 数据修正+跨模型)、`7fc98df`(6月未提交润色)。其中**关键发现**：6/11 草稿上矢田先生 6/13 批注明确要求 patient verification 段落**从 Methodology 移到 §5**（「BD-Riskでも同じ処理をしているのかと読者が混乱」「必須の前処理のように読まれる」）；Windows 侧照办后投稿，而合并时 Mac 血统把它放回了 §3.1。已全部回退（verification 归位 §5、§3.1 flow 句/restructure 句删除）。

已回退（38 处）：§2.1 压缩改写、§2.3 结尾、贡献3措辞、§3.1 重构一式、§3.2 data-use agreement→sensitive 改写、never-drawn 删除、recruits→selects（3处）、temperature 依据句、§4.5 caption→本文移动、§4.6 20-epoch 数字、§5 行内百分比+导航句、Discussion 措辞（meaningful/trend distributions句）、结论简化句、Ethics 微调（6处）、taxonomy 指针句、Lee et al. prose cite。CMT 无人问 temperature/epoch，故回退。

保留（带红标）：跨模型全部内容（贡献2/§4.3/§4.7.3/Table 6/Discussion 证据段/Limitations/结论(3)）、R4 hedging（unvalidated hypotheses・pattern consistent with）、数值修正（88.9→89.0×2、depressive-or-neutral→depressive-pole、9.1→8.9）、匿名解除、Model Card 引用、"(see the Appendix)" 断引用修复、**Pattern 1–6 散文化（用户指示保留）**。

注意：将来 22→20 页压缩时**不得复活上述已回退的 Mac 压缩措辞**（导师未确认）；删减内容一律用 \del 标注由共著者过目。

---

## 0.6 CMT 对照评审执行清单（2026-08-09 多代理评审产出）

45 点评估：addressed 11 / partial 17 / not-addressed 10 / no-action 7。**预算实测**（tectonic clean build）：全部 must+should 逐字应用后仍 22 页（净 +0.28 页）——逐条 "net 0 with named cut" 记账系双重支出，已废除；改用下方全局删减表。页数核对只看 clean build（\del 在 tracking 版仍占版面）。

### 必改（must，合并后 12 项）
1. **R1-6 exploratory 声明**：§5 开头 "yielding 1,794 valid analysis periods." 后加 `\rev{Because no period-level expert ground truth exists, the analysis in this section is exploratory.}`；Discussion "four \rev{exploratory} observations"。（插入顺序：先 R4-10 统计句、后本句）
2. **R1-7 引用补充**：Discussion "clinical expectations for BD-related online discussion" 后 `\rev{~\cite{apa2013dsm5,grande2016bipolar}}`（零文献增长）。
3. **R2-10/R2-4 bootstrap CI（B1）**：1,000 重采样；Table 2 caption 加 macro/Manic F1 的 95% CI；Limitations `\del{$\pm$ approximately 13 percentage points}\rev{bootstrap 95% CI [L,U]}`。
4. **R4-5 断言对冲**：×2 "trends \rev{may} mark episode onset"；Fig.3 caption `\del{rapid cycling}\rev{a pattern consistent with rapid cycling}`。
5. **R4-9 no-labeled-data 限定（A1）**：4 处统一 "\rev{ at annotation time}"（Contribution 1、§4.6 末、Table 4 caption、**Intro "without task-specific fine-tuning or labeled training data" 处**——漏一处即自相矛盾）；§4.6 补 schema 开发用了 314 条 dev 子集；同时修订与 ModernBERT 的成本对比措辞（R4 弱点 4 后半句）。
6. **R4-10 NO_DATA 统计（A7）**：从 DB 按最终 105 人 cohort 算总窗口数 T、NO_DATA=T−1794、非空窗每窗帖数中位数/IQR；用语 "posts (submissions and comments)"；先断言 T−1794 与 DB 的 NO_DATA 计数一致再合入。
7. **R4-11 period prompt 输入说明（A6）**："the LLM analyzes the collected posts \rev{(the raw submission and comment texts in the window; post-level predictions are not provided)}"；dominant state "aggregated \rev{by holistic judgment under the schema rules rather than by majority voting over post-level labels}"。
8. **R4-12 post→period 对照（B2）**：先算 dominant-state×窗内标签组成交叉表，**据实**写 2-3 句入 Discussion 不对称段（16.1%→43.2% 的机制）；最大增量（~4.5 行），超页时降为单句。
9. **R4-14 BD-Risk 标签地位（A2）**：§2.2 `\del{validated by a psychiatrist and a clinical psychologist}\rev{assigned by trained researchers under psychiatric guidance, with a psychiatrist and a clinical psychologist validating a random 150-post subset}`；expert-labeled→expert-validated 等 4 处＋**Related Work 末段 "against \rev{psychiatrist-guided} labels" 补漏**；α=0.87 改为三方一致性表述（κ=0.69 数字合入前须对照 Lee et al. 原文核实，核实不了只留定性）。
10. **R4-15 重叠不可知句**：Limitations gold-state 段加 "150 expert-validated posts (2.0% of the dataset) 与 145 held-out 是否重叠 cannot be established"（"from 120 users" 须核实后才写）。
11. **R3-9/A11 付印检查**：clean build 全文 \ref/\label 无 "??"、实验均在 §4.3 先声明（0 行）。
12. **R4-2 保护清单**：混同行列（Table 3）、双 accuracy、author-disjoint 记述、DSM-5 窗口论证（×2）、research-gap 论述、GPT-5.5 拒答分析、Table 6 不得删。

### 建议（should）
- **R1-2 删 Pattern 1–6 Synthetic case 句**：实测省 **0.70 页**（最大单项）；须同步改 §3.2 "illustrates each pattern with a synthetic case" 承诺句，或保留 Pattern 1（主导错误）与 3（安全关键）的单句缩写版。
- **R3-4 跨域限制句**（英语/Reddit/DSM-5 之外需再验证）＋ **R3-6 窗口敏感性句**（7/30 天、锚点；同句覆盖 R4-D2，R4-13 撤回）＋ **R3-7 八例确定方式句**（failure-mode coverage 而非调参，未做数目消融）＋ **R3-10 zero-shot=整体消融定位句**——均入 Limitations/对应节，各 +1~2 行。
- **R2-9 患者验证抽查（B3，决策项）**：批准且 8/12 前完成 30 人复核→§5 加结果句；否则自动改走 R2-5 后备句（Limitations "tier assignments have not been audited against manual review"）。两者互斥。
- **underway 从句三合一**：R1-4/R2-6/R4-4 同句重复，只执行 R4-4 措辞一次（以 C1 批准为前提；未批准则全部不写）。

### optional（末次 clean build ≤20 页且有余量才逐条放行）
- A8 摘要跨模型句——审计纠错：不得写 "five additional LLMs without refusals"（零拒答的含主注释器；额外模型零拒答仅 4 个），改 "\rev{The schema transfers without refusals to four additional LLMs from four providers.}"；R3-5 "compared \rev{LLMs}"；R4-17；R1-5b。

### 删减候选（凑齐 ~1.4 页；全部打 \del）
| 候选 | 省 | 风险 |
|---|---|---|
| Synthetic case ×6 全删 | 0.70 页 | 改 §3.2 承诺句；R1 表扬的 pattern→rule 链接句逐条保留 |
| 删 Fig.1 pipeline | 0.25 页 | 无审稿人点名；文字描述已完整 |
| Related Work 压缩 ~40% | 0.35–0.4 页 | 保 BD-Risk 定位句＋gilardi 论证链 |
| Intro 数字复述＋4.7.2/4.6 压缩＋absence-modeling 尾句 | 0.35–0.4 页 | 表格与核心结论不动 |
| Ethics ¶2–3 压缩 | 0.2 页 | 已被 must 项记账 ~10 行，净余额趋零 |
| Fig.2 缩至 0.7\textwidth 或删 | 0.13 页 | 表扬的是文字论证非图 |

回复信用语：跨模型问题一律 "the camera-ready incorporates the full cross-model evaluation"（不称审稿人漏读）。

### 0.7 组会/导师决定（2026-08-09 记录）
- **Synthetic case ×6 保留**（删减候选 1 作废）；**Fig.1 pipeline 保留**（候选作废）
- **B3 患者验证抽查：不做**（导师指示）；R2-5 后备句也不加（现有 Limitations 的 "does not constitute clinical confirmation" 已覆盖，且不新增暴露面）
- **C1 "医師アノテーション進行中" 不写**（导师指示：不暴露进行中的研究状态）→ R1-4/R2-6/R4-4 的 underway 从句全部不执行；Conclusion 的 future work 表述（投稿版原文）维持即可
- 删减账本重排：可用候选剩 Related Work ~0.4 + Intro 复述/4.7.2/4.6/absence 尾句 ~0.4 + Fig.2 缩小 0.13 + Pattern 正文冗余从句（不碰 synthetic case 与链接句）~0.15 + Ethics 净余 ~0.1 ≈ **~1.2 页**；must 项净增约 +0.4 页（B3/C1 取消后）→ 距 −1.4 页目标缺口 **~0.6 页**，执行时边做边实测，不足部分再议

### 0.8 必改执行完了（2026-08-09）
§0.6 must 全 12 项已应用（含数据计算，全部通过自洽验证后合入）：
- **B1 bootstrap**（复现 Table 2 全数值后重采样 1,000 次, seed 42）：macro F1 [0.430, 0.610]、Manic F1 [0.000, 0.348]、Depressive [0.641, 0.810]、Stable [0.588, 0.818]、Hypomanic [0.296, 0.681] → Table 2 注＋Limitations 替换旧 "±13pp"
- **A7 NO_DATA**（快照重建：improved_v2 且作者≥2 窗口 = 精确 105 人/1,794 窗）：总网格 **4,091** 窗、NO_DATA **2,297**（56.1%）、非空窗中位 3 帖（IQR 1–9）→ §5
- **B2 交叉表**（16.1%=2,475/15,410、775=564/157/54 复现）：**93.8%** 的极性支配窗口含 ≥1 同极 post 标签、中位 5 帖 → Discussion 不对称段
- **A2**：α=0.87 三方表述＋κ(E1,E2)=0.69（原文 Table 3 核实）＋150/120 users/2.0% 核实；expert-labeled→expert-validated 等 4 处
- A1（at annotation time ×4＋314 dev 子集句）、A6（raw texts/holistic judgment）、R4-15 重叠句、R1-6 exploratory ×2、R1-7 引用、R4-5 hedge ×3、A11 检查（clean build 无 "??"）完了
**页数**：clean build 22 页・末页 90% 満 → 缩减讨论需净删 **~1.9 页**（must 项净增 ~0.5 页）。should 项（R3-4/6/7/10 等）与删减一并待议。

### 0.9 should 4 项完了（2026-08-09）
R3-4（跨域限制）＋R3-6（窗口/锚点敏感性、兼答 R4-D2）→ Limitations 评价范围段；R3-7（八例=错误模式覆盖、未做数目消融）→ §3.3；R3-10（zero-shot=schema 整体消融）→ §4.7.2。全部 \rev 标注。
**页数**：clean 22 页・末页已满 → 压缩任务 **~2.0 页**。剩余：压缩讨论、optional 项（A8 摘要句等）、共著者送付、版权表、CMT 题目、提出打包。

### 0.10 Tier A 压缩（2026-08-09 执行）
**A2（Discussion 的 NO_DATA absence-modeling 展望句）＝导师点名保留 → 加入保护清单，永久排除**。
执行：A1 Intro 数字复述删除、A3 Limitations 三处（数据获取括注、第二个 e.g.、release-time 段的 Table 2 数字复读）、A4 表注三处（Table 1 第二句、Table 7 趋势词汇表、Table 8 解读句）、A5 Appendix 规则名枚举。全部 \del 标注。

### 0.11 Cross-Model 压缩（2026-08-09 执行）
8 处：§4.7.3 引入段压缩（设计复述→指向 §4.3）、观察段去框架句＋二三点合并、Flash 段删表值复读与结论重复、GPT-5.5 段删拒答原文引用/42 帖逐类分解/(2/4 vs 1/4)（此三处 \del）、§4.3 bullet 删 per-model 从句、结论(3) 删 0.564 复读。实测省 ~0.21 页。**累计余量：clean 末页 402pt/622pt ≈ 内容 21.65 页当量 → 缺口 ~1.65 页**。

### 0.12 Tier B 执行（2026-08-09）
35 处编辑全部应用（Fig.2 按本人指示保留）：B1 Related Work（含 2.2 段落统合＋孤儿引用 torous2016new/chancellor2020methods 退出文献表）、B3 Table 5 瘦身 8→4 行（条件宏、Manic F1 数值并入 B6 新句、Pattern 4 交叉引用配套删除）、B4 Pattern 修剪 18 刀（合成案例与规则名全部保留）、B5 Ethics ¶2–3、B6 §4.7.2 第三观察改写＋§4.6 结尾合并（顺带消除 "constructing 314 expert-labeled" 的措辞不一致）。
**实测：clean build 21 页・末页 270pt/622pt（43%）→ 内容 ~20.43 页当量、距 20 页缺口 ~0.43 页**。
剩余弹药：B1 扩展 (a) 0.578 括注 0.5 行 (b) 2.1 gap 句 1.5 行 (c) dechoudhury 退出文献表 2–3 行；Limitations 连接语 ~3 行；Intro 进一步；Tier C 措辞复用。

### 0.13 逐项删减→20 页达成（2026-08-09）
强候选 13 项（E1 Limitations 重复句、E2 §4.2 两句、E3 §3.2 change-point 句[truong 退出文献表]、E4 Intro 三处枚举＋schema 句、E5 Uncertain 枚举、E6 Appendix、E7 Discussion 括注、E8 0.578 括注＋2.1 gap 从句、E9 §4.3 尾）＋中候选 4 项（M1 §4.4 选型理由、M3 §5 静态快照对比、M2 §4.4 period 字段复述、M4 Limitations 开头枚举）逐项应用。
**最终：clean build = 20 页（末页 658/665pt 满）／tracking 23 页。全文无 ?? 引用。**
⚠️ 零余量：共著者若要求增补，需等量删减对冲。后备候选：§3.2 evidence-extraction 句 1.5 行、Fig.3 caption 期间数 0.5 行、Conclusion 开头数字复述 ~2 行、optional A8 摘要句（需先腾位）。

### 0.14 压缩负面影响审查＋修复（2026-08-09）
5 维度×18 代理对抗审查：确认 13 项（去重 4 组）＋低危 18 项，全部修复或有意接受：
- **高危（已修复）**：Limitations "five additional LLMs on the full holdout" 事实反转（压缩时把 GPT-5.5 算进了完成 holdout 的模型）→ 改 "four additional LLMs that completed...; the fifth, GPT-5.5, declined"；Contribution 2 的区间加 "for the four completing models" 限定
- **中危（已修复）**：Intro "The recall asymmetry" 悬空指代（补 antecedent 短语）；"( 89.0%" 括号内漏空格伪影 ×3（del/rev 接缝空格进入 clean build）
- **低危（已修复 8 项）**：Discussion "as does" 错误省略、"rather than from" 平行结构、"consistency issue" 术语、"in-text"→"in the text"、Pattern 1 悬空 "it"、"verbatim" 残留、§3.2/§4.5 两处 "expert labels" 与 A2 术语统一
- **有意接受（记录在案）**：Table 5 删行后 per-class 数值仅存于正文叙述（与"数值单处存放"原则一致，正文完整叙述了四类变化）；Pattern 6 空洞化（组会批准的全删）；del/rev 接缝的双空格 glue（不可见）；Pattern 开场 "is the LLM ignoring" 口语性（本人保留的散文化）
修复后 clean build 仍 20 页整、零 Overfull、无断引用（tracking 版 §4.5 一处 20pt Overfull 系 del+rev 并存所致，仅评审副本可见）。

### 0.15 LNCS 合规审计＋修复（2026-08-10）
llncsdoc/Springer 指南对照的 6 维度×11 代理审计：封面区・摘要 keywords・credits 位置・全 11 浮动体 caption 位置全部合格。确认 4 项（1 must＋3 should）：
- **已修复**：①Table 5 (tab:pilot-dists) 正文零引用（Springer §4.5 "cross referred in the text" 违反）→ §5 段落加 \rev{(Table~\ref{tab:pilot-dists})}；②§4.1 标题 "Against"→\del{Against}\rev{against}（全文唯一介词大写标题；heading 内需 \protect）。①的增行用后备候选 **Conclusion 开头数值复述**对冲（87.9%→high、6.7%→low、删 " at the manic pole"；数值在 Table 2/Discussion/Limitations 单处存放原则）→ clean 恢复 20 页。
- **DOI 补记（测试后保留）**：warner2025modernbert 加 doi=10.18653/v1/2025.acl-long.127＋pages=2526--2547（ACL Anthology 核实）→ 文献表 +1 行被末页 7pt 余量吸收，clean 仍 20 页、**末页 665/665pt 完全满**（此前 658pt）。cohan2018smhd（ACL Anthology 无 DOI）・hirschfeld2002guideline（Crossref 无注册）合规维持原样。bib 变更无法打红字 → 追踪版说明框补记一句。
- **未决（本人判断待ち）**：anonymous.4open.science URL（§Data Availability 唯一 URL、会过期）→ 需建正式公开仓库后替换。
- 被反驳 1 项（句首 Fig.→Figure 非 LNCS 规则）；info 6 项记录：stale .bbl（打包时必须用剥离版重新生成）、dechoudhury volume+number BibTeX 警告（number 反正被丢弃）、"(Section~3.2)" 外部论文指向、摘要内 \cite、\emergencystretch、\textbf 行首标签（后三者可接受）。
现状：tracking 24 页／clean **20 页整・零余量（665/665pt）**。任何后续增补必须等量对冲。

### 0.16 Appendix 规范调查＋credits 顺序修正（2026-08-10）
4 代理调查（SpringerLink 排版 PDF 3 篇目视核实・BESC 2025 全 111 篇扫描・arXiv llncs 预印本・Springer 官方文档）：
- **规则**（Instructions for Proceedings Authors, 2026-02 版 p.9）：Appendix 置于 References 前（放错会被排版商强制移动）、单个无编号 "Appendix"／多个 "Appendix 1/2"、须被正文引用、附录内图表公式延续正文编号。llncsdoc 完全未提附录；llncs.cls 的 \appendix 产生字母节（与规定不一致）→ 手写 \section*{Appendix} 是正解（现状已如此）。
- **Ack vs Appendix 顺序**：官方无明文，但指南自身版式＋3 篇 OA 排版 PDF＋BESC 2025 两篇附录论文（LNCS 16433 p.114 同页直证）全部为 credits → Appendix → References，零反例。**导师 "Appendixの前" 正确**，已将 credits 块移至 \section*{Appendix} 前（块内容全 \rev 红显，位置互换无需额外标注；tex 注释已记排序依据）。两版重编译零错误、页数不变（tracking 24／clean 20 页・665pt）。
- 附带警示：BESC 2025 有论文留下悬空 "Appendix G" 引用（删附录未删引用），Springer 排版未纠——后续删减需自查。Appendix 标题=独立节标题（"major heading"）、credits=9pt 行内标题，形式区分明确。

### 0.17 斜体/粗体一致性审计＋修复（2026-08-10）
4 维度×17 代理（确认 6→去重 5・反驳 7・info 5）。审计确立论文双层惯例：**独立标签引用=斜体（\emph{Manic} recall 等）、连字符复合词=正体（Manic-pole/Manic-to-Depressive/Manic-recall ceiling）**——多项"复合词应斜体"指控据此被反驳，Manic-recall ceiling（439/449）维持正体。已修复 5 处（样式变更用 \rev 红显、文字变更用 \del+\rev）：
1. Table 4 (tab:zeroshot) Accuracy 行胜者 65.9\% 补粗体（4 行中唯一漏粗的胜者；逐格核算确认）
2. L449 "Manic-F1"×2 → \emph{Manic} F1（与 Table 2 caption 同量同区间的写法矛盾）
3. L449 "the Manic-pole numbers" → 小写 manic-pole（全文唯一句中大写，同句自有小写形式）
4. L320 Severity Descriptors 唯一漏斜体处 → \emph
5. Table 3 caption 图例 DEP = \emph{Depressive} 等 5 词斜体（与 Table 5 caption 图例统一）＋ L200 excluding-\emph{Uncertain}
被反驳记录：Table 2 Precision 0.833 加粗非错误（加粗惯例=叙事强调而非逐列最大，Table 6 只粗 Macro F1 同理）；\emph{Clinical Guidance} 是 prompt 实际节名（batch.single.md 核实）合法。渲染层字体验证（pymupdf span font）全部通过。两版零错误、页数不变（tracking 24／clean 20 页・665pt）。

### 0.18 交叉引用语义审计＋修复（2026-08-10）
机械层: clean build 零 "??"、全 \ref 有 \label（孤儿 label 2 个: sec:resource/sec:metrics、無害）。语义层 4 维度×12 代理（确认 7・反驳 1・info 8）、8 处修复完了:
1. **L430 事实错误**: rapid cycling 误归 User D（caption 归 C; 投稿版由来）→ \del D 从句＋\rev "User~C shows a pattern consistent with rapid cycling"（后续 "cycling patterns" 枚举的锚点恢复）
2. **L320 最高级不成立**: "benefits the most (+0.116)" が次句の Manic +0.125 と矛盾 → "gains +0.116 in per-class F1"
3. **L346 数值不成立**: "(with Hypomanic recall varying the most)" — 実際は Manic の方が variance 大（range 0.200 vs 0.188）→ \rev 内から削除
4. L290 指向錯誤: label--text 主張の指針 (Sect.4.5, Pattern 1)→(Sect.5 Discussion)（Pattern 1 はモデル側要因で自己矛盾だった）
5. L123 全称承諾削減: "characterized there" \del（Improvement-Narrative/Severity Descriptors は §4.5 未特性化）
6. L161 "(full analysis in→see) Sect.4.5"（同上理由; L449 の "full analysis in Sect.5" は Discussion が実際に担うため維持）
7. L354 P6 held-out 承諾回復: "and appears effective on the held-out subset" を P6 に補充（圧縮の連帯傷; 長版は頁数超過のため証拠従句なし短版）
8. **摘要 L64**: "including"→"alongside"（label-text issue は六 pattern の一員ではなく Discussion 所在）
反駁 1（L362 +0.116 無来源説—指針は \del 内のみ・数値は L320 が担う）。info 記録: Table6 caption ref は sec:metrics がより正確（未変更）・Table7 "Posts" 列頭 vs 本文 "submissions"（数値は全て検算一致）・Fig1 の optionality 未描画。clean 20 頁復元（P6 句を一度長版で入れ 21 頁→証拠従句を削って 665pt 満杯で 20 頁）。tracking 24 頁・両版零 error。

### 0.19 渡邊さんコメント対応: "tabulated"（2026-08-10）
渡邊さん指摘「"All five tabulated models" の tabulated は普通は使わない」→ 2 箇所とも表への明示参照に置換（いずれも \rev 内・直接修正）:
- L346 "All five tabulated models" → "All five models in Table~\ref{tab:crossmodel}"（直前文の「4 追加 LLM＋本文報告の GPT-5.5」と区別する機能を明示参照で維持; Table 6 の 5 行=4 追加+主注釈器で GPT-5.5 含まず、の曖昧性回避に必要な反復）
- L439 "across the tabulated LLMs (Table~\ref{tab:crossmodel})" → "across the LLMs in Table~\ref{tab:crossmodel}"（括弧参照を本文に吸収、微短縮）
両版再構築: tracking 24 頁／clean 20 頁（665pt）・零 error・"tabulated" 全文 0 件。

### 0.20 コード公開＋匿名リンク差し替え（2026-08-15）
- 匿名鏡像の源 = Hintay/bd-state-annotation（私有）と特定 → README を camera-ready 仕様に更新（渡邊さん共著追加・"(Under review.)"→BESC 2026 acceptance＋BibTeX・"our submission"→accepted paper・no task-specific training data at inference time に整合・クロスモデル 5 LLM 列挙・render.py 補記・University of Tsukuba 明記・破折号 4 箇所除去・KAKENHI 謝辞追加）。履歴は単一中性コミット "docs: update README" に squash（本人指示）。
- 本人が公開化（personal 名義; 転移リダイレクトで後日 kalclab 移管も可逆と助言済み）→ 論文 Appendix の \url を anonymous.4open.science → https://github.com/Hintay/bd-state-annotation に差し替え（\del+\rev、新URL短縮で頁数影響なし）。**LNCS 監査の最終未決項クローズ**。
- 残: 倉庫 prompts は 5/28 版 — improved_v6 との整合確認は任意（時間があれば）。clean 20 頁（665pt）・tracking 24 頁・零 error。

### 0.21 label-text 表記統一（2026-08-15）
摘要点検の副産物: "label-text"（連字符・投稿版多数形 6 箇所、摘要含む）vs "label--text"（en-dash・4 箇所、うち 2 箇所は投稿版由来で投稿版自体が不統一）→ 連字符に統一。\rev 内 2 箇所（L320/L346）は直接修正、平文 2 箇所（L290/L439）は \del+\rev。摘要は無変更（点検結果: 摘要は修正不要と確認済み）。clean 20 頁（665pt）・tracking 24 頁・零 error・clean PDF で en-dash 形 0 件確認。

### 0.22 剥離版作成＋提出パッケージ同期（2026-08-15）
- 倉庫 deidentify.md の Yada et al. (2026) 帰属を復元（匿名化残滓; commit c7d509b push 済）→ **公開倉庫の 4 prompt 全てが実行版と逐字一致確定**（batch_single=improved_v6・trend=improved_v2・verification=baseline_v1・deidentify=v1; ローカルの YAML frontmatter 剥離のみが差分だった）
- 剥離スクリプト（scratchpad/strip_markup.py, 全ステップ assert 付き）で bd-risk-final.tex 生成: \del 124 削除・\rev 108 展開・トラッキング序文/説明枠/xcolor/ulem 除去。**単独コンパイル 20 頁ちょうど(665pt)・零 error**。clean 版との全文比較=**逐字一致**（差分は del/rev 接縫の二重空白 glue が単一空白になったことによる断詞位置移動のみ=剥離版の方が正しい組版）
- camera_ready/ 同期完了: BESC2026_paper96.pdf・source/{bd-risk.tex, bd-risk.bbl(新 15 件エントリ+ModernBERT DOI), refs.bib}、figures 無変更確認、source 単独コンパイル 20 頁検証済
- 残: 署名済み版権表の差し替え（本人）→ ZIP 化 → CMT 提出。thesis repo push も本人。

### 0.23 全著者メール追加（2026-08-15）
Springer 指南 p.2: 責任著者メール=必須（充足済）、全著者メール=強く推奨（各著者に出版後 Springer Nature Link の個人 access link が届く）→ 3 名分追加: \email{\{lin.jiefeng.tkb\_ge, watanabe.koichiro.ge\}@u.tsukuba.ac.jp, yada@slis.tsukuba.ac.jp}（samplepaper の同域グループ記法）。ヘッダ 1 行増だが本文前で吸収され clean/final とも 20 頁維持。著者ブロックはマーク対象外（説明枠の既定方針通り）。剥離版・パッケージ再同期＋単独コンパイル検証済（commit 8c243de）。
⚠️ 教訓: `grep -ci` はゼロ件で exit 1 → `&&` チェーンが短絡し stale ファイルを包に同期しかけた（全文比較で検出・修正済）。検証コマンドは `;` 区切りで。

### 0.24 LNCS 全面様式監査＋14件修復（2026-08-15/16）
6 次元×20 代理・LNCS 公式文書基準（規則は原文引用必須・文書沈黙時は内部一貫性と明示）：**確認 14・反駁 0・合規記録 3**。
- **提出版に無関係と判明**: clean 版の del/rev 接縫二重空白（~30 箇所・幾何測定 2 倍）は剥離スクリプトが空白折畳済み→ **final 版は単一空白で正しい**（過去の断詞位置ずれの根因もこれ）。プレビュー専用の宿題として記録のみ。
- **修復済み 13 件**: ①責任著者 \textsuperscript{(\Envelope)} 標記（指南 §6.2 の bbding 指定通り; E-Vote-ID 2025 出版実例で版式確認済み）②Table 7 表体の趨勢トークン \texttt 化 ③verified+probable の \texttt 化 ④vs.~ ×3（p.13 の規則名分断解消）⑤``never''、論理式句読点 ⑥$n=145$ 数式モード（Table 2/5 caption）⑦α/κ 関係式の完全数式モード ⑧71.0% 精度統一 ×2 ⑨five seeds ⑩引用番号順 [11,13] ×2（指南 §4.9 明文）⑪submission-comment/expert-expert 連字符化（label-text 先例に整合）
- **文献[5]の二重グルー**（splncs04 の ", ~6" 排出・6.14pt→3.07pt 実測修正）: 修補済み bbl を final tex に**インライン化**（inline_bbl.py; tectonic の bibtex 再走で上書きされないため。以後 final 再生成時は strip→compile→inline_bbl→recompile の順）。
- 合規記録 3（変更不要）: \texttt{"high"} の直引用符・符号付き数値のソース混在（渲染は一致）・macro F1 の二層大小文字慣例。
- 全版検証: tracking 24／clean 20（665pt）／final 20・逐字一致・包内単独 20 頁・零 overfull（commit 2c3151d）。
