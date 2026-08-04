#import "@preview/fine-lncs:0.6.5": lncs, institute, author, theorem, proof

#set text(lang: "zh", font: ("Noto Serif CJK SC", "Source Han Serif SC", "Microsoft YaHei", "SimSun"))

#let inst_tsukuba = institute("筑波大学",
  addr: "日本茨城县筑波市春日 1-2，305-8550",
  email: "lin.jiefeng.tkb_ge@u.tsukuba.ac.jp",
)

#show: lncs.with(
  title: "社交媒体中双相障碍纵向心境状态的少样本提示分析",
  running-title: "少样本 BD 心境状态分析",
  authors: (
    author("Jiefeng Lin",
      insts: (inst_tsukuba),
      oicd: "0000-0003-1800-0052",
    ),
    author("Shuntaro Yada",
      insts: (inst_tsukuba),
      oicd: "0000-0002-6209-1054",
    ),
  ),
  abstract: [
    双相障碍（bipolar disorder, BD）常被误诊为重性抑郁障碍，持续监测心境状态_转变_对于及时干预至关重要。现有用于 BD 研究的社交媒体数据集通常只提供二元诊断标签或逐帖心境评分；能够捕捉心境轨迹的资源仍然有限。由于专家标注成本高昂，且微调需要稀缺的标注数据，我们提出一种无需任务特定训练的少样本提示式 LLM 方法。该标注模式以 DSM-5 发作标准为基础，并配有八个合成少样本示例，使该方法能够直接应用于其他 BD 语料。该方法在两个粒度上标注帖子：逐帖心境状态和 14 天周期级趋势（主导状态、趋势方向、变化点），从而支持仅凭逐帖标签无法完成的轨迹建模。逐帖分类在 BD-Risk 数据集 @lee2024detecting 上进行外部验证，验证集为 145 篇帖子组成的留出、作者互斥、分层子集，取得 0.519 的 macro F1；抑郁召回率较高（87.9%），躁狂极召回率较低（35.7%/6.7%）。本文刻画了六类错误模式，其中包括躁狂极处限制可达到躁狂召回率的结构性标签--文本一致性问题。随后，我们使用 Gemini 3.1 Pro 将该方法应用于 BD 主题 subreddit 中 105 名自我报告 BD 用户（1,794 个 14 天周期，15,423 篇帖子和评论，2019 年 4 月至 2026 年 5 月），观察到抑郁极占主导，这与 BD 相关在线讨论的临床预期大体一致。
  ],
  keywords: ("双相障碍", "大语言模型", "少样本提示", "社交媒体", "临床自然语言处理", "心境轨迹"),
  bibliography: bibliography("refs.bib", style: "splncs.csl"),
)

#set heading(supplement: [Sect.])

= 引言

双相障碍（BD）的特征是躁狂、轻躁狂和抑郁发作反复出现，影响全球 1--2% 的人口 @grande2016bipolar。据估计，17--50% 的 BD 病例最初被误诊为重性抑郁障碍（MDD），因为患者通常在抑郁发作期间寻求帮助，并且可能不会将躁狂或轻躁狂状态识别为病理性状态 @hirschfeld2002guideline @vieta2018misdiagnosis。这种误诊会导致不恰当治疗（例如抗抑郁药单药治疗，可能诱发躁狂转换），并延误适当干预。

Reddit 等社交媒体平台承载了 BD 社群（例如 r/bipolar、r/BipolarReddit），用户在其中公开讨论症状、治疗和日常功能。既有研究已使用这些数据进行 BD 与 MDD 分类 @cohan2018smhd @coppersmith2015clpsych @sekulic2018not，然而现有数据集仅提供二元诊断标签（BD vs.~MDD）或用户级风险评分。能够提供随时间追踪的逐帖心境状态标签的资源仍然较少，这限制了关于心境轨迹的计算研究，并进一步限制了关于 BD 进展和早期干预的研究。

构建专家标注的 BD 语料成本很高：心境状态标注需要精神医学专业知识，而标注数据的稀缺使微调方法难以扩展。同时，大语言模型（LLM）的近期进展表明，它们可以在文本标注任务中以合理的准确性遵循人类编写的指南 @gilardi2023chatgpt。这促成了我们的思路：如果 LLM 能够内化提示中呈现的临床指南，那么一个经过精心设计、以 DSM-5 为基础并包含合成少样本示例的提示，应当能够在_没有任务特定微调或标注训练数据_的情况下完成心境状态标注，使该方法可直接应用于新的 BD 语料。

近期研究已将 LLM 应用于心理健康 NLP 任务 @xu2024mental @yang2024mentallama；然而，它们是否能够以专家级准确性分类 BD 心境状态，尤其是从文本中难以检测的躁狂极状态，尚未得到确认。

本文提出一种基于少样本提示的 LLM 方法，用于社交媒体中 BD 的纵向心境状态分析，并展示其在 Reddit 队列上的应用。我们从 BD 主题 subreddit（r/bipolar、r/BipolarReddit、r/bipolar2）中收集自我报告 BD 诊断用户的 Reddit 帖子，并在两个粒度上进行标注：（1）逐帖心境状态（_Depressive_、_Stable_、_Hypomanic_、_Manic_）和（2）14 天周期级心境趋势（主导状态、趋势方向、变化点）。标注模式遵循 DSM-5 发作标准，并以 LLM 流水线（Gemini 3.1 Pro）实现。我们使用 BD-Risk 数据集 @lee2024detecting，在 145 篇帖子组成的留出、作者互斥、分层子集上验证逐帖标注，取得 0.519 的 macro F1，其中抑郁召回率为 87.9%，轻躁狂/躁狂召回率为 35.7%/6.7%。不同心境极之间的召回率不对称既反映了一项已知模型属性（躁狂侧状态常通过所描述行为而非情感语调表现出来），也反映了源数据集躁狂极标签中的结构性标签--文本一致性问题。

本文贡献如下：
+ *方法：* 提出一种以 DSM-5 为基础的少样本提示模式，用于基于 LLM 的两个时间粒度心境状态标注（逐帖状态和 14 天周期级趋势），无需微调或标注训练数据。
+ *评估：* 在 BD-Risk 专家标注数据集 @lee2024detecting 的留出、作者互斥、分层子集上，对逐帖状态分类进行外部验证，macro F1 为 0.519（抑郁召回率 87.9%，轻躁狂召回率 35.7%，躁狂召回率 6.7%），并辅以零样本基线比较、监督式微调基线以及跨五家供应商五个额外 LLM 的跨模型可移植性评估（macro F1 0.432--0.564）。
+ *示范：* 将该方法应用于 BD 主题 subreddit 中的 105 名自我报告 BD 用户（1,794 个 14 天周期，15,423 篇帖子和评论，时间跨度为 2019 年 4 月至 2026 年 5 月），生成纵向心境轨迹标注，其分布与临床 BD 文献一致。


= 相关工作

== BD 中的纵向心境监测

追踪 BD 心境轨迹的临床方法在很大程度上依赖生态瞬时评估（EMA）以及通过智能手机传感器和自评应用的数字表型 @faurholt2018smartphone @torous2016new。这些方法能够产生密集的心境信号，然而它们需要患者主动入组并提供知情同意，因此限制了队列规模和外部使用。社交媒体提供了一种互补的非侵入式来源：对于已在讨论自身状况的用户，它能够提供跨越数月到数年的被动、自然产生的语言数据；然而，具有周期级心境轨迹标注的公开语料仍然有限，这制约了纵向 BD 方法的开发。

== 心理健康检测中的社交媒体

