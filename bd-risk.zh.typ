#import "@preview/fine-lncs:0.6.3": lncs, institute, author, theorem, proof

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
    双相障碍（bipolar disorder, BD）常被误诊为重性抑郁障碍，持续监测心境状态_转变_对于及时干预至关重要。现有用于 BD 研究的社交媒体数据集通常只提供二元诊断标签或逐帖心境评分；能够捕捉心境轨迹的资源仍然有限。由于专家标注成本高昂，且微调需要稀缺的标注数据，我们提出一种无需任务特定训练的少样本提示式 LLM 方法。该标注模式以 DSM-5 发作标准为基础，并配有八个合成少样本示例，使该方法能够直接应用于其他 BD 语料。该方法在两个粒度上标注帖子：逐帖心境状态和 14 天周期级趋势（主导状态、趋势方向、变化点），从而支持仅凭逐帖标签无法完成的轨迹建模。逐帖分类在 BD-Risk 数据集 @lee2024detecting 上进行外部验证，验证集为 145 篇帖子组成的留出、作者互斥、分层子集，取得 0.519 的宏平均 F1；抑郁召回率较高（87.9%），躁狂极召回率较低（35.7%/6.7%）。本文刻画了六类错误模式，其中包括躁狂极处限制可达到躁狂召回率的结构性标签—文本一致性问题。随后，我们使用 Gemini 3.1 Pro，将该方法应用于 BD 主题 subreddit 中 105 名自我报告 BD 用户（1,794 个 14 天周期，15,423 篇帖子和评论，2019 年 4 月至 2026 年 5 月），观察到抑郁极占主导，这与 BD 相关在线讨论的临床预期大体一致。
  ],
  keywords: ("双相障碍", "大语言模型", "少样本提示", "社交媒体", "临床自然语言处理", "心境轨迹"),
  bibliography: bibliography("refs.bib"),
)


= 引言

双相障碍（BD）的特征是躁狂、轻躁狂和抑郁发作反复出现，影响全球 1--2% 的人口 @grande2016bipolar。据估计，17--50% 的 BD 病例最初被误诊为重性抑郁障碍（MDD），因为患者通常在抑郁发作期间寻求帮助，并且可能不会把躁狂或轻躁狂状态识别为病理性状态 @hirschfeld2002guideline @vieta2018misdiagnosis。这种误诊会导致不恰当治疗（例如抗抑郁药单药治疗，可能诱发躁狂转换），并延误适当干预。

Reddit 等社交媒体平台承载了 BD 社群（例如 r/bipolar、r/BipolarReddit），用户在其中公开讨论症状、治疗和日常功能。既有研究已使用这些数据进行 BD 与 MDD 分类 @cohan2018smhd @coppersmith2015clpsych @sekulic2018not，然而现有数据集仅提供二元诊断标签（BD vs.~MDD）或用户级风险评分。能够提供随时间追踪的帖文级心境状态标签的资源仍然较少，这限制了关于心境轨迹的计算研究，并进一步限制了关于 BD 进展和早期干预的研究。

构建专家标注的 BD 语料成本很高：心境状态标注需要精神医学专业知识，而标注数据稀缺使微调方法难以扩展。同时，大语言模型（LLM）的近期进展表明，它们可以在文本标注任务中以较合理的准确性遵循人类编写的指南 @gilardi2023chatgpt。这促成了我们的思路：如果 LLM 能够内化提示中呈现的临床指南，那么一个经过精心设计、以 DSM-5 为基础并包含合成少样本示例的提示，应当能够在_没有任务特定微调或标注训练数据_的情况下完成心境状态标注，使该方法可直接应用于新的 BD 语料。

近期研究已将 LLM 应用于心理健康 NLP 任务 @xu2024mental @yang2024mentallama；然而，它们是否能够以专家级准确性分类 BD 心境状态，尤其是从文本中难以检测的躁狂极状态，尚未得到确认。

本文提出一种基于少样本提示的 LLM 方法，用于社交媒体中 BD 的纵向心境状态分析，并展示其在 Reddit 队列上的应用。我们从 BD 主题 subreddit（r/bipolar、r/BipolarReddit、r/bipolar2）中收集自我报告 BD 诊断用户的 Reddit 帖子，并在两个粒度上进行标注：（1）逐帖心境状态（_Depressive_、_Stable_、_Hypomanic_、_Manic_）和（2）14 天周期级心境趋势（主导状态、趋势方向、变化点）。标注模式遵循 DSM-5 发作标准，并以 LLM 流水线（Gemini 3.1 Pro）实现。我们使用 BD-Risk 数据集 @lee2024detecting，在 145 篇帖子组成的留出、作者互斥、分层子集上验证逐帖标注，取得 0.519 的宏平均 F1，其中抑郁召回率为 87.9%，轻躁狂/躁狂召回率为 35.7%/6.7%。不同心境极之间的召回率不对称既反映了一项已知模型属性（躁狂侧状态常通过所描述行为而非情感语调表现出来），也反映了源数据集躁狂极标签中的结构性标签—文本一致性问题。

本文贡献如下：
+ *方法：* 提出一种以 DSM-5 为基础的少样本提示模式，用于基于 LLM 的两个时间粒度心境状态标注（逐帖状态和 14 天周期级趋势），无需微调或标注训练数据。
+ *评估：* 在 BD-Risk 专家标注数据集 @lee2024detecting 的留出、作者互斥、分层子集上，对逐帖状态分类进行外部验证，宏平均 F1 为 0.519（抑郁召回率 87.9%，轻躁狂召回率 35.7%，躁狂召回率 6.7%），并辅以零样本基线比较和跨模型可行性探查。
+ *示范：* 将该方法应用于 BD 主题 subreddit 中的 105 名自我报告 BD 用户（1,794 个 14 天周期，15,423 篇帖子和评论，时间跨度为 2019 年 4 月至 2026 年 5 月），生成纵向心境轨迹标注，其分布与 BD 相关在线讨论的临床预期大体一致。


= 相关工作

== BD 中的纵向心境监测

追踪 BD 心境轨迹的临床努力在很大程度上依赖生态瞬时评估（EMA）以及使用智能手机传感器和自评应用的数字表型 @faurholt2018smartphone @torous2016new。这些方法能够产生密集、高频的心境信号；然而，它们需要患者主动入组并提供同意，因此限制了队列规模和外部使用。社交媒体提供了一种互补的非侵入式来源：对于已经在讨论自身状况的用户，它能够提供跨越数月到数年的被动、自然产生的语言数据。公开可用且具有周期级心境轨迹标注的社交媒体语料仍然有限，这约束了纵向 BD 分析的方法开发。

== 心理健康检测中的社交媒体

De Choudhury 等人~@dechoudhury2013predicting 表明，社交媒体信号能够预测抑郁发作。SMHD 数据集 @cohan2018smhd 通过自我报告诊断覆盖九类心理健康状况；Coppersmith 等人~@coppersmith2015clpsych 建立了基于 X (formerly Twitter) 的抑郁和 PTSD 检测共享任务。

