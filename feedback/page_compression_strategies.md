# 页数压缩策略参考

> 导师要求：含 Reference ≤ 20 页（LNCS 格式）。
> 基准：0529 修订后 21 页 → 经压缩后 20 页（已执行标 ✅）。
> 后续新增 BERT baseline 等内容可能再次超出，本文档供届时参考。

---

## 已执行的压缩 ✅

| 操作 | 节省 | 说明 |
|---|---|---|
| 删除 `#pagebreak()` (Gold State → Evaluation Set Construction 之间) | ~0.2 页 | 强制分页在自然分页附近，单独效果有限，但与下条叠加有效 |
| Cross-Model 表格删除，核心数字并入正文 | ~0.3 页 | 表格 9 行 + caption → 一段文字。保留了 macro F1 0.710 vs 0.649、71% refusal、Manic 2/4 vs 1/4 |

---

## 备选策略（按优先级排序）

### 第一梯队：低负面影响

#### G. Zero-Shot 三条观察压为两条
- **节省**: ~0.1 页
- **操作**: 合并 (1) Uncertain 4× 减少 + (2) Stable F1 +0.116 为一条 "coverage and decisiveness"；(3) Manic 结构性限制保留
- **负面影响**: 低 — 表格 (@tab-zeroshot) 仍在，数字不丢失，只是文字解释更紧凑
- **压缩后文本示例**:
  > Two key patterns emerge. First, the schema's primary effect is coverage and decisiveness: Uncertain emissions drop 4× (27→7) and Stable F1 improves by +0.116, both driven by the schema's explicit vocabulary for border-class decisions. Second, Depressive and Hypomanic F1 are unchanged, and Manic remains poorly recalled in both settings (0/15 vs. 1/15), confirming the manic-pole limitation is structural rather than prompt-specific.

#### B. Fig.2 (period segmentation) 缩小
- **节省**: ~0.1 页
- **操作**: cell 高度 13mm → 10mm；可选减少显示的 period 数（6 → 4-5）
- **负面影响**: 极低 — 纯示意图，概念不受影响

#### Fig.1 缩放微调
- **节省**: ~0.05 页
- **操作**: 98% → 95%，或减小间距 (spacing) 从 5mm → 4mm
- **负面影响**: 极低 — 文字略小但仍可读

### 第二梯队：中等负面影响

#### C. Ethical Considerations 精简
- **节省**: ~0.15 页
- **操作**: 五类 PII 分类法保留名称列表（一句话），删除每类的详细示例和解释；指向 supplementary 的 `deidentify.md` prompt
- **负面影响**: 中 — 临床 NLP 审稿人重视伦理完整度。分类法的完整细节已在 supplementary prompt 中，论文不重复不算缺失
- **压缩后文本示例**:
  > Before public release, all post content undergoes LLM-based de-identification across five risk-ranked PII categories (identifiers, quasi-identifiers, contact information, linkage codes, personal identification codes), each replaced by a category-specific placeholder. The full de-identification taxonomy and prompt are available in the supplementary repository.

#### D. Discussion "Period-level trends" 段压缩
- **节省**: ~0.1 页
- **操作**: 4 条观察中 (2) FLUCTUATING 和 (4) dominant-state distribution 各压缩为一句
- **负面影响**: 中 — 弱化 demonstration 讨论深度，但核心观点 (1) episode onset 和 (3) hierarchical modeling 保留

#### E. Limitations 合并段落
- **节省**: ~0.1 页
- **操作**: "Manic-pole interpretability" 并入 "Evaluation scope"（都涉及 manic-pole 问题）
- **负面影响**: 中 — 段落边界模糊化，但内容不丢失

### 第三梯队：高负面影响（不建议）

#### A. Error Analysis 删除 synthetic case 描述
- **节省**: ~0.3 页
- **负面影响**: 高 — synthetic case 是读者理解 error pattern 的**唯一**具体例示（真实案例因 BD-Risk 数据协议不可展示）。删除后 6 个 pattern 变为纯抽象描述，审稿人难以评判其 convincingness
- **仅在极端情况下考虑**: 如需压缩 0.3+ 页且其他策略已用尽

#### H. Post-Level State Classification 五状态定义压缩
- **节省**: ~0.1 页
- **负面影响**: 高 — DSM-5 grounding 是核心方法贡献，语言标记映射到临床标准是方法论的关键内容

---

## 组合建议

| 场景 | 需压缩 | 建议组合 |
|---|---|---|
| 超 0.5 页以内 | ~0.5 页 | G + B + Fig.1 微调 |
| 超 0.5-1.0 页 | ~1 页 | G + B + C + D |
| 超 1.0-1.5 页 | ~1.5 页 | G + B + C + D + E + A（synthetic case 最后手段） |

---

## 注意事项

- BERT baseline（§二）新增后预计增加 ~0.5-1 页（一个表格 + 设计预告 + 结果段落）。计划在 Evaluation Design 预告 + Validation Results 之后新增 == BERT Fine-Tuning Baseline 子节。
- 如 BERT 新增后超出限制，优先用第一梯队策略；如仍不够再考虑第二梯队。
- 压缩时**不要触碰** Error Analysis synthetic cases 和五状态定义——这些是论文的核心方法论内容。