#cite(<dechoudhury2013predicting>, form: "prose") 表明，社交媒体信号可以预测抑郁发作。SMHD 数据集 @cohan2018smhd 通过自我报告诊断覆盖九类心理健康状况；#cite(<coppersmith2015clpsych>, form: "prose") 建立了基于 X (formerly Twitter) 的抑郁和 PTSD 检测共享任务。

对于 BD，#cite(<sekulic2018not>, form: "prose") 提出了基于 Reddit 的分类方法，#cite(<jagfeld2021understanding>, form: "prose") 汇编了一个大型 BD Reddit 语料；然而，两者均依赖未经专家验证的自我报告诊断 @harrigian2021state @chancellor2020methods。BD-Risk 数据集 @lee2024detecting 提供由精神科医生和临床心理学家验证的逐帖心境标签；我们将其作为逐帖验证的金标准。

== 面向临床 NLP 与心理健康的 LLM

#cite(<xu2024mental>, form: "prose") 评估了 LLM 从在线文本预测心理健康状态的能力；#cite(<yang2024mentallama>, form: "prose") 对 MentalLLaMA 进行了微调，以支持可解释的心理健康分析。#cite(<lee2024detecting>, form: "prose") 发现 ChatGPT 在 BD 风险检测上的 F1 仅为 0.130（相比之下，其多任务模型为 0.578），表明现成 LLM 在 BD 特定任务上仍面临困难。对于 LLM 标注质量这一更一般的问题，#cite(<gilardi2023chatgpt>, form: "prose") 表明 ChatGPT 在文本标注任务中可以达到或超过众包工人的表现；我们的工作沿着这一路径，将 LLM 视为标注者（而非分类器），并将其输出锚定在明确的 DSM-5 派生模式中。

不同于上述诊断预测评估，我们提出一种基于提示的方法，用于_标注_逐帖心境状态和周期级趋势，并针对专家标签验证这些标注；错误分析（@errorsec）刻画了该模式必须应对的失败模式。


= 方法

== 方法概述 <resourcesec>

所提出的方法以来自心理健康相关社交媒体社区的用户发帖历史为输入，并在两个时间粒度（逐帖状态和 14 天周期级趋势）上生成心境状态标注。@fig-pipeline 展示了端到端流程：通过基于 LLM 的患者验证识别候选用户，随后使用两个基于 DSM-5 的提示进行结构化标注。