对于 BD，Sekuli\'c 等人~@sekulic2018not 提出了基于 Reddit 的分类方法，Jagfeld 等人~@jagfeld2021understanding 汇编了一个大型 BD Reddit 语料；然而，两者均依赖未经专家验证的自我报告诊断 @harrigian2021state @chancellor2020methods。BD-Risk 数据集 @lee2024detecting 提供由精神科医生和临床心理学家验证的逐帖心境标签；我们将其作为逐帖验证的金标准。

== 面向临床 NLP 与心理健康的 LLM

Xu 等人~@xu2024mental 评估了 LLM 从在线文本预测心理健康状态的能力；Yang 等人~@yang2024mentallama 对 MentalLLaMA 进行了微调，以支持可解释的心理健康分析。Lee 等人~@lee2024detecting 发现，ChatGPT 在 BD 风险检测上的 F1 仅为 0.130（相比之下，其多任务模型为 0.578），表明现成 LLM 在 BD 特定任务上仍面临困难。对于 LLM 标注质量这一更一般的问题，Gilardi 等人~@gilardi2023chatgpt 表明，ChatGPT 在文本标注任务中可以达到或超过众包工人的表现；我们的工作沿着这一路径，将 LLM 视为标注者（而非分类器），并将其输出锚定在明确的 DSM-5 派生模式中。

我们的工作不同于上述评估，因为我们并不预测诊断。相反，我们提出一种基于提示的方法，用于_标注_逐帖心境状态和周期级趋势，并用专家标签验证这些标注。错误分析（@errorsec）刻画了该模式必须应对、且下游用户应保持关注的失败模式。


= 方法

== 方法概述 <resourcesec>

所提出的方法以来自心理健康相关社交媒体社区的用户发帖历史为输入，并在两个时间粒度（逐帖状态和 14 天周期级趋势）上生成心境状态标注。@fig-pipeline 展示了端到端流程：通过基于 LLM 的患者验证识别候选用户，随后使用两个基于 DSM-5 的提示进行结构化标注。