#figure(
  {
    import "@preview/fletcher:0.5.8": diagram, node, edge

    // Muted-academic palette: distinct hues for the pipeline roles, each
    // readable in print and grayscale (border-only colouring keeps fills white).
    let c_data    = "#1F4E79"  // blue   (data collection)
    let c_verify  = "#2E7D32"  // green  (patient verification)
    let c_annot   = "#7030A0"  // purple (LLM prompts, Gemini)
    let c_post    = "#1F4E79"  // blue   (post-level output)
    let c_trend   = "#C65911"  // orange (period-level output)

    // Inline line-art icons (Lucide-style, MIT-licensed paths) — outline
    // strokes only, so they look line-drawn rather than chunky-filled.
    let line_icon(paths, color, size: 11pt) = box(
      width: size, height: size,
      image(
        bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' "
              + "fill='none' stroke='" + color + "' stroke-width='1.8' "
              + "stroke-linecap='round' stroke-linejoin='round'>"
              + paths + "</svg>"),
        format: "svg",
      ),
    )

    let icon_globe = ("<circle cx='12' cy='12' r='10'/>"
      + "<path d='M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20'/>"
      + "<path d='M2 12h20'/>")
    let icon_shield = ("<path d='M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z'/>"
      + "<path d='m9 12 2 2 4-4'/>")
    let icon_brain = ("<rect width='16' height='16' x='4' y='4' rx='3'/>"
      + "<circle cx='9' cy='9' r='1.2'/>"
      + "<circle cx='15' cy='9' r='1.2'/>"
      + "<circle cx='9' cy='15' r='1.2'/>"
      + "<circle cx='15' cy='15' r='1.2'/>"
      + "<line x1='9' y1='9' x2='15' y2='9'/>"
      + "<line x1='9' y1='15' x2='15' y2='15'/>"
      + "<line x1='9' y1='9' x2='9' y2='15'/>"
      + "<line x1='15' y1='9' x2='15' y2='15'/>")

    // Stage box: bold title on top (in the box's border color), icon
    // centered below, then small body lines.
    let make_box(pos, icon_paths, color, title, body_lines, width: 22mm, name: none) = node(
      pos,
      {
        set par(first-line-indent: 0pt, leading: 0.4em, justify: false)
        stack(dir: ttb, spacing: 2.5pt,
          align(center, text(weight: "bold", size: 7.5pt, fill: rgb(color), hyphenate: false)[#title]),
          align(center, line_icon(icon_paths, color, size: 16pt)),
          ..body_lines.map(line =>
            align(center, text(size: 6pt, fill: luma(70), hyphenate: false)[#line])
          ),
        )
      },
      width: width,
      fill: white,
      stroke: (paint: rgb(color), thickness: 0.8pt),
      corner-radius: 2pt,
      inset: 4pt,
      name: name,
    )

    let elabel(body) = box(
      fill: white,
      inset: (x: 1.5pt, y: 0.5pt),
      align(center, text(size: 6pt)[#body]),
    )

    // Sub-box inside the LLM prompts compound (one per prompt).
    // `justify: false` prevents single-word wrapped lines (e.g. "A.") from
    // being stretched to the box width, which would read as a left indent;
    // `hyphenate: false` blocks mid-word breaks like "rea-soning".
    let prompt_subbox(header, task, rules) = box(
      stroke: 0.45pt + rgb(c_annot),
      radius: 1.5pt,
      inset: 3pt,
      width: 100%,
      {
        set par(first-line-indent: 0pt, leading: 0.4em, justify: false)
        set text(hyphenate: false)
        stack(dir: ttb, spacing: 2pt,
          align(center, text(weight: "bold", size: 6.5pt, fill: rgb(c_annot))[#header]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *任务：*\ #task]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *规则：*\ #rules]),
        )
      },
    )

    // The "LLM prompts" compound node wraps the two sub-boxes (A above B)
    // with a single dashed border so it reads as one stage.
    let llm_prompts = node(
      (1, 0),
      {
        set par(first-line-indent: 0pt, justify: false)
        set text(hyphenate: false)
        stack(dir: ttb, spacing: 3pt,
          align(center, text(weight: "bold", size: 9pt, fill: rgb(c_annot))[LLM 提示]),
          grid(
            columns: (1fr, 1fr),
            column-gutter: 3pt,
            prompt_subbox(
              [单帖提示],
              [独立分类每条帖子],
              [DSM-5、安全覆写、行为优先于语调],
            ),
            prompt_subbox(
              [14 天趋势提示],
              [分析每个 14 天周期],
              [全周期证据加权、混合特征],
            ),
          ),
        )
      },
      width: 40mm,
      fill: white,
      stroke: (paint: rgb(c_annot), thickness: 0.9pt, dash: "dashed"),
      corner-radius: 2pt,
      inset: 3pt,
      name: <prompts>,
    )

    // JSON-style output box (monospace, code-like).
    // No inner background; JSON is left-aligned (raw lines inherit the
    // node's default centering otherwise, which looks like centered code).
    let json_box(pos, color, title, fields, width: 32mm, name: none) = node(
      pos,
      {
        set par(first-line-indent: 0pt, leading: 0.4em, justify: false)
        set text(hyphenate: false)
        stack(dir: ttb, spacing: 3pt,
          align(center, text(weight: "bold", size: 7.5pt, fill: rgb(color))[#title]),
          v(3pt),
          align(left, {
            set text(size: 5.5pt, font: "DejaVu Sans Mono")
            stack(dir: ttb, spacing: 0.5pt,
              raw("{"),
              ..fields.map(f => raw("  \"" + f + "\": \"...\",")),
              raw("}"),
            )
          }),
        )
      },
      width: width,
      fill: white,
      stroke: (paint: rgb(color), thickness: 0.8pt),
      corner-radius: 2pt,
      inset: 4pt,
      name: name,
    )

    // The diagram's natural width exceeds the LNCS column, so we render it
    // at full size then scale uniformly to fit. `reflow: true` makes the
    // bounding box collapse to the scaled size (otherwise the surrounding
    // layout would still reserve the un-scaled width).
    align(center, scale(x: 98%, y: 98%, reflow: true,
      diagram(
        spacing: (5mm, 1.2mm),
        edge-stroke: 0.6pt + black,
        mark-scale: 60%,

        // Incoming arrow: user posting history feeds into the pipeline.
        // Start far enough left so the arrow and label clear the verify box.
        edge((-2.5, 0), <verify>, "-|>", elabel[用户发帖\ 历史], label-pos: 0.25),

        // Row 0: main pipeline.
        make_box((-0.8, 0), icon_shield, c_verify, [患者验证],
          ([LLM 证据], [三级分类器]), width: 16mm, name: <verify>),
        edge(<verify>, <prompts>, "-|>", elabel[已验证\ 队列], label-side: left),

        llm_prompts,
        edge(<prompts>, <gemini>, "-|>"),

        make_box((2, 0), icon_brain, c_annot, [Gemini\ 3.1 Pro],
          ([基于 DSM-5], [标注]), width: 17mm, name: <gemini>),

        // Brace-style fork from Gemini to the two outputs.
        // All fork coordinates are relative to <gemini> via (rel:, to:).
        // edge(<gemini>, (rel: (0.2, 0), to: <gemini>), "-"),
        edge((rel: (0.2, -0.55), to: <gemini>), (rel: (0.2, 0.55), to: <gemini>), "-"),
        edge((rel: (0.2, -0.55), to: <gemini>), <post-out>, "-|>", mark-scale: 120%),
        edge((rel: (0.2,  0.55), to: <gemini>), <trend-out>, "-|>", mark-scale: 120%),

        json_box((3, -0.55), c_post, [逐帖输出],
          ("state", "specifiers", "confidence", "reasoning"), width: 29mm, name: <post-out>),

        json_box((3, 0.55), c_trend, [周期级输出],
          ("dominant_state", "trend_direction", "change_points", "trend_summary", "confidence"), width: 29mm, name: <trend-out>),
      )
    ))
  },
  caption: [标注流水线：在两个时间粒度（逐帖和 14 天周期级）上生成结构化心境状态标签。],
) <fig-pipeline>

在心理健康相关 subreddit 发帖是必要但不充分的 BD 诊断信号：许多此类帖子来自临床工作者、家属或一般社群参与者。为筛选候选池，我们应用一个 LLM 三级分类器（Gemini 3.1 Pro，独立提示），扫描每位作者的完整发帖历史，并返回 `verified`（明确的第一人称诊断陈述，例如 "I was diagnosed with bipolar II in 2019"，或具体治疗/住院叙述）、`probable`（通过症状、药物或社群成员语气体现的一致自我认同，但没有明确诊断陈述），或 `unverified`（无诊断信号）。只有 `verified` 和 `probable` 层级被纳入标注队列；这与既有 BD 社交媒体数据集 @sekulic2018not @jagfeld2021understanding 的纳入模型一致，同时比单帖成员规则采用更严格的逐用户证据门控。

== 标注模式 <frameworksec>

我们的标注模式借鉴 DSM-5 发作定义 @apa2013dsm5，并将其操作化为面向 LLM 标注的结构化提示框架。以下规则是在针对外部专家标签的错误分析基础上迭代形成的（见 @errorsec）；下文命名的每条临床指导规则都是该模式对其中某类反复出现失败模式的回应。由于 BD-Risk 帖子包含敏感的心理健康披露内容，错误分析使用合成案例而非原始帖子文本说明每种模式，同时保留原始分歧中具有临床相关性的结构。

=== 逐帖状态分类
对于每条单独帖子（发帖或评论），LLM 从五个选项中分配一个类别型心境状态：

- *Manic：* 夸大、压力性书写（长串句、过度大写）、意念飘忽（离题的话题跳转）、极端易激惹或欣快。
- *Hypomanic：* 能量与节奏升高且保持连贯，社交去抑制，没有精神病性特征的不寻常强度。
- *Depressive：* 语言收缩、绝对化语言（"never""nothing"）、高度自我聚焦（第一人称代词）、认知扭曲、自杀意念。
- *Stable：* 情绪语调平衡、元认知反思、反应相称、支持社群的语言。
- *Uncertain：* 仅用于真正无法解释的帖子；LLM 必须在诉诸该标签之前尝试分类。

该框架还支持 `with_mixed_features` 说明符（遵循 DSM-5 混合特征标准）。在应用该说明符之前，提示要求 LLM 抽取明确的相反极症状列表，并且只有在记录到三个或更多明确相反极症状时才分配 `with_mixed_features`。这一证据抽取步骤避免将混合特征说明符用作模糊的中性标签。

=== 周期级趋势分析
为进行纵向心境轨迹建模，我们将每位用户的发帖历史划分为连续的固定长度周期（默认：14~天）。14 天窗口长度是在临床顾问协助下确定的，并以 DSM-5 发作持续时间标准为依据：重性抑郁发作至少持续两周，躁狂发作至少持续一周 @apa2013dsm5；因此，14 天窗口能够覆盖完整抑郁发作的最短持续时间，并允许观察躁狂发作的起始与进展。周期锚定在用户第一条帖子（第 0 天），并以严格的半开区间 $[t_(k), t_(k) + 14)$ 前进；帖子和评论共同分配到包含其时间戳的周期。定义从用户第一条到最后一条帖子之间的所有周期；没有帖子的周期被赋予 `NO_DATA` 标签而不是跳过，从而为轨迹建模保留连续时间网格。@fig-period-slicing 展示了该划分。

#figure(
  {
    let s_dot = circle(radius: 1.6pt, fill: black, stroke: none)
    let c_dot = circle(radius: 1.6pt, fill: white, stroke: 0.5pt + black)
    let dots(..kinds) = stack(
      dir: ltr,
      spacing: 4pt,
      ..kinds.pos().map(k => if k == "S" { s_dot } else { c_dot }),
    )
    let cell(body) = box(
      width: 100%, height: 10mm,
      stroke: 0.4pt + black, inset: 3pt,
      align(center + horizon, body),
    )
    let nodata_cell = box(
      width: 100%, height: 10mm,
      stroke: 0.4pt + black, fill: luma(240), inset: 3pt,
      align(center + horizon, text(size: 7pt, style: "italic", fill: luma(80))[NO\_DATA]),
    )

    grid(
      columns: (1fr,) * 6,
      column-gutter: 0pt,
      row-gutter: 2pt,
      align: center + horizon,

      text(weight: "bold", size: 7pt)[周期 1],
      text(weight: "bold", size: 7pt)[周期 2],
      text(weight: "bold", size: 7pt)[周期 3],
      text(weight: "bold", size: 7pt)[周期 4],
      text(weight: "bold", size: 7pt)[周期 5],
      text(weight: "bold", size: 7pt)[周期 6],

      text(size: 6pt, fill: luma(110))[第 0--13 天],
      text(size: 6pt, fill: luma(110))[第 14--27 天],
      text(size: 6pt, fill: luma(110))[第 28--41 天],
      text(size: 6pt, fill: luma(110))[第 42--55 天],
      text(size: 6pt, fill: luma(110))[第 56--69 天],
      text(size: 6pt, fill: luma(110))[第 70--83 天],

      cell(dots("S", "C", "S", "C")),
      cell(dots("C", "C")),
      nodata_cell,
      cell(dots("S", "C")),
      cell(dots("C", "C", "C", "C")),
      cell(dots("S")),
    )
  },
  caption: [周期划分（示意）。帖子（实心圆）和评论（空心圆）落入包含其时间戳的周期；空周期保留 `NO_DATA` 标签。],
) <fig-period-slicing>

对于每个至少包含一条帖子的周期，LLM 分析其中收集的帖子并生成：

- *主导状态：* 该周期内的主要心境状态（与逐帖层面相同的五分类集合），在窗口内所有帖子上聚合。
- *趋势方向：* `NO_TREND`（状态维持）、`TOWARDS_MANIA` / `TOWARDS_DEPRESSION`（逐步向相应极端恶化），或 `FLUCTUATING`（交替出现但无明确方向）。
- *变化点：* 心境转变发生的具体日期或事件，并记录转变前后的状态。
- *趋势摘要：* 简要叙述该周期的轨迹以及支持主导状态的证据。
- *DSM-5 说明符：* 当相反极症状在周期内共同出现时标记 `with_mixed_features`（区别于序列性波动）。

这两个粒度共同支持事件层面分析（例如，状态变化之前发生了什么）和纵向轨迹建模；明确的变化点字段还使文本层面的变化点检测成为可能 @truong2020selective。

=== 少样本示例构建
逐帖提示配有八个合成少样本示例（标记为 A--H），由作者编写。每个示例都演示一条针对开发过程中观察到的失败模式的模式规则（完整分析见 @errorsec）：A 展示回顾性躁狂侧叙述中的 _Behavior Over Tone_；B 和~E 展示带有夸大性躁狂例外的 _SAFETY OVERRIDE_ 规则；C 和~D 对比 _Improvement-Narrative_ 与 _Whole-Post Evidence Weighting_；F 抑制短帖中默认转向 _Uncertain_ 的倾向；G 展示物质诱发轻躁狂的 _Recurrent-Pattern Exception_；H 演示用于区分 _Hypomanic_ 与 _Stable_ 边界的 _Severity Descriptors_。每个示例都给出输入文本以及完整预期 JSON 输出（包括 `opposite_pole_symptoms` 证据列表和推理），因此模型可以同时观察目标标签和证据链。完整提示文本发布在补充仓库中（见附录）。

= 验证实验

== 针对 BD-Risk 的外部验证 <validsec>

BD-Risk 数据集 @lee2024detecting 包含来自 1,025 名用户的 7,346 条 Reddit 帖子，每条帖子都带有精神科医生指导的 7 点心境水平标签（$-$3 至 $+$3）。由于该数据集基于初始 MDD 表现选择用户（MDD-only 与 MDD$arrow$BD 组），其结构上富含抑郁极内容（89.0% 的帖子 $lt 0$）。

BD-Risk 数据集只提供有序心境标签；类别型状态并未被直接标注。为获得评估用金标准状态，我们根据 @tab-mapping 所示映射从 BD-Risk 心境标签推导类别。

#figure(
  table(
    columns: 3,
    align: (center, center, left),
    stroke: none,
    table.hline(),
    table.header(
      [*BD-Risk 心境标签*], [*派生金标状态*], [*备注*],
    ),
    table.hline(stroke: 0.5pt),
    [$-$3, $-$2, $-$1], [Depressive], [],
    [0, $+$1], [Stable], [$+$1 = high motivation / positive mood within normal range],
    [$+$2], [Hypomanic], [Clear manic-side activation without psychosis],
    [$+$3], [Manic], [Severe manic expression with psychotic features],
    table.hline(),
  ),
  caption: [从 BD-Risk 7 点心境标签到推导金标准状态的映射。],
) <tab-mapping>

完整 BD-Risk 数据集呈现高度偏斜的心境分布（89.0% 的帖子 $lt$ 0）。由于部署任务是 BD 风险检测而非一般心境分类，我们有意过采样躁狂极帖子，使得代表性不足类别的逐类指标具有足够支持度。

我们将已标注帖子分为两个互斥子集。_开发_子集（314 条帖子）用于提示设计和失败模式分析。_留出_子集（145 条帖子）专门用于下文报告的评估；它与开发子集_作者互斥_，通过从不在开发子集中的 BD-Risk 作者中分层抽样得到，并设置配额以确保四个推导金标准状态均有足够的逐类支持（$60$ _Depressive_、$40$ _Stable_、$30$ _Hypomanic_、$15$ _Manic_）。@bdresultsec 中所有指标均在留出子集上计算；开发子集从不用于产生报告数字。BD-Risk 中躁狂极金标准帖子几乎全部来自 MDD$arrow$BD 组，因此留出的躁狂侧样本在结构上来自 MDD$arrow$BD（该限制在 @discussionsec 中讨论）。

== 评估指标 <metricssec>

我们报告逐类精确率、召回率和 F1，以及总体准确率和 macro F1。报告两种准确率变体：_排除_ _Uncertain_ 的准确率将 _Uncertain_ 输出视为弃权，并从分子与分母中同时移除；_包含_ _Uncertain_ 的准确率将 _Uncertain_ 计为错误，从而提供保守下界。逐类指标基于排除 _Uncertain_ 的口径计算。

== 评估设计 <evaldesignsec>

除主要的 BD-Risk 留出验证外，我们还进行三项附加评估，以刻画该模式的性质，并将其表现置于监督式替代方案的背景中：

- *零样本基线比较：* 为量化结构化标注模式（DSM-5 规则、少样本示例）相对于 LLM 基础能力的贡献，我们使用仅包含任务定义和输出格式的最小零样本提示重新评估同一模型。
- *跨模型可移植性评估：* 为测试该模式能否推广到主要标注者之外，我们使用来自五家供应商的五个额外 LLM（Gemini 3.5 Flash、Claude Opus 4.8、DeepSeek V4 Pro、GLM-5.1 和 GPT-5.5）评估完整模式，刻画模式可移植性、各模型躁狂极行为以及供应商层面内容政策差异对标注可行性的影响。
- *监督微调基线：* 为评估带标签数据的任务特定微调是否优于所提出的少样本方法，我们在 314 条训练池的逐步增大子集（$n in {50, 100, 200, 314}$）上微调 ModernBERT-base @warner2025modernbert，并在同一 145 条留出集上评估，从而在相同测试条件下进行直接比较。

== LLM 配置

我们通过官方 API 使用 Gemini 3.1 Pro @team2024gemini，并要求结构化 JSON 输出；选择该模型是因为其上下文窗口较大且原生支持结构化输出生成。每条帖子都使用完整标注模式和上述少样本示例作为系统指令进行独立处理；模型返回一个 JSON 对象，包含 `state`、`opposite_pole_symptoms`、`specifiers`、`confidence`（High/Medium/Low）和 `reasoning` 字段，其中 `opposite_pole_symptoms` 承载在分配 `with_mixed_features` 之前所需的明确证据列表（见 @frameworksec）。对于周期级标注，LLM 还返回 `trend_direction`、`change_points` 和 `trend_summary` 叙述，并以 0--1 的尺度给出 `confidence`。我们使用 Gemini 推荐的默认温度 1.0；Google 对 Gemini 3 系列模型的文档建议不使用更低温度，因为较低温度可能在复杂推理任务上导致循环或性能下降。模型未经过微调。

== 验证结果 <bdresultsec>

我们首先针对 BD-Risk 专家标签验证逐帖状态分类（@tab-state-metrics：逐类指标及宏聚合摘要）；由于留出子集经过有意的跨类分层，macro F1 是主要指标。

#figure(
  table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*状态*], [*精确率*], [*召回率*], [*F1*], [*支持数*],
    ),
    table.hline(stroke: 0.5pt),
    [Depressive],     [0.630],   [*0.879*], [*0.734*], [58],
    [Stable],         [0.659],   [0.784],   [0.716],   [37],
    [Hypomanic],      [*0.833*], [0.357],   [0.500],   [28],
    [Manic],          [*1.000*], [0.067],   [0.125],   [15],
    table.hline(stroke: 0.5pt),
    [_Macro avg_],    [_0.781_], [_0.522_], [_0.519_], [_138_],
    table.hline(),
  ),
  caption: [留出子集上的逐类指标与宏摘要（n=145；排除 7 个 _Uncertain_ 后为 138）。排除/包含 _Uncertain_ 的准确率 = 65.9 % / 62.8 %。],
) <tab-state-metrics>

_Depressive_ 召回率较高（87.9%），_Stable_ 召回率中等（78.4%），而 _Hypomanic_ 与 _Manic_ 召回率仍然较低（35.7% 与 6.7%），表明 LLM 能正确识别大多数抑郁和稳定帖子，却漏掉了多数躁狂极病例。主要错误流向从躁狂极流向 _Depressive_：在 30 条金标准 _Hypomanic_ 帖子中，12 条被预测为 _Depressive_，6 条被预测为 _Stable_；在 15 条金标准 _Manic_ 帖子中，11 条被预测为 _Depressive_，2 条被预测为 _Stable_。这些错误集中在躁狂极帖子上，其激活信号被负性语调掩盖，这是当前提示尚未完全解决的模式。Manic 到 Depressive 的错误流向是一种反复出现的模式，可能具有标签--文本来源，我们在 @discussionsec 中讨论。

== 监督微调基线 <bertsec>

为给少样本 LLM 结果提供参照，我们与监督式基线进行比较。我们在同一 BD-Risk 训练池上微调 ModernBERT-base @warner2025modernbert（149M 参数），使用逐步增大的带标签子集（$n in {50, 100, 200, 314}$），并在相同的 145 条留出集上评估。每个档位训练 10 个 epoch，学习率为 $2 times 10^(-5)$，最大序列长度为 2,048 tokens；对于 50--200 档，我们报告五个随机训练集样本（种子 42--46）的均值和标准差，而 314 档使用全部可用训练样本，并报告五个随机初始化上的方差。@tab-bert-baseline 将这些结果与 LLM 条件并列汇总。

#figure(
  table(
    columns: 4,
    align: (left, left, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*方法*], [*训练数据*], [*宏 F1*], [*$Delta$（相对 few-shot）*],
    ),
    table.hline(stroke: 0.5pt),
    [ModernBERT], [$n = 50$],   [$0.306 plus.minus 0.022$], [$-0.213$],
    [ModernBERT], [$n = 100$],  [$0.337 plus.minus 0.018$], [$-0.182$],
    [ModernBERT], [$n = 200$],  [$0.372 plus.minus 0.019$], [$-0.147$],
    [ModernBERT], [$n = 314$],  [$0.398 plus.minus 0.018$], [$-0.121$],
    table.hline(stroke: 0.5pt),
    [Gemini 3.1 Pro], [zero-shot],  [$0.459$], [$-0.060$],
    [Gemini 3.1 Pro], [8 few-shot], [$bold(0.519)$], [---],
    table.hline(),
  ),
  caption: [留出子集（$n = 145$）上的监督微调基线与 LLM 标注对比。ModernBERT 结果报告 5 个种子的均值 $plus.minus$ 标准差。少样本 LLM 使用八个合成示例，且不需要带标签训练数据。],
) <tab-bert-baseline>