#figure(
  {
    import "@preview/fletcher:0.5.8": diagram, node, edge

    // Muted-academic palette: distinct hues for the pipeline roles.
    let c_data    = "#1F4E79"
    let c_verify  = "#2E7D32"
    let c_annot   = "#7030A0"
    let c_post    = "#1F4E79"
    let c_trend   = "#C65911"

    // Inline line-art icons, preserved from the original figure.
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
      + "<circle cx='9' cy='9' r='1.2'/><circle cx='15' cy='9' r='1.2'/>"
      + "<circle cx='9' cy='15' r='1.2'/><circle cx='15' cy='15' r='1.2'/>"
      + "<line x1='9' y1='9' x2='15' y2='9'/><line x1='9' y1='15' x2='15' y2='15'/>"
      + "<line x1='9' y1='9' x2='9' y2='15'/><line x1='15' y1='9' x2='15' y2='15'/>")

    let make_box(pos, icon_paths, color, title, body_lines, width: 22mm) = node(
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
    )

    let elabel(body) = box(fill: white, inset: (x: 1.5pt, y: 0.5pt), align(center, text(size: 6pt)[#body]))

    let prompt_subbox(header, task, rules, schema) = box(
      stroke: 0.45pt + rgb(c_annot),
      radius: 1.5pt,
      inset: 3pt,
      width: 100%,
      {
        set par(first-line-indent: 0pt, leading: 0.4em, justify: false)
        set text(hyphenate: false)
        stack(dir: ttb, spacing: 2pt,
          align(center, text(weight: "bold", size: 6.5pt, fill: rgb(c_annot))[#header]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *任务：* #task]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *规则：* #rules]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *输出模式：* #schema]),
        )
      },
    )

    let llm_prompts = node(
      (2, 0),
      {
        set par(first-line-indent: 0pt, justify: false)
        set text(hyphenate: false)
        stack(dir: ttb, spacing: 3pt,
          align(center, text(weight: "bold", size: 9pt, fill: rgb(c_annot))[LLM 提示]),
          grid(
            columns: (1fr, 1fr),
            column-gutter: 3pt,
            prompt_subbox(
              [A. 单帖提示],
              [独立分类每条帖子],
              [DSM-5，安全覆盖，行为优先于语调],
              [state, opposite\_pole\_symptoms, specifiers, confidence, reasoning],
            ),
            prompt_subbox(
              [B. 14 天趋势提示],
              [分析每个 14 天周期],
              [全周期加权，混合特征],
              [dominant\_state, trend\_direction, change\_points, trend\_summary, confidence],
            ),
          ),
        )
      },
      width: 56mm,
      fill: white,
      stroke: (paint: rgb(c_annot), thickness: 0.9pt, dash: "dashed"),
      corner-radius: 2pt,
      inset: 4pt,
    )

    let json_box(pos, color, title, fields, width: 32mm) = node(
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
    )

    align(center, scale(x: 74%, y: 74%, reflow: true,
      diagram(
        spacing: (5mm, 2mm),
        edge-stroke: 0.6pt + black,
        mark-scale: 60%,

        make_box((0, 0), icon_globe, c_data, [数据收集],
          ([Reddit API], [3 个 BD subreddit]), width: 20mm),
        edge((0, 0), (1, 0), "-|>", elabel[124 名候选者]),

        make_box((1, 0), icon_shield, c_verify, [患者验证],
          ([LLM 证据], [三级分类器]), width: 22mm),
        edge((1, 0), (2, 0), "-|>", elabel[115/124 纳入]),

        llm_prompts,
        edge((2, 0), (3, 0), "-|>"),

        make_box((3, 0), icon_brain, c_annot, [Gemini\ 3.1 Pro],
          ([DSM-5 指导], [标注]), width: 22mm),

        edge((3, 0), (3.3, 0), "-"),
        edge((3.3, -0.55), (3.3, 0.55), "-"),
        edge((3.3, -0.55), (4, -0.55), "-|>", mark-scale: 120%),
        edge((3.3,  0.55), (4,  0.55), "-|>", mark-scale: 120%),

        json_box((4, -0.55), c_post, [逐帖输出],
          ("state", "specifiers", "confidence", "reasoning"), width: 30mm),

        json_box((4, 0.55), c_trend, [周期级输出],
          ("dominant_state", "trend_direction", "change_points", "trend_summary", "confidence"), width: 30mm),
      )
    ))
  },
  caption: [标注流水线：用户发帖历史 $arrow$ LLM 患者验证（三级分类器）$arrow$ Gemini 3.1 Pro 使用两个基于 DSM-5 的提示进行标注（单帖 + 14 天趋势）$arrow$ 在两个时间粒度上输出结构化 JSON。],
) <fig-pipeline>

*患者验证。* 在心理健康相关 subreddit 发帖是必要但不充分的 BD 诊断信号：许多此类帖子来自临床工作者、家属或一般社群参与者。为筛选候选池，我们应用一个 LLM 三级分类器（Gemini 3.1 Pro，独立提示），扫描每位作者的完整发帖历史，并返回 `verified`（明确的第一人称诊断陈述，例如 “I was diagnosed with bipolar II in 2019”，或具体治疗/住院叙述）、`probable`（通过症状、药物或社群成员语气体现的一致自我认同，但没有明确诊断陈述），或 `unverified`（无诊断信号）。只有 `verified` 和 `probable` 层级被纳入标注队列；这与既有 BD 社交媒体数据集 @sekulic2018not @jagfeld2021understanding 的纳入模型一致，同时比单帖成员规则采用更严格的逐用户证据门控。

== 标注模式 <frameworksec>

我们的标注模式借鉴 DSM-5 发作定义 @apa2013dsm5，并将其操作化为面向 LLM 标注的结构化提示框架。以下规则是在针对外部专家标签的错误分析基础上迭代形成的（见 @errorsec）；下文命名的每条临床指导规则都是对其中某类反复出现失败模式的模式性回应。由于 BD-Risk 数据使用协议禁止逐字复现帖子文本，错误分析使用合成案例说明每种模式，同时保留原始分歧中具有临床相关性的结构。

=== 逐帖状态分类

对于每条单独帖子（发帖或评论），LLM 从五个选项中分配一个类别型心境状态：

- *Manic：* 夸大、压力性书写（长串句、过度大写）、意念飘忽（离题的话题跳转）、极端易激惹或欣快。
- *Hypomanic：* 能量与节奏升高但仍保持连贯，社交去抑制，没有精神病性特征的不寻常强度。
- *Depressive：* 语言收缩、绝对化语言（“never”“nothing”）、高度自我聚焦（第一人称代词）、认知扭曲、自杀意念。
- *Stable：* 情绪语调平衡、元认知反思、反应相称、支持社群的语言。
- *Uncertain：* 仅用于真正无法解释的帖子；LLM 必须在诉诸该标签之前尝试分类。

该框架还支持 `with_mixed_features` 说明符（遵循 DSM-5 混合特征标准）。在应用该说明符之前，提示要求 LLM 抽取明确的相反极症状列表，并且只有在记录到三个或更多明确相反极症状时才分配 `with_mixed_features`。这一证据抽取步骤避免将混合特征说明符用作模糊的中性标签。

=== 周期级趋势分析

为了进行纵向心境轨迹建模，我们将每位用户的发帖历史划分为连续的固定长度周期（默认：14~天）。14 天窗口长度是在临床顾问协助下确定的，并以 DSM-5 发作持续时间标准为依据：重性抑郁发作至少持续两周，躁狂发作至少持续一周 @apa2013dsm5；因此，14 天窗口能够覆盖完整抑郁发作的最短持续时间，并允许观察躁狂发作的起始与进展。周期锚定在用户第一条帖子（第 0 天），并以严格的半开区间 $[t_(k), t_(k) + 14)$ 前进；帖子和评论共同分配到包含其时间戳的周期。定义从用户第一条到最后一条帖子之间的所有周期；没有帖子的周期被赋予 `NO_DATA` 标签而不是跳过，从而为轨迹建模保留连续时间网格。@fig-period-slicing 展示了该划分。

#figure(
  {
    let s_dot = circle(radius: 1.6pt, fill: black, stroke: none)
    let c_dot = circle(radius: 1.6pt, fill: white, stroke: 0.5pt + black)
    let dots(..kinds) = stack(
      dir: ltr,
      spacing: 4pt,
      ..kinds.pos().map(k => if k == "S" { s_dot } else { c_dot }),
    )
    let cell(body) = box(width: 100%, height: 13mm, stroke: 0.4pt + black, inset: 3pt, align(center + horizon, body))
    let nodata_cell = box(width: 100%, height: 13mm, stroke: 0.4pt + black, fill: luma(240), inset: 3pt, align(center + horizon, text(size: 7pt, style: "italic", fill: luma(80))[NO\_DATA]))

    grid(
      columns: (1fr,) * 6,
      column-gutter: 0pt,
      row-gutter: 3pt,
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
  caption: [周期划分（示意）：固定 14 天窗口锚定于用户第一条帖子（第 0 天）。帖子（实心圆）和评论（空心圆）落入包含其时间戳的周期；空周期（周期 3）保留 `NO_DATA` 标签，而不是被跳过。],
) <fig-period-slicing>

对于每个至少包含一条帖子的周期，LLM 分析其中收集的帖子并生成：

- *主导状态：* 该周期内的主要心境状态（与逐帖层面相同的五分类集合），在窗口内所有帖子上聚合。
- *趋势方向：* `NO_TREND`（状态维持）、`TOWARDS_MANIA` / `TOWARDS_DEPRESSION`（逐步向相应极端恶化），或 `FLUCTUATING`（交替出现但无明确方向）。
- *变化点：* 心境转变发生的具体日期或事件，并记录转变前后的状态。
- *趋势摘要：* 简要叙述该周期轨迹以及支持主导状态的证据。
- *DSM-5 说明符：* 当相反极症状在周期内共同出现时标记 `with_mixed_features`（区别于序列性波动）。

这两个粒度共同支持事件层面分析（例如，状态变化之前发生了什么）和纵向轨迹建模；明确的变化点字段还使文本层面的变化点检测成为可能 @truong2020selective。

=== 少样本示例构建 <fewshotsec>

逐帖提示配有八个合成少样本示例（标记为 A--H），由作者编写，且从未来自 BD-Risk。每个示例都演示一条针对开发过程中观察到的失败模式的模式规则（完整分析见 @errorsec）：A 展示回顾性躁狂侧叙述中的 _Behavior Over Tone_；B 和~E 展示带有夸大性躁狂例外的 _SAFETY OVERRIDE_ 规则；C 和~D 对比 _Improvement-Narrative_ 与 _Whole-Post Evidence Weighting_；F 抑制短帖中默认转向 _Uncertain_ 的倾向；G 展示物质诱发轻躁狂的 _Recurrent-Pattern Exception_；H 演示用于区分 _Hypomanic_ 与 _Stable_ 边界的 _Severity Descriptors_。每个示例都给出输入文本以及完整预期 JSON 输出（包括 `opposite_pole_symptoms` 证据列表和推理），因此模型可以同时观察目标标签和证据链。完整文本在附录中复现。

= 验证实验

== 针对 BD-Risk 的外部验证 <validsec>

=== BD-Risk 数据集

BD-Risk 数据集 @lee2024detecting 包含来自 1,025 名用户的 7,346 条 Reddit 帖子，每条帖子都带有精神科医生指导的 7 点心境水平标签（$-$3 至 $+$3）。由于该数据集通过初始 MDD 表现招募用户（MDD-only 与 MDD$arrow$BD 组），其结构上富含抑郁极内容（88.9% 的帖子 $lt.eq 0$）。

=== 金标准状态推导

BD-Risk 数据集只提供有序心境标签；类别型状态并未被直接标注。为获得评估用金标准状态，我们根据 @tab-mapping 所示映射从 BD-Risk 心境标签推导类别。

#figure(
  table(
    columns: 3,
    align: (center, center, left),
    stroke: none,
    table.hline(),
    table.header([*BD-Risk 心境标签*], [*推导金标准状态*], [*说明*]),
    table.hline(stroke: 0.5pt),
    [$-$3, $-$2, $-$1], [Depressive], [],
    [0, $+$1], [Stable], [$+$1 = 正常范围内的高动机 / 积极心境],
    [$+$2], [Hypomanic], [无精神病性的明确躁狂侧激活],
    [$+$3], [Manic], [带精神病性特征的严重躁狂表达],
    table.hline(),
  ),
  caption: [从 BD-Risk 7 点心境标签到推导金标准状态的映射。该映射将 $+$1 视为正常积极范围（Stable），而非病理性激活。],
) <tab-mapping>

#pagebreak()

=== 评估集构建

完整 BD-Risk 数据集呈现高度偏斜的心境分布（88.9% 的帖子 $lt.eq$ 0）。由于部署任务是 BD 风险检测而非一般心境分类，我们有意过采样躁狂极帖子，使得代表性不足类别的逐类指标具有足够支持度。

我们将已标注帖子分为两个互斥子集。_开发_子集（314 条帖子）用于提示设计和失败模式分析。_保留_子集（145 条帖子）专门用于下文报告的评估；它与开发子集_作者互斥_，通过从不在开发子集中的 BD-Risk 作者中分层抽样得到，并设置配额以确保四个推导金标准状态均有足够的逐类支持（$60$ Depressive、$40$ Stable、$30$ Hypomanic、$15$ Manic）。@bdresultsec 中所有指标均在保留子集上计算；开发子集从不用于产生报告数字。BD-Risk 中躁狂极金标准帖子几乎全部来自 MDD$arrow$BD 组，因此保留的躁狂侧样本在结构上来自 MDD$arrow$BD（该限制在 @discussionsec 中讨论）。

== 评估指标 <metricssec>

本文将 BD-Risk 数据集中的专家分配标签称为金标准标签，将 LLM 输出称为预测。金标准状态通过 @tab-mapping 中的映射从 BD-Risk 心境标签推导而来。

我们报告逐类精确率、召回率和 F1，以及总体准确率、宏 F1 和混淆矩阵。报告两种准确率变体：_排除_ Uncertain 的准确率将 Uncertain 输出视为弃权，并从分子与分母中同时移除；_包含_ Uncertain 的准确率将 Uncertain 计为错误，从而提供保守下界。逐类精确率、召回率和 F1 均基于排除 Uncertain 的口径计算。所有指标均在完整评估集上计算。

== 评估设计 <evaldesignsec>

除主要的 BD-Risk 保留验证外，我们还进行三项附加评估，以刻画该模式的性质，并将其表现置于监督式替代方案的背景中：

- *零样本基线比较：* 为量化结构化标注模式（DSM-5 规则、少样本示例）相对于 LLM 基础能力的贡献，我们使用仅包含任务定义和输出格式的最小零样本提示重新评估同一模型。
- *跨模型可行性探查：* 为测试该模式能否推广到单一 LLM 供应商之外，我们还使用 OpenAI 的 GPT-5.5 评估完整模式，刻画模式可迁移性以及供应商层面内容政策差异对标注可行性的影响。
- *监督微调基线：* 为评估带标签数据的任务特定微调是否优于所提出的少样本方法，我们在 314 条训练池的逐步增大子集（$n in {50, 100, 200, 314}$）上微调 ModernBERT-base @warner2025modernbert，并在同一 145 条保留集上评估，从而在相同测试条件下进行直接比较。

== LLM 配置

我们通过官方 API 使用 Gemini 3.1 Pro @team2024gemini，并要求结构化 JSON 输出；选择该模型是因为其上下文窗口较大且原生支持结构化输出生成。每条帖子都使用完整标注模式和上述少样本示例作为系统指令进行独立处理；模型返回一个 JSON 对象，包含 `state`、`opposite_pole_symptoms`、`specifiers`、`confidence`（High/Medium/Low）和 `reasoning` 字段，其中 `opposite_pole_symptoms` 承载在分配 `with_mixed_features` 之前所需的明确证据列表（见 @frameworksec）。对于周期级标注，LLM 还返回 `trend_direction`、`change_points` 和 `trend_summary` 叙述，并以 0--1 的尺度给出 `confidence`。我们使用 Gemini 3.1 Pro 默认温度 1.0；模型未经过微调。

== 验证结果 <bdresultsec>

我们首先针对 BD-Risk 专家标签验证逐帖状态分类（@tab-state-metrics：逐类指标及宏聚合摘要）。

#figure(
  table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header([*状态*], [*精确率*], [*召回率*], [*F1*], [*支持度*]),
    table.hline(stroke: 0.5pt),
    [Depressive],     [0.630],   [*0.879*], [*0.734*], [58],
    [Stable],         [0.659],   [0.784],   [0.716],   [37],
    [Hypomanic],      [*0.833*], [0.357],   [0.500],   [28],
    [Manic],          [*1.000*], [0.067],   [0.125],   [15],
    table.hline(stroke: 0.5pt),
    [_宏平均_],       [_0.781_], [_0.522_], [_0.519_], [_138_],
    table.hline(),
  ),
  caption: [保留子集上的逐类指标与宏摘要（n=145；排除 7 个 Uncertain 后为 138）。排除/包含 Uncertain 的准确率 = 65.9 % / 62.8 %；由于该子集经过有意分层，宏 F1 是主要指标。],
) <tab-state-metrics>

抑郁召回率较高（87.9%），Stable 召回率中等（78.4%），而 Hypomanic 与 Manic 召回率仍然较低（35.7% 与 6.7%），表明 LLM 能正确识别大多数抑郁和稳定帖子，却漏掉了多数躁狂极病例。混淆矩阵（@tab-state-cm）明确显示主要错误流向：在 30 条金标准 Hypomanic 帖子中，12 条被预测为 Depressive，6 条被预测为 Stable；在 15 条金标准 Manic 帖子中，11 条被预测为 Depressive，2 条被预测为 Stable。Manic 到 Depressive 的错误流向是一种反复出现的模式，可能具有标签-文本来源，我们在 @discussionsec 中讨论。

#figure(
  table(
    columns: 7,
    align: (left, right, right, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [], table.cell(colspan: 6)[#align(center)[*预测*]],
      [*金标准*], [*DEP*], [*STA*], [*HYP*], [*MAN*], [*UNC*], [*合计*],
    ),
    table.hline(stroke: 0.5pt),
    [*Depressive*],  [*51*], [7],   [0],    [0],   [2], [60],
    [*Stable*],      [7],    [*29*],[1],    [0],   [3], [40],
    [*Hypomanic*],   [12],   [6],   [*10*], [0],   [2], [30],
    [*Manic*],       [11],   [2],   [1],    [*1*], [0], [15],
    table.hline(),
  ),
  caption: [保留子集上的状态混淆矩阵（行：推导金标准状态；列：LLM 预测）。DEP = Depressive，STA = Stable，HYP = Hypomanic，MAN = Manic，UNC = Uncertain。],
) <tab-state-cm>

这些 _Hypomanic_ 错误集中在金标准 $+$2 帖子上，其躁狂侧激活被负性语调掩盖，这是当前提示尚未完全解决的模式。

== 监督微调基线 <bertsec>

为给少样本 LLM 结果提供参照，我们与监督式基线进行比较。我们在同一 BD-Risk 训练池上微调 ModernBERT-base @warner2025modernbert（149M 参数），使用逐步增大的带标签子集（$n in {50, 100, 200, 314}$），并在相同的 145 条保留集上评估。每个档位训练 10 个 epoch，学习率为 $2 times 10^(-5)$，最大序列长度为 2,048 tokens；对于 50--200 档，我们报告五个随机训练集样本（种子 42--46）的均值和标准差，而 314 档使用全部可用训练样本，并报告五个随机初始化上的方差。@tab-bert-baseline 将这些结果与 LLM 条件并列汇总。

#figure(
  table(
    columns: 4,
    align: (left, left, right, right),
    stroke: none,
    table.hline(),
    table.header([*方法*], [*训练数据*], [*宏 F1*], [*相对少样本的 $Delta$*]),
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
  caption: [保留子集（$n = 145$）上的监督微调基线与 LLM 标注对比。ModernBERT 结果报告 5 个种子的均值 $plus.minus$ 标准差。少样本 LLM 使用八个合成示例，且不需要带标签训练数据。],
) <tab-bert-baseline>

ModernBERT 的宏 F1 随训练规模单调上升（0.306 $arrow.r$ 0.398），但即使在最大可用训练规模（$n = 314$）下，仍比 Gemini 少样本（0.519）低 0.121，并且仅接近 Gemini 零样本水平（0.459）。我们还在完整 314 条训练集上探索了 15 和 20 个 epoch；最佳配置（15 epochs：$0.454 plus.minus 0.038$）缩小了差距，但仍低于少样本结果。

逐类分析显示，ModernBERT 也具有 LLM 结果中观察到的相同躁狂极困难（@bdresultsec）：在五次 314 档运行中，_Manic_ 召回率平均为 0.04（5 次中有 2 次 _Manic_ 召回率为零），而 _Depressive_ 与 _Stable_ F1 平均分别为 0.51 和 0.62。这种平行现象表明，躁狂极限制更可能源于 BD-Risk 标签--文本关系（@errorsec，模式~1），而非某一模型架构的选择。

从实践角度看，为 BD 心境状态分类构建 314 条专家标注训练样本需要精神医学专业知识和大量标注工作。少样本 LLM 方法仅使用嵌入提示中的八个合成示例、无需人工标注训练数据，即取得更高表现。该比较支持所提出方法在标注数据稀缺的低资源临床 NLP 场景中的实践优势。

== 验证结果的解释

=== Uncertain 标签作为质量控制

LLM 将 7 条帖子（4.8%）标记为 _Uncertain_，在帖子内容不足以进行状态评估时选择弃权，这与提示中明确要求优先弃权而非强制分类的指令一致。_Uncertain_ 输出分布在各金标准类别中（2 条 _Depressive_、3 条 _Stable_、2 条 _Hypomanic_、0 条 _Manic_），没有明显集中在某一极。

=== 模式贡献：与零样本基线比较

按照 @evaldesignsec 中的设计，我们在保留子集上比较完整模式与最小零样本提示。零样本提示仅保留任务定义（帖子 $arrow.r$ 五种状态之一）和输出 JSON 字段；所有 DSM-5 规则、_SAFETY OVERRIDE_、_Severity Descriptors_ 和少样本示例均被移除。@tab-zeroshot 报告并列指标。

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    table.hline(),
    table.header([*指标*], [*零样本*], [*完整模式*], [*$Delta$*]),
    table.hline(stroke: 0.5pt),
    [准确率（含 Uncertain）], [51.7%], [*62.8%*], [#text()[$+$11.1 pp]],
    [准确率（不含 Uncertain）], [63.6%], [65.9%], [#text()[$+$2.3 pp]],
    [宏 F1], [0.459], [*0.519*], [#text()[$+$0.060]],
    [Uncertain 数量], [27], [*7*], [#text()[$-$20]],
    [DEPRESSIVE F1], [*0.738*], [0.734], [#text()[$-$0.004]],
    [STABLE F1], [0.600], [*0.716*], [#text()[$+$0.116]],
    [HYPOMANIC F1], [0.500], [0.500], [$plus.minus$ 0.000],
    [MANIC F1], [0.000], [*0.125*], [#text()[$+$0.125]],
    table.hline(),
  ),
  caption: [保留子集上的模式贡献（n=145）。两次运行均使用 Gemini 3.1 Pro 和相同 JSON 输出；唯一变量是系统提示（零样本：仅任务定义；完整模式：_SAFETY OVERRIDE_、_Severity Descriptors_、_Clinical Guidance_、八个少样本示例）。],
) <tab-zeroshot>

三个观察结果界定了该模式的价值。首先，单项最大效果是 _Uncertain_ 输出减少 4$times$（27 $arrow.r$ 7）：结构化模式赋予 LLM 足够词汇以提交标签而不是弃权，这解释了为什么包含 _Uncertain_ 的准确率增益（+11.1 pp）远大于排除 _Uncertain_ 的增益（+2.3 pp）。其次，_Stable_ 分类在逐类 F1 中受益最大（+0.116），这由 Severity Descriptors 中明确的“Stable includes mild positive activation”规则驱动，该规则防止 LLM 将非病理性积极帖子默认归为 _Depressive_ 或 _Uncertain_。第三，_Depressive_ 与 _Hypomanic_ F1 保持不变，说明完整模式在该子集上没有实质改变这些类别的表现，并且 _Manic_ 在两次运行中召回率均很差（零样本 0/15 vs. 模式 1/15，将 _Uncertain_ 计为错误），进一步表明躁狂极限制是结构性的（标签-文本一致性，@discussionsec），而不是更丰富提示可解决的限制。

该比较表明，模式的主要贡献是_覆盖率与决断性_（减少弃权、锚定边界类别决策），而非在 LLM 已有信心的案例上显著提高原始分类准确率。

=== 跨模型标注可行性

作为跨模型探查（@evaldesignsec），我们在同一 145 条保留帖子上使用 OpenAI 的 GPT-5.5（`reasoning_effort = "high"`）评估完整模式。模式和 JSON 输出格式与主实验相同；唯一变化是底层模型。

*内容政策下的拒答。* GPT-5.5 拒绝分类 145 条保留帖子中的 103 条（71.0%），并返回逐字拒答（`"I'm sorry, but I cannot assist with that request."`）。拒答集中在包含明确自伤或自杀内容的帖子上，而这正是 BD-Risk 出于临床设计而包含、并由 _SAFETY OVERRIDE_ 规则处理的安全相关子集。提示中的临床研究框架未能克服拒答。在相同提示下，Gemini 3.1 Pro 对所有 145 条帖子都产生了结构化输出。

*非拒答子集上的性能。* 在 GPT-5.5 实际分类的 42 条帖子上，两个模型的得分均高于完整 145 条帖子上的得分，因为该子集偏离抑郁危机内容（16 条 _Depressive_、10 条 _Stable_、12 条 _Hypomanic_、4 条 _Manic_）。@tab-crossmodel 报告头对头指标。

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.hline(),
    table.header([*指标（42 条非拒答帖子）*], [*Gemini*], [*GPT-5.5*]),
    table.hline(stroke: 0.5pt),
    [准确率（不含 Uncertain）], [72.5%], [*73.2%*],
    [宏 F1], [0.649], [*0.710*],
    [宏精确率], [0.827], [*0.838*],
    [宏召回率], [0.656], [*0.679*],
    [DEPRESSIVE F1], [*0.800*], [0.769],
    [STABLE F1], [0.727], [*0.737*],
    [HYPOMANIC F1], [0.667], [0.667],
    [MANIC F1], [0.400], [*0.667*],
    [Uncertain 输出], [2], [*1*],
    table.hline(),
  ),
  caption: [42 条非拒答帖子（145 条保留帖子中的子集）上的跨模型比较。该子集选择性排除了 GPT-5.5 拒绝的抑郁危机帖子（103 条，71%）。GPT-5.5 达到更高宏 F1，主要由 Manic F1 驱动（2/4 vs. Gemini 1/4）。],
) <tab-crossmodel>

*解释。* 当 GPT-5.5 作出回应时，该模式能够生成合理的结构化输出，说明其本质上并非 Gemini 特有。非拒答子集上的头对头数字偏向 GPT-5.5，然而子集选择本身才是主导效应：GPT-5.5 系统性过滤掉了推动 Gemini 在完整保留子集上多数错误率的困难抑郁危机帖子，因此该宏 F1 比较高估了 GPT-5.5 在临床心理健康语料上的有效能力。最重要的是，在此处测试的配置中，生产安全过滤器可能使 LLM _不适合作为精神健康语料的标注者_：71% 的拒答率使 GPT-5.5 无论内在能力如何，都无法作为独立标注者使用。

=== 错误分析 <errorsec>

我们通过手工分析开发子集中 LLM 与 BD-Risk 的分歧，刻画六类失败模式。对于每种模式，我们命名旨在缓解该模式的规则，并说明该规则是否在保留子集上解决了该模式，或该模式是否仍为残余错误。躁狂极帖子被误分为抑郁或稳定仍然是主要残余失败模式（在 @bdresultsec 中量化）。

*模式 1：忽略回顾性行为线索（主要躁狂侧错误）。* 当用户以带有悔恨或自责的回顾性帖子描述躁狂发作行为（冲动消费、攻击性冲突、过度活跃）时，LLM 会锚定在_当前情绪语调_而非_所述行为的临床意义_上，并预测为 _Depressive_。模式中的 _Behavior Over Tone_ 规则直接针对这一混淆；然而，它仍然是保留子集上的主要残余错误，说明该规则减少了这一模式，但未能完全消除。_合成案例：_ 用户以深度后悔和自我贬低的语调回忆一周的鲁莽消费和冲动决定；金标准为 _Hypomanic_（这些行为是躁狂症状的典型表现），LLM 预测为 _Depressive_（锚定于自我贬低语调）。

*模式 2：将混合特征误认为中性。* 当一条帖子同时带有两极症状（例如严重睡眠中断和无法集中注意力，同时伴随攻击性爆发）时，LLM 有时将共存解释为相互抵消，并默认 _Stable_。根据 DSM-5 @apa2013dsm5，混合特征应当作为主导极上的 `with_mixed_features` 说明符呈现。该模式中的混合特征规则减少了这种混淆，但当症状信号较为微弱时仍会出现残余实例。_合成案例：_ 用户写道自己三天没有睡觉、无法在工作中集中注意力，并且冲伴侣发火，所有内容都在同一帖子中；金标准为带混合特征的 _Hypomanic_（睡眠需求降低伴随烦躁性易激惹），LLM 基于信号“balance out”的推理预测为 _Stable_。

*模式 3：平静写作风格掩盖自杀意念（安全关键）。* 一些帖子以平静、反思性或教育性散文表达自杀意念（“I want to die”）；LLM 将语言体裁解读为稳定并据此分类，而金标准状态为 _Depressive_（$-$3）。平静写作并不能排除自杀危机，模式中明确的 _SAFETY OVERRIDE_ 规则强制在出现危机级语言时无论周围语调如何均标记为 _Depressive_。在保留子集上，包含明确自杀内容的帖子没有被预测为 _Stable_ 或 _Uncertain_，这表明该规则在评估子集上处理了这一模式。_合成案例：_ 用户发布一篇关于公众对抑郁误解的连贯短文；第二段中以同样平静语体嵌入一句话，说明作者多数早晨都悄悄想着不要醒来。

*模式 4：帖子结尾的希望覆盖广泛功能受损。* 描述严重功能受损（学业崩溃、无法维持日常作息、社交退缩）的帖子，有时以一句希望性陈述结尾（例如“my therapist said maybe I shouldn't give up”），LLM 锚定于这个末尾积极信号（与近因偏差一致）并预测为 _Stable_，而金标准标签追踪整篇帖子的广泛受损。模式中的 _Whole-Post Evidence Weighting_ 规则通过要求 LLM 权衡主导临床图景而非结尾情绪来处理此问题；零样本比较（@tab-zeroshot）显示，完整模式使 _Stable_ F1 提高 +0.116，这与减少将受损帖子过度分配为 _Stable_ 的情况一致。_合成案例：_ 用户报告一个月没有上任何课、本周几乎没有进食、失去回复朋友的能力，最后写道“maybe tomorrow will be different”；金标准基于广泛受损为 _Depressive_，LLM 预测为 _Stable_。

*模式 5：物质诱发激活与内源性心境。* 当用户描述明确归因于物质的心境升高（例如咖啡因诱发的欣快，被描述为“on top of the world”）时，LLM 可能将这些线索解释为轻躁狂心境，而金标准标签会区分急性药理性激活与内源性基线。模式中的 _Substance vs. Endogenous Mood_ 规则处理该边界，并覆盖 _Recurrent-Pattern Exception_，即对常见物质的不寻常反应性本身可能属于双相谱系。该模式在保留子集中较少见；该规则的主要作用是防止对归因于物质的帖子作出错误的 _Hypomanic_ 预测。_合成案例：_ 用户写道喝了第四杯咖啡后突然觉得“unbeatable and ready to overhaul”自己的公寓，将这种上冲归因于咖啡因并预期晚上会崩溃；金标准为 _Stable_（急性、外部造成、自我标记），LLM 基于表面线索预测为 _Hypomanic_。

*模式 6：Uncertain 掩盖嵌入的临床信号。* _Uncertain_ 在绝大多数情况下功能恰当；此处描述的失败较少见。LLM 正确识别帖子为元评论或信息性内容，却未能显露嵌入其中的临床重要内容。_合成案例：_ 用户写了一段批评网络上如何呈现康复的元评论，并在论证中途以括号形式提到自己一直在考虑结束生命；金标准为 _Depressive_，LLM 因元讨论语体默认 _Uncertain_。_SAFETY OVERRIDE_ 规则通过在危机级语言出现时无论整体框架如何均强制 _Depressive_，从而缓解该模式。与模式 3 类似，该规则在保留子集上似乎有效：没有危机级帖子被分类为 _Uncertain_。


= 纵向示范：周期级心境趋势 <pilotsec>

*数据收集。* 我们通过 Reddit API 持续抓取三个 BD 主题 subreddit（r/bipolar、r/BipolarReddit、r/bipolar2），检索每位活跃作者的完整发帖历史（帖子与评论），并定期重新抓取以捕捉持续活动。在 @resourcesec 所述患者验证之后，verified+probable 队列包含 124 名候选作者中的 115 名。我们排除少于两个包含帖子的 14 天周期的用户（即纵向跨度不足以进行趋势分析）。剩余 105 名用户贡献了 2,611 篇帖子和 12,812 条评论，时间跨度为 2019 年 4 月至 2026 年 5 月，形成 1,794 个有效分析周期。

#figure(
  image("fig_timeline.svg", width: 100%),
  caption: [四名匿名用户的心境轨迹（A：以抑郁为主并伴随波动，49 个周期；B：偏轻躁狂且频繁出现躁狂转换，74 个周期；C：躁狂主导并伴随快速循环，36 个周期；D：发帖密集且混合特征发生率高，25 个周期）。条形 = 14 天周期（颜色 = 主导状态；纹理 = 趋势方向；细黑边 = `with_mixed_features`）；条形上方点 = 逐帖标注，按帖子状态着色。],
) <fig-user-timeline>

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
      table.header([*趋势方向*], [*周期数*], [*%*]),
      table.hline(stroke: 0.5pt),
      [NO\_TREND], [1,506], [83.9%],
      [FLUCTUATING], [106], [5.9%],
      [TOWARDS\_DEPRESSION], [105], [5.9%],
      [TOWARDS\_MANIA], [77], [4.3%],
      table.hline(),
    ),
    table(
      columns: 3,
      align: (left, right, right),
      stroke: none,
      table.hline(),
      table.header([*主导状态*], [*周期数*], [*%*]),
      table.hline(stroke: 0.5pt),
      [Stable], [765], [42.6%],
      [Depressive], [564], [31.4%],
      [Hypomanic], [157], [8.8%],
      [Manic], [54], [3.0%],
      [Uncertain], [254], [14.2%],
      table.hline(),
    ),
  ),
  caption: [105 名用户队列的周期级分布（$n = 1,794$）。左：趋势方向（NO\_TREND = 状态维持，FLUCTUATING = 交替，TOWARDS\_MANIA / TOWARDS\_DEPRESSION = 恶化）。右：主导状态；`with_mixed_features` 被应用于 84 个周期（4.7%）。],
) <tab-pilot-dists>

多数 14 天窗口显示 NO\_TREND，这符合预期：DSM-5 发作持续时间标准要求躁狂 $gt.eq$1 周、轻躁狂 $gt.eq$4 天、重性抑郁 $gt.eq$2 周 @apa2013dsm5，而未经治疗的发作通常持续数周至数月，因此窗口内转换并不常见；少见的 TOWARDS\_DEPRESSION 和 TOWARDS\_MANIA 趋势标记发作起始或升级，是与早期干预最相关的信号。Stable 与 Depressive 状态占主导（分别为 42.6% 与 31.4% 的周期），而躁狂极状态所占比例较小（Hypomanic 8.8%，Manic 3.0%），这与长期 BD 队列研究中报告的抑郁极占优大体一致 @grande2016bipolar，同时也反映了 Reddit 社群的选择偏差和发帖偏差。

*逐帖状态分布。* @tab-post-state-dist 按内容类型分解标注；帖子/评论不对称及其含义在 @discussionsec 中讨论。两类内容的 _Uncertain_ 率均较低（$lt.eq$3.0%），反映了模型对该语料的信心。

#figure(
  table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header([*状态*], [*帖子*], [*%*], [*评论*], [*%*]),
    table.hline(stroke: 0.5pt),
    [Manic], [98], [3.8%], [93], [0.7%],
    [Hypomanic], [277], [10.6%], [292], [2.3%],
    [Stable], [1,217], [46.6%], [11,287], [88.1%],
    [Depressive], [961], [36.8%], [755], [5.9%],
    [Uncertain], [58], [2.2%], [385], [3.0%],
    table.hline(),
  ),
  caption: [105 名用户队列中按内容类型划分的逐帖状态分布。帖子（submissions，$n = 2,611$）作为较长形式的情绪披露，承载了多数极性状态标签；评论（$n = 12,812$）主要是会话性回复，多被标记为 Stable。],
) <tab-post-state-dist>