ModernBERT 的 macro F1 随训练规模单调上升（0.306 $arrow.r$ 0.398），但即使在最大可用训练规模（$n = 314$）下，仍比 Gemini few-shot（0.519）低 0.121，并且仅接近 Gemini zero-shot 水平（0.459）。我们还在完整 314 条训练集上探索了 15 和 20 个 epoch 的训练：15 epochs 达到 $0.454 plus.minus 0.038$，20 epochs 达到 $0.445 plus.minus 0.010$，缩小了差距，但两种情况下均仍低于 few-shot 结果。

逐类分析显示，ModernBERT 也表现出与 LLM 结果中相同的躁狂极困难（@bdresultsec）：在五次 314 档运行中，_Manic_ 召回率平均为 0.04（5 次中有 2 次 _Manic_ 召回率为零），而 _Depressive_ 与 _Stable_ F1 平均分别为 0.51 和 0.62。这种平行现象表明，躁狂极限制更可能源于 BD-Risk 标签--文本关系（@errorsec，模式~1），而非某一模型架构的选择。

为 BD 心境状态分类标注 314 条训练样本需要精神科医生指导的标注工作；少样本 LLM 方法仅使用八个合成提示示例、无需人工标注，即取得更高表现。

== 验证结果的解释

LLM 将 7 条帖子（4.8%）标记为 _Uncertain_，在帖子内容不足以进行状态评估时选择弃权，这与提示中明确要求优先弃权而非强制分类的指令一致。_Uncertain_ 输出分布在各金标准类别中（2 条 _Depressive_、3 条 _Stable_、2 条 _Hypomanic_、0 条 _Manic_），没有明显集中在某一极。