= 讨论 <discussionsec>

*周期级趋势。* 既有 BD 数据集主要提供用户级标签 @cohan2018smhd @sekulic2018not 或逐帖分数 @lee2024detecting，使周期级心境轨迹相对不足；我们的周期级标注通过在每个 14 天窗口中记录主导状态、心境是否正在转移（趋势方向）以及何时发生转移（变化点），补充了这一维度。从趋势分布（@pilotsec）可见四点。（1）TOWARDS\_MANIA 和 TOWARDS\_DEPRESSION 趋势较少见，但属于最具临床意义的信号，因为它们标记发作起始，此时干预最具影响。（2）FLUCTUATING 周期可能对应快速循环或混合表现，而单帖标签无法捕捉这些现象。（3）逐帖状态与周期级趋势共同支持分层建模：根据逐帖特征序列预测下一周期轨迹。（4）主导状态分布保留了有意义的躁狂极表示，与 MDD 招募队列形成对照（BD-Risk：88.9% 为抑郁或中性）；这种平衡对于必须区分躁狂极与抑郁状态的下游模型很重要。趋势分布与 BD 相关在线讨论的临床预期大体一致；直接外部验证需要周期级专家标注。一个互补方向是建模 `NO_DATA` 周期中的缺失信号：在数字表型研究中，发帖减少有时与抑郁相关 @faurholt2018smartphone，但这种关系具有异质性，因此缺失建模需要超出文本流水线的发帖频率基线。