=== 模式贡献：与零样本基线比较
按照 @evaldesignsec 中的设计，我们在留出子集上比较完整模式与最小零样本提示。零样本提示仅保留任务定义（帖子 $arrow.r$ 五种状态之一）和输出 JSON 字段；所有 DSM-5 规则、_SAFETY OVERRIDE_、_Severity Descriptors_ 和少样本示例均被移除。@tab-zeroshot 报告并列指标。

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*指标*], [*Zero-shot*], [*完整模式*], [*$Delta$*],
    ),
    table.hline(stroke: 0.5pt),
    [Accuracy (incl. Uncertain)], [51.7%], [*62.8%*],  [#text()[$+$11.1 pp]],
    [Accuracy (excl. Uncertain)], [63.6%], [65.9%],   [#text()[$+$2.3 pp]],
    [Macro F1],                   [0.459], [*0.519*], [#text()[$+$0.060]],
    [Uncertain count],            [27],    [*7*],     [#text()[$-$20]],
    [DEPRESSIVE F1],              [*0.738*], [0.734],  [#text()[$-$0.004]],
    [STABLE F1],                  [0.600],   [*0.716*], [#text()[$+$0.116]],
    [HYPOMANIC F1],               [0.500],   [0.500],   [$plus.minus$ 0.000],
    [MANIC F1],                   [0.000],   [*0.125*], [#text()[$+$0.125]],
    table.hline(),
  ),
  caption: [留出子集上的模式贡献（n=145）。两次运行均使用 Gemini 3.1 Pro 和相同 JSON 输出；唯一变量是系统提示（最小零样本与完整模式）。],
) <tab-zeroshot>

该模式的主要效果是减少弃权并锚定边界类别决策：_Uncertain_ 输出减少 4$times$（27 $arrow.r$ 7），_Stable_ F1 提高 +0.116（由 Severity Descriptors 中关于轻度积极激活属于 _Stable_ 的明确规则驱动），这解释了为什么包含 _Uncertain_ 的准确率增益（+11.1 pp）远大于排除 _Uncertain_ 的增益（+2.3 pp）。_Depressive_ 与 _Hypomanic_ F1 保持不变，_Manic_ 在两次运行中召回率均很差（zero-shot 0/15 vs. schema 1/15，将 _Uncertain_ 计为错误），进一步表明躁狂极限制是结构性的（标签--文本一致性，@discussionsec），而非更丰富提示可解决的限制。

=== 跨模型模式可移植性 <crossmodelsec>
为测试模式能否推广到 Gemini 3.1 Pro 之外，我们在同一 145 条留出子集上，使用来自五家供应商的五个额外 LLM 应用相同提示和 JSON 格式。@tab-crossmodel 报告完成全部标注的四个模型；GPT-5.5 因拒绝多数帖子，在正文中单独报告。

#figure(
  table(
    columns: 7,
    align: (left, right, right, right, right, right, right),
    stroke: none,
    inset: (x: 5pt, y: 2.2pt),
    table.hline(),
    table.header(
      [*模型*], [*N*], [*宏 F1*], [*抑郁召回*], [*轻躁召回*], [*躁狂召回*], [*不确定*],
    ),
    table.hline(stroke: 0.5pt),
    [Gemini 3.5 Flash],    [145], [$bold(0.564)$], [$0.850$], [$0.379$], [$0.200$], [3],
    [Gemini 3.1 Pro],      [145], [$0.519$],       [$0.879$], [$0.357$], [$0.067$], [7],
    [Claude Opus 4.8],     [145], [$0.535$],       [$0.932$], [$0.429$], [$0.067$], [7],
    [GLM-5.1],             [145], [$0.456$],       [$0.881$], [$0.286$], [$0.000$], [4],
    [DeepSeek V4 Pro],     [145], [$0.432$],       [$0.833$], [$0.241$], [$0.000$], [2],
    table.hline(),
  ),
  caption: [留出子集上的跨模型评估（$n = 145$），使用相同 8 示例 few-shot 提示。Macro F1 基于四个目标类别计算，排除 _Uncertain_（见 @bdresultsec）。],
) <tab-crossmodel>

该比较产生三点观察。第一，该模式在全部五个列表模型上均生成有效的结构化输出且零拒绝（macro F1 0.432--0.564），表明该模式并非供应商特有；相比之下，GPT-5.5 在相同提示下拒绝了 145 条帖子中的 103 条，仅在回答的 42 条上达到 0.710，因此我们单独报告该模型，视为不可直接比较。第二，躁狂极检测不足在各模型族间一致（DeepSeek V4 Pro 和 GLM-5.1 的 _Manic_ 召回率为零；Claude Opus 4.8 和 Gemini 3.1 Pro 为 6.7%；Gemini 3.5 Flash 为 20.0%），强化了结构性解释（@discussionsec），即困难源于 BD-Risk 标签--文本关系而非某一单个模型。第三，_Hypomanic_ 召回率变异更大（0.241--0.429），这与躁狂侧检测取决于模型读取行为线索而非情感语调的能力一致（模式~1，@errorsec）。

Gemini 3.5 Flash 在完整留出子集上取得最高 macro F1（0.564），超过 Gemini 3.1 Pro 0.045。由于该语料在此次跨模型比较之前已使用 Gemini 3.1 Pro 完成标注，现有标注保持不变；该结果表明模式性能随模型能力提升而改善，使用更新模型重新标注可能改善躁狂极覆盖率。

GPT-5.5 拒绝分类 145 条留出帖子中的 103 条（71.0%），返回逐字拒答（`"I'm sorry, but I cannot assist with that request."`），集中在包含明确自伤或自杀内容的帖子上。提示中的临床研究框架未能克服该拒答。在 GPT-5.5 实际分类的 42 条帖子上（偏离抑郁危机内容：16 条 _Depressive_、10 条 _Stable_、12 条 _Hypomanic_、4 条 _Manic_），它达到了 0.710 的 macro F1，主要由较高的 _Manic_ 召回率（2/4）驱动。子集选择本身才是主导效应：GPT-5.5 系统性过滤掉了推动 Gemini 多数错误率的困难抑郁危机帖子，因此 macro F1 比较高估了 GPT-5.5 的有效能力。71% 的拒答率使 GPT-5.5 无论内在能力如何都无法作为精神健康语料的独立标注者。

=== 错误分析 <errorsec>
我们通过手工分析开发子集中 LLM 与 BD-Risk 的分歧，刻画六类失败模式。对于每种模式，我们命名旨在缓解该模式的模式规则，并说明该规则是否在留出子集上解决了该模式，或该模式是否仍为残余错误。躁狂极帖子被误分为抑郁或稳定仍然是主要残余失败模式（在 @bdresultsec 中量化）。

模式 1 是主要的躁狂侧错误，即 LLM 忽略回顾性行为线索。当用户以带有悔恨或自责的回顾性帖子描述躁狂发作行为（冲动消费、攻击性冲突、过度活跃）时，LLM 锚定在_当前情绪语调_而非_所述行为的临床意义_上，并预测为 _Depressive_。模式中的 _Behavior Over Tone_ 规则直接针对这一混淆；然而，它仍然是留出子集上的主要残余错误，说明该规则减少了这一模式但未能完全消除。_合成案例：_ 用户以深度后悔和自我贬低的语调回忆一周的鲁莽消费和冲动决定；金标准为 _Hypomanic_（这些行为是躁狂症状的典型表现），LLM 预测为 _Depressive_（锚定于自我贬低语调）。

模式 2 是将混合特征误认为中性。当一条帖子同时带有两极症状（例如严重睡眠中断和无法集中注意力，同时伴随攻击性爆发）时，LLM 有时将共存解释为相互抵消，并默认 _Stable_。根据 DSM-5 @apa2013dsm5，混合特征应当作为主导极上的 `with_mixed_features` 说明符呈现。该模式中的混合特征规则减少了这种混淆，但当症状信号较为微弱时仍出现残余实例。_合成案例：_ 用户写道自己三天没有睡觉、无法在工作中集中注意力，并且冲伴侣发火，所有内容都在同一帖子中；金标准为带混合特征的 _Hypomanic_（睡眠需求降低伴随烦躁性易激惹），LLM 基于信号"相互抵消"的推理预测为 _Stable_。

模式 3 是安全关键情况，即平静写作风格掩盖自杀意念。一些帖子以平静、反思性或教育性散文表达自杀意念（"I want to die"）；LLM 将语言体裁解读为稳定并据此分类，而金标准状态为 _Depressive_（$-$3）。平静写作并不排除自杀危机，模式中明确的 _SAFETY OVERRIDE_ 规则强制在出现危机级语言时无论周围语调如何均标记为 _Depressive_。在留出子集上，包含明确自杀内容的帖子没有被预测为 _Stable_ 或 _Uncertain_，表明该规则在评估子集上有效。_合成案例：_ 用户发布一篇关于公众对抑郁误解的连贯短文；第二段中以同样平静语体嵌入一句话，说明作者多数早晨都悄悄想着不要醒来。

模式 4 是帖子结尾的希望覆盖广泛功能受损。描述严重功能受损（学业崩溃、无法维持日常作息、社交退缩）的帖子，有时以一句希望性陈述结尾（例如 "my therapist said maybe I shouldn't give up"），LLM 锚定于这个末尾积极信号（与近因偏差一致）并预测为 _Stable_，而金标准标签追踪整篇帖子的广泛受损。模式中的 _Whole-Post Evidence Weighting_ 规则通过要求 LLM 权衡主导临床图景而非末尾情绪来处理此问题；零样本比较（@tab-zeroshot）显示完整模式使 _Stable_ F1 提高 +0.116，这与减少将受损帖子过度分配为 _Stable_ 的情况一致。_合成案例：_ 用户报告一个月没有上任何课、本周几乎没有进食、失去回复朋友的能力，最后写道 "maybe tomorrow will be different"；金标准基于广泛受损为 _Depressive_，LLM 预测为 _Stable_。

模式 5 涉及物质诱发激活与内源性心境的区分。当用户描述明确归因于物质的心境升高（例如咖啡因诱发的欣快，被描述为 "on top of the world"）时，LLM 可能将这些线索解释为轻躁狂心境，而金标准标签区分急性药理性激活与内源性基线。模式中的 _Substance vs. Endogenous Mood_ 规则处理该边界，并覆盖 _Recurrent-Pattern Exception_，即对常见物质的不寻常反应性本身可能属于双相谱系。该模式在留出子集中较少见；该规则的主要作用是防止对归因于物质的帖子作出错误的 _Hypomanic_ 预测。_合成案例：_ 用户写道喝了第四杯咖啡后突然觉得 "unbeatable and ready to overhaul" 自己的公寓，将这种上冲归因于咖啡因并预期晚上会崩溃；金标准为 _Stable_（急性、外部造成、自我标记），LLM 基于表面线索预测为 _Hypomanic_。

模式 6 是 _Uncertain_ 掩盖嵌入的临床信号。_Uncertain_ 在绝大多数情况下功能恰当；此处描述的失败较少见。LLM 正确识别帖子为元评论或信息性内容，却未能显露嵌入其中的临床重要内容。_合成案例：_ 用户写了一段批评网络上如何呈现康复的元评论，并在论证中途以括号形式提到自己一直在考虑结束生命；金标准为 _Depressive_，LLM 因元讨论语体默认 _Uncertain_。_SAFETY OVERRIDE_ 规则通过在危机级语言出现时无论整体框架如何均强制 _Depressive_，从而缓解该模式。与模式 3 类似，该规则在留出子集上有效：没有危机级帖子被分类为 _Uncertain_。


= 纵向示范：周期级心境趋势 <pilotsec>

我们通过 Reddit API 持续抓取三个 BD 主题 subreddit（r/bipolar、r/BipolarReddit、r/bipolar2），检索每位活跃作者的完整发帖历史（帖子和评论），并定期重新抓取以捕捉持续活动。在 @resourcesec 所述患者验证之后，verified+probable 队列包含 124 名候选作者中的 115 名。排除少于两个包含帖子的 14 天周期的用户（即纵向跨度不足以进行趋势分析）。剩余 105 名用户贡献了 2,611 篇帖子和 12,812 条评论，时间跨度为 2019 年 4 月至 2026 年 5 月，形成 1,794 个有效分析周期。

#figure(
  image("fig_timeline.svg", width: 100%),
  caption: [四名匿名用户的心境轨迹（A：以抑郁为主并伴随波动，49 个周期；B：偏轻躁狂且频繁出现躁狂转换，74 个周期；C：躁狂主导并伴随快速循环，36 个周期；D：发帖密集且混合特征发生率高，25 个周期）。每个条形为一个 14 天周期；细黑边标记 `with_mixed_features`。条形上方圆点为逐帖标注，按帖子状态着色。状态与趋势编码参见图例。],
) <fig-user-timeline>

多数 14 天窗口显示 `NO_TREND`（83.9%）；`TOWARDS_DEPRESSION` 和 `TOWARDS_MANIA` 分别占 5.9% 和 4.3%。_Stable_ 和 _Depressive_ 状态占主导（分别为 42.6% 和 31.4% 的周期），而躁狂极状态所占比例较小（_Hypomanic_ 8.8%、_Manic_ 3.0%）。这些分布在 @discussionsec 中进行解释。

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    align: top,
    table(
      columns: 3,
      align: (left, right, right),
      stroke: none,
      table.hline(),
      table.header(
        [*趋势方向*], [*周期数*], [*%*],
      ),
      table.hline(stroke: 0.5pt),
      [NO\_TREND],            [1,506], [83.9%],
      [FLUCTUATING],          [106],   [5.9%],
      [TOWARDS\_DEPRESSION],  [105],   [5.9%],
      [TOWARDS\_MANIA],       [77],    [4.3%],
      table.hline(),
    ),
    table(
      columns: 3,
      align: (left, right, right),
      stroke: none,
      table.hline(),
      table.header(
        [*主导状态*], [*周期数*], [*%*],
      ),
      table.hline(stroke: 0.5pt),
      [Stable],     [765], [42.6%],
      [Depressive], [564], [31.4%],
      [Hypomanic],  [157], [8.8%],
      [Manic],      [54],  [3.0%],
      [Uncertain],  [254], [14.2%],
      table.hline(),
    ),
  ),
  caption: [105 名用户队列的周期级分布（$n = 1,794$）：趋势方向（左）和主导状态（右）。`with_mixed_features` 说明符被应用于 84 个周期（4.7%）。],
) <tab-pilot-dists>

帖子（submissions，$n = 2,611$）承载了多数极性状态标签：36.8% _Depressive_、10.6% _Hypomanic_、3.8% _Manic_、46.6% _Stable_、2.2% _Uncertain_。评论（$n = 12,812$）主要是会话性回复，以 _Stable_ 为主（88.1%），极性状态仅占评论的 8.9%。帖子--评论不对称及其含义在 @discussionsec 中讨论。


= 讨论 <discussionsec>

从趋势分布（@pilotsec）可见四点观察。（1）`TOWARDS_MANIA` 和 `TOWARDS_DEPRESSION` 趋势较少见，但属于最具临床意义的信号，因为它们标记发作起始，此时干预最具影响。（2）`FLUCTUATING` 周期可能对应快速循环或混合表现，而单帖标签无法捕捉这些现象。（3）逐帖状态与周期级趋势共同支持分层建模：根据逐帖特征序列预测下一周期的轨迹。（4）主导状态分布保留了足够的躁狂极表示（_Hypomanic_ 8.8%、_Manic_ 3.0%），与基于 MDD 筛选的队列形成对照（BD-Risk：89.0% 为抑郁极）；这种平衡对于必须区分躁狂极与抑郁状态的下游模型很重要。趋势分布与长期 BD 队列研究 @grande2016bipolar 大体一致，同时反映了 Reddit 社群的选择偏差和发帖偏差；直接外部验证需要周期级专家标注。一个互补方向是建模 `NO_DATA` 周期中的缺失信号：在数字表型研究中，发帖减少有时与抑郁相关 @faurholt2018smartphone，但这种关系具有异质性，因此缺失建模需要超出文本流水线的发帖频率基线。

帖子和评论差异显著：51.2% 的帖子携带极性状态，而评论中仅有 8.9%，并且评论以 _Stable_ 为主（88.1%）。帖子是较长形式的披露，而评论是短回复。由此产生两个下游含义：在评论占比较高的语料上，逐帖分类器可能在 _Stable_ 上显得过度自信，因此按内容类型报告指标优于单一汇总指标；轨迹模型应当上调帖子的权重，或依赖周期级主导状态标注（其已经在窗口内聚合不同内容类型）作为主要轨迹信号。

LLM 在留出子集上对 _Depressive_ 达到 87.9% 召回率，但对 _Hypomanic_ 和 _Manic_ 仅达到 35.7% 和 6.7%。两个因素共同造成这种不对称。第一是模型特性：抑郁语言具有典型表面标记（负性、自我聚焦、绝望），而躁狂极状态常通过_被描述的行为_体现（挥霍、睡眠需求减少、夸大计划），且可由任何语调叙述；LLM 读取的是语调而非所描述行为的临床意义（见 @errorsec 中模式~1）。第二是 BD-Risk 标注规则中的标签--文本一致性问题：如 #cite(<lee2024detecting>, form: "prose")（第~3.2 节）所述，"posts exhibiting both manic and depressive moods are regarded as manic moods"，这是一种非对称平局规则，会将任何混合躁狂+抑郁帖子提升至躁狂侧。结合该数据集的 MDD$arrow$BD 筛选标准，这产生了金标准 _Manic_（$+$3）帖子，其文本内容符合 BD-Risk 自身对 $-$3 的定义（"extreme anxiety and having suicidal thoughts"）。一个采用临床安全先验的单帖 LLM（将明确自伤内容分类为 _Depressive_）会系统性地在这些帖子上表现较差，因为它能够看到的唯一信号正是标签规则所覆盖的内容。跨模型评估（@crossmodelsec）为结构性解释提供了直接证据：在来自五家供应商的六个 LLM 中，_Manic_ 召回率从 0.0%（DeepSeek V4 Pro、GLM-5.1）到 20.0%（Gemini 3.5 Flash），且监督式 ModernBERT 基线平均为 4.0%（@bertsec）；所有架构都收敛于相同的躁狂极下限。因此，@tab-state-metrics 中的 Manic 召回率上限反映的是结构性不匹配，而非仅仅是模型限制（下游影响见局限性）。

= 局限性

所提出的方法和语料受到若干限制，我们将其归为评估范围、金标准状态推导、躁狂极可解释性、队列界定和发布时可靠性。

跨模型评估（@crossmodelsec）确认了该模式在五个额外 LLM 上的可移植性（完整 145 条留出集上 macro F1 0.432--0.564），然而该语料本身完全使用 Gemini 3.1 Pro 进行标注；逐类可靠性估计因此仍然是 Gemini 特有的。量化验证也仅在逐帖层面进行，因为可供研究使用且规模足够的逐帖专家标注 BD 数据集很少（BD-Risk 是通过正式数据请求和伦理审查获得的，类似共享任务语料也面临相近的访问障碍）；周期级趋势作为本方法的关键贡献，尚未得到外部验证。

金标准状态是通过确定性映射（@tab-mapping）从 BD-Risk 有序心境标签推导而来，而非由专家直接标注为类别状态。这引入了边界不精确性（例如心境标签 $+$1 可能反映轻度轻躁狂而非稳定心境，且有序强度分数不一定与类别型临床判断对应），将有序标签（专家间 Krippendorff's $alpha$ = 0.87）映射为类别状态会放大边界处的分歧。因此，一些表面误分类可能是映射伪影，报告的准确率应被解读为该模式真实可靠性的下界。

两个因素限制了 Manic 极数字的解读。第一，留出 _Manic_ 类规模较小（$n=15$，因为整个 BD-Risk 数据集仅包含 28 条心境-$+$3 帖子）；Manic-F1 估计的 95% 置信区间较宽（约 $plus.minus$ 13 个百分点），因此不应将较小 Manic-F1 差异解释为显著。第二，6.7% 的 Manic 召回率上限受到 BD-Risk 非对称平局规则与逐帖分类器可见文本证据之间结构性不匹配的限制（完整分析见 @discussionsec）；恢复标签--文本一致性需要在仅文本标准下重新标注，或采用能够提供标注者所见时间上下文的纵向评估协议。

患者验证由 LLM 完成，筛选用户发帖历史中的自我披露 BD 诊断，而非提供临床确认；该做法遵循既有 BD 社交媒体数据集 @sekulic2018not @jagfeld2021understanding 的纳入模型，同时比单帖成员规则采用更严格的逐用户证据门控。该队列可能包含描述未经确认诊断的 `verified` 或 `probable` 用户，也可能排除从不披露诊断的 BD 用户；Reddit 是一种自选择、异步渠道，其帖子与临床观察到的心境状态之间的关系需要进一步研究。需要临床医生确认状态的下游使用应将该队列视为经 LLM 筛选的自我认同样本，而非临床队列。

所有标注完全由 LLM 生成，未经人工抽查。逐类可靠性从 _Depressive_ 到 _Hypomanic_ 再到 _Manic_ 递减（见 @tab-state-metrics）；鉴于支持度较小以及上述躁狂极可解释性限制，应谨慎使用 _Manic_ 标签。

= 结论

验证结果区分了所提出方法的两个失败来源：87.9% 的抑郁召回率表明该模式以合理覆盖率捕捉主要抑郁极标记，而 6.7% 的躁狂召回率似乎强烈受到躁狂极结构性标签--文本一致性问题的影响，而非仅仅是提示本身造成（见 @discussionsec）。由于周期级不存在外部纵向真值，该语料的 1,794 条轨迹只能通过其逐帖组成部分得到间接验证。由此产生三个近期优先事项：（1）专家标注周期级趋势，以实现直接纵向验证；（2）跨心境状态、置信水平和趋势方向进行分层人机协同审计，并以标注者间一致性形式报告；（3）使用更高性能模型（例如在跨模型评估中达到 0.564 的 Gemini 3.5 Flash）重新标注该语料以改善躁狂极覆盖率，并结合针对 @errorsec 模式~1 所记录行为线索识别失败的定向提示修订。所得语料旨在用于计算心理健康研究，不应作为临床诊断工具使用。

= 伦理考量 <ethicssec>

本研究分析公开发布的社交媒体内容，其中涉及敏感心理健康经历。研究方案已由筑波大学研究伦理委员会审查并批准（批准号~25-188）。我们还遵守 Reddit 隐私政策以及社交媒体研究伦理指南 @harrigian2021state。

在公开发布之前，所有帖子内容都经过基于 LLM 的去标识化处理，涵盖五个按风险排序的 PII 类别（标识符、准标识符、联系信息、关联码、个人识别码），每个检测到的片段替换为类别特定占位符。与基于规则或 NER 的方法不同，LLM 还能检测累积的长跨度准标识符（多个单独看似无害的细节如职业、地点、家庭结构等共同缩小到某一个人），同时保留临床相关内容（药物名称、诊断、症状、相对时间表达）。完整分类法和提示发布在补充仓库中。

数据集仅保留心境状态标注所需的文本内容和时间信息；作者用户名被替换为匿名标识符，可能促进再识别的 subreddit 成员身份和帖子元数据从发布数据集中排除。为降低基于搜索的再识别风险，发布的时间线使用相对时间偏移而非精确发帖时间。由于基于 LLM 的去标识化可能遗漏残留准标识符，公开发布以对分层样本进行发布前隐私审计为条件。该数据集仅用于计算心理健康研究，不得用于再识别、商业画像或未经适当专家监督的临床决策。

// Appendix: per the Springer proceedings instructions, a single appendix is
// designated "Appendix" (unnumbered), placed before the references, and
// referred to in the text. (Multiple appendices would be "Appendix 1", etc.)
#set heading(numbering: none)

= 附录

四类系统提示驱动该流水线：（A）逐帖标注提示，包含完整的基于 DSM-5 的模式和八个合成少样本示例；（B）14 天周期级趋势提示；（C）患者验证提示；以及（D）去标识化提示。提示（A）的最小零样本变体用于模式贡献比较（@evaldesignsec）。完整提示文本、流水线源码和评估脚本发布在 #link("https://anonymous.4open.science/r/bd-state-annotation/")。