*帖子--评论不对称。* @tab-post-state-dist 显示帖子和评论差异显著：51.2% 的帖子携带极性状态，而评论中只有 9.1%，并且评论主要由 _Stable_ 主导（88.1%）。帖子是较长形式的披露，而评论是短回复。由此产生两个下游含义：在评论占比较高的语料上，逐帖分类器可能在 _Stable_ 上显得过度自信，因此按内容类型报告指标优于单一汇总指标；轨迹模型应当上调帖子的权重，或依赖周期级主导状态标注（其已经在窗口内聚合不同内容类型）作为主要轨迹信号。

*躁狂极检测不足。* LLM 在保留子集上对 _Depressive_ 达到 87.9% 召回率，但对 _Hypomanic_ 和 _Manic_ 仅达到 35.7% 与 6.7%。两个因素共同造成这种不对称。第一是模型特性：抑郁语言具有典型表面标记（负性、自我聚焦、绝望），而躁狂极状态常通过_被描述的行为_体现（挥霍、睡眠需求减少、夸大计划），且可由任何语调叙述；LLM 读取的是语调而不是被描述行为的临床意义（见 @errorsec 中模式~1）。第二是 BD-Risk 标注规则中的标签--文本一致性问题：如 @lee2024detecting（第~3.2 节）所述，“posts exhibiting both manic and depressive moods are regarded as manic moods”，这是一种非对称平局规则，会将任何混合躁狂+抑郁帖子提升至躁狂侧。结合该数据集的 MDD$arrow$BD 招募方式，这产生了金标准 _Manic_（$+$3）帖子，其文本内容符合 BD-Risk 自身对 $-$3 的定义（“extreme anxiety and having suicidal thoughts”）。一个采用临床安全先验的单帖 LLM（将明确自伤内容分类为 _Depressive_）会系统性地在这些帖子上表现较差，因为它能够看到的唯一信号正是标签规则所覆盖的内容。因此，@tab-state-metrics 中 6.7% 的 _Manic_ 召回率上限反映的是结构性不匹配，而不只是模型限制（下游影响见局限性）。

= 局限性

所提出的方法和语料受到若干限制，我们将其归为评估范围、评估标签、躁狂极可解释性、队列界定以及发布时可靠性。

*评估范围。* 主要 BD-Risk 验证报告的是单一标注者（Gemini 3.1 Pro）；补充的 GPT-5.5 跨模型探查（见 @tab-crossmodel）表明该模式本质上并非 Gemini 特有，但在 OpenAI 当前内容政策下，GPT-5.5 不能大规模使用（保留子集上 71% 拒答），因此 145 条保留帖子上的逐类数字应被解读为 Gemini 特定结果。量化验证也仅在逐帖层面进行，因为可供研究使用、且规模足够的逐帖专家标注 BD 数据集很少（BD-Risk 是通过正式数据请求和伦理审查获得的，类似共享任务语料也面临相近的访问障碍）；周期级趋势作为本方法的关键贡献，尚未得到外部验证。

*金标准状态推导。* 最重要的是，金标准状态是通过确定性映射（@tab-mapping）从 BD-Risk 心境标签推导而来，而不是由专家直接标注为类别状态。这种映射引入了不精确性：相邻类别之间的边界本身不确定（例如 BD-Risk 心境标签 $+$1 可能反映轻度轻躁狂而非稳定心境），有序强度分数也并不总是对应类别型临床判断（例如，一个仍处于抑郁发作中的恢复叙述可能获得中性心境分数，但在临床上仍属抑郁）。专家间一致性（Krippendorff's $alpha$ = 0.87）是在有序层面测量的，将其映射为类别状态会放大边界处的分歧。因此，一些表面误分类可能反映映射伪影，报告的准确率数字应被解释为该模式真实可靠性的下界。

*躁狂极可解释性。* 两个因素限制了 Manic 极数字的解读。首先，保留 Manic 类规模较小（$n=15$，因为整个 BD-Risk 数据集仅包含 28 条心境-$+$3 帖子）；Manic-F1 估计的 95% 置信区间较宽（约 $plus.minus$ 13 个百分点），因此不应将较小 Manic-F1 差异解释为显著。其次，6.7% 的 Manic 召回率上限受到 BD-Risk 非对称平局规则与逐帖分类器可见文本证据之间结构性不匹配的限制（完整分析见 @discussionsec）；恢复标签-文本一致性需要在仅文本标准下重新标注，或采用能够提供标注者所见时间上下文的纵向评估协议。

*队列界定。* 患者验证由 LLM 完成，并筛选用户发帖历史中对 BD 诊断的自我披露；这并不构成临床确认。该做法遵循既有 BD 社交媒体数据集 @sekulic2018not @jagfeld2021understanding 的纳入模型，同时相比单帖成员规则采用更严格的逐用户证据门控。`verified` 或 `probable` 层级中的一些用户可能描述了尚未临床确立的 BD 诊断；相反，该队列也排除了从不公开披露诊断的 BD 用户。Reddit 也是一种自选择、异步渠道，因此其帖子与临床观察到的心境状态之间的关系需要进一步研究。需要临床医生确认 BD 状态的下游使用，应将该队列视为经 LLM 筛选的自我认同样本，而非临床队列。

*发布时可靠性。* 所有周期级（1,794）和逐帖层面（15,423）标注均完全由 LLM 生成；我们尚未对跨心境状态、置信水平和趋势方向的分层样本进行人工抽查。保留验证表明，_Depressive_ 标签（87.9% 召回率，73.4% F1）比躁狂极标签更可靠；_Hypomanic_ 标签具有中等可靠性（35.7% 召回率，50.0% F1），且在模型分配该标签时精确率较高（83.3%）；鉴于支持度较小以及上述躁狂极可解释性限制，应谨慎使用 _Manic_ 标签。

= 结论

验证结果区分了所提出方法的两个失败来源：87.9% 的抑郁召回率表明该模式能可靠锚定主要抑郁极标记，而 6.7% 的躁狂召回率似乎强烈受到躁狂极结构性标签-文本一致性问题影响，而不只是提示本身造成（见 @discussionsec）。由于周期级不存在外部纵向真值，该语料的 1,794 条轨迹只能通过其逐帖组成部分得到间接验证。由此产生三个近期优先事项：（1）专家标注周期级趋势，以实现直接纵向验证；（2）跨心境状态、置信水平和趋势方向进行分层人机协同审计，并以标注者间一致性形式报告；（3）将跨模型探查扩展到单一供应商评估之外（Anthropic Claude、开放权重推理模型），目前该评估受到 GPT-5.5 生产安全拒答模式的限制。所得语料旨在用于计算心理健康研究，不应作为临床诊断工具使用。

= 伦理考量

本研究分析公开发布的社交媒体内容，其中涉及敏感心理健康经历。研究方案已由筑波大学研究伦理委员会审查并批准（批准号~25-188）。我们还遵守 Reddit 隐私政策以及社交媒体研究伦理指南 @harrigian2021state。

*去标识化。* 在公开发布之前，所有帖子内容都经过基于 LLM 的去标识化处理。我们将个人可识别信息划分为五个按风险排序的类别：_identifiers_（直接姓名）、_quasi-identifiers_（可组合细节，例如具体地点、组织、日期或独特个人处境）、_contact information_、_linkage codes_ 和 _personal identification codes_，并将每个检测到的 PII 片段替换为类别特定占位符（例如 `[IDENTIFIER]`、`[QUASI_ID]`）。LLM 还会识别长跨度准标识符，即多个单独看似无害的细节（职业、地点、家庭结构）累积后可能共同缩小到某一个人的情况，而这种模式通常会被基于规则或 NER 的方法遗漏。该分类法旨在保留临床相关内容（药物名称、诊断类型、症状描述、相对时间表达），同时移除可识别信息。

*数据最小化与预期用途。* 数据集仅保留心境状态标注所需的文本内容和时间信息；作者用户名被替换为匿名标识符，可能促进再识别的 subreddit 成员身份和帖子元数据从发布数据集中排除。为降低基于搜索的再识别风险，发布的时间线使用相对时间偏移而非精确发帖时间。由于基于 LLM 的去标识化可能遗漏残留准标识符，公开发布以对分层样本进行发布前隐私审计为条件。该数据集仅用于计算心理健康研究，不得用于再识别、商业画像或未经适当专家监督的临床决策。

// Appendix uses letter numbering per LNCS convention
#set heading(numbering: (..nums) => {
  let n = nums.pos()
  if n.len() == 1 {
    numbering("A", n.last())
  } else {
    numbering("A.1", ..n)
  }
})
#counter(heading).update(0)

= 附录：标注提示 <appendix>

三类系统提示驱动该流水线：（A）逐帖提示，包含完整的基于 DSM-5 的模式、临床指导规则（_SAFETY OVERRIDE_、_Behavior Over Tone_、_Whole-Post Evidence Weighting_、_Improvement-Narrative_、_Substance vs.~Endogenous Mood_）、混合特征规则以及八个合成少样本示例；（B）最小零样本基线（仅任务与输出格式）；以及（C）14 天周期级趋势提示。用户消息只携带帖子文本。完整提示文本、流水线源码与评估脚本以匿名补充仓库形式公开：#link("https://anonymous.4open.science/r/bd-state-annotation/")。
