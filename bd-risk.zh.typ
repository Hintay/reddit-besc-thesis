#import "@preview/fine-lncs:0.6.3": lncs, institute, author, theorem, proof

// Latin (LNCS body) + Simplified Chinese. Adjust names to match `typst fonts` locally.
#set text(
  font: (
    (name: "New Computer Modern", covers: "latin-in-cjk"),
    "Noto Serif SC",
    "Noto Serif CJK SC",
    "Source Han Serif",
    "Microsoft YaHei",
  ),
  lang: "zh",
  region: "CN",
  cjk-latin-spacing: auto,
)

#let inst_tsukuba = institute("University of Tsukuba",
  addr: "1-1-1 Tennodai, Tsukuba, Ibaraki 305-8577, Japan",
  email: "lin.jiefeng.tkb_ge@u.tsukuba.ac.jp",
)

#show: lncs.with(
  title: "MoodTrail-BD：面向双相情感障碍的纵向心境状态标注社交媒体资源",
  running-title: "MoodTrail-BD",
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
    双相情感障碍（BD）常被误诊为重性抑郁障碍（MDD），随时间监测心境状态 _转变_ 对及时干预至关重要。现有社交媒体数据集仅提供二元诊断标签或帖文级心境评分，均未捕获心境轨迹，即临床上定义 BD 的状态转变时间动态。本文提出一种纵向心境状态标注社交媒体资源，提供两个粒度的标注：帖文级心境状态分类与 14 天周期级心境趋势分析。后者记录主导状态、趋势方向（稳定、向躁狂或抑郁恶化、波动）及临床变化点，使仅靠帖文级标签无法实现的心境轨迹建模成为可能。标注框架基于 DSM-5 发作标准，以 LLM 流水线（Gemini 3.1 Pro）实现。本数据集涵盖 105 名在 BD 相关子版块自我披露 BD 诊断的用户（1,794 个 14 天周期、2,642 条投稿、12,847 条评论，跨度 2019 年 4 月至 2026 年 5 月），心境分布与已知 BD 流行病学一致。帖文级状态分类在 BD-Risk 数据集 @lee2024detecting 上以一个作者不重叠、分层抽样的 145 条留出子集进行外部验证，宏平均 F1 为 0.519，抑郁召回率 87.9%，轻躁狂/躁狂召回率分别为 35.7%/6.7%。本文归纳了六种具有临床意义的错误模式，并识别出一项位于躁狂极的标签—文本一致性结构性问题，该问题限制了帖文级躁狂召回的可达上限。
  ],
  keywords: ("双相情感障碍", "大语言模型", "数据集构建", "社交媒体", "临床自然语言处理", "心理健康"),
  bibliography: bibliography("refs.bib"),
)

= 引言

双相情感障碍（BD）以躁狂、轻躁狂与抑郁反复发作为特征，全球患病率约 1--2% @grande2016bipolar。约 17--50% 的 BD 初诊被误诊为重性抑郁障碍（MDD），因患者多在抑郁期求助，且未必将躁狂或轻躁狂视为病态 @hirschfeld2003misdiagnosis @vieta2018misdiagnosis。误诊导致不当治疗（如单用抗抑郁药可能诱发躁狂转相）并延误干预。

Reddit 等社交媒体平台存在 BD 社群（如 r/bipolar、r/BipolarReddit），用户公开讨论症状、治疗与日常功能。已有工作利用这些数据进行 BD 与 MDD 分类 @cohan2018smhd @coppersmith2015clpsych @sekulic2018not，但现有数据集仅提供二元诊断标签（BD vs.~MDD）或用户级风险评分。无数据集提供随时间追踪的帖文级心境状态标签，限制了对心境轨迹的计算研究。

近期研究将 LLM 应用于心理健康 NLP 任务 @xu2024mental @yang2024mentallama，但 LLM 能否在专家水平分类 BD 心境状态，尤其是难以从文本检测的躁狂极状态，尚未得到验证。

本文提出 MoodTrail-BD 资源以应对这一局限。我们从 BD 相关子版块（r/bipolar、r/BipolarReddit、r/bipolar2）采集自我披露 BD 诊断的用户的 Reddit 帖文，在两个粒度进行标注：（1）帖文级心境状态（抑郁、稳定、轻躁狂、躁狂）；（2）14 天周期级心境趋势（主导状态、趋势方向、变化点）。标注框架遵循 DSM-5 发作标准，以 LLM 流水线（Gemini 3.1 Pro）实现。我们以 BD-Risk 数据集 @lee2024detecting 为金标准，在作者不重叠、分层抽样的 145 条留出子集上验证帖文级标注，宏平均 F1 为 0.519，抑郁召回率 87.9%，轻躁狂/躁狂召回率分别为 35.7%/6.7%。两极召回率的不对称源于两方面：一是已知的模型属性（躁狂极状态常通过 _所描述行为_ 而非情感语气表达），二是源数据集躁狂极标签存在结构性的标签—文本一致性问题。

本文贡献：
+ 双粒度标注框架（帖文级状态 + 14 天趋势）及 LLM 流水线。现有 BD 社交媒体资源仅提供用户级或帖文级标签，本资源增加了周期级心境轨迹标注。
+ MoodTrail-BD 包含 105 名来自 BD 相关子版块的自我披露 BD 用户、1,794 个 14 天周期、15,489 条帖文与评论，跨度 2019 年 4 月至 2026 年 5 月，心境与趋势分布符合临床预期。
+ 在 BD-Risk 专家标注数据集的一个作者不重叠、分层抽样的留出子集上进行外部验证，宏平均 F1 为 0.519（抑郁召回率 87.9%，轻躁狂召回率 35.7%，躁狂召回率 6.7%），并归纳出六种错误模式。


= 相关工作

== BD 纵向心境监测

临床上对 BD 心境轨迹的追踪主要依赖生态瞬时评估（EMA）与基于智能手机传感器及自报应用的数字表型 @faurholt2018smartphone @torous2016new。该路径可产出高频心境信号，但需患者主动加入并知情同意，限制了队列规模与对外可用性。社交媒体提供一种互补的非侵入数据源：对已在公开讨论自身病情的用户，可被动获取数月至数年自然产生的语言数据。然而迄今为止，社交媒体数据在周期级的心境轨迹标注尚未作为公开资源发布。

== 社交媒体心理健康检测

De Choudhury 等 @dechoudhury2013predicting 证明社交媒体信号可预测抑郁发作。SMHD 数据集 @cohan2018smhd 基于自报诊断覆盖九类心理健康状况；Coppersmith 等 @coppersmith2015clpsych 建立了 Twitter 上抑郁与 PTSD 检测的共享任务。

针对 BD，Sekuli\'c 等 @sekulic2018not 提出基于 Reddit 的分类方法，Jagfeld 等 @jagfeld2021understanding 构建了大规模 BD Reddit 语料，但两者均依赖未经专家验证的自报诊断 @harrigian2021state @stanton2020critical。BD-Risk 数据集 @lee2024detecting 提供经精神科医师与临床心理学家验证的帖文级心境标签，本文将其作为帖文级验证的金标准。

== 临床 NLP 与心理健康中的 LLM

Xu 等 @xu2024mental 评估了 LLM 从在线文本预测心理健康状况的表现；Yang 等 @yang2024mentallama 对 MentalLLaMA 进行微调以实现可解释的心理健康分析。Lee 等 @lee2024detecting 发现 ChatGPT 在 BD 风险检测上 F1 仅 0.130（其多任务模型为 0.578），表明通用 LLM 在 BD 特定任务上表现不佳。在 LLM 标注质量这一更一般的问题上，Gilardi 等 @gilardi2023chatgpt 表明 ChatGPT 在文本标注任务上可达到或超过众包工作者；本工作沿此路径，将 LLM 视作 _标注者_ 而非分类器，并以一个由 DSM-5 衍生的显式标注框架为基础。

本工作与上述评估的不同在于：我们不预测诊断，而是用 LLM _标注_ 帖文级心境状态与周期级趋势，以专家标签验证标注质量，并将结果作为资源发布。错误分析（@errorsec）刻画了标注框架须应对的失败模式，亦提示下游用户应关注的局限。


= 方法

== 方法概览 <resourcesec>

我们将所提出的方法应用于在 BD 相关子版块自我披露 BD 诊断的 Reddit 用户数据，构建一份纵向心境状态标注语料。流水线在两个时间粒度产出标注：（1）帖文级心境状态分类；（2）14 天周期级心境趋势分析。@fig-pipeline 展示从数据采集到 LLM 标注的端到端流程。

#figure(
  {
    import "@preview/fletcher:0.5.8": diagram, node, edge

    let c_data    = "#1F4E79"
    let c_verify  = "#2E7D32"
    let c_annot   = "#7030A0"
    let c_post    = "#1F4E79"
    let c_trend   = "#C65911"

    let line_icon(paths, color, size: 10pt) = box(
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

    let elabel(body) = box(
      fill: white,
      inset: (x: 1.5pt, y: 0.5pt),
      align(center, text(size: 6pt)[#body]),
    )

    // `justify: false` prevents single-word wrapped lines (e.g. "A.") from
    // being stretched to the box width, which would read as a left indent;
    // `hyphenate: false` blocks mid-word breaks.
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
          align(left, text(size: 5.5pt, fill: luma(40))[• *输出字段：* #schema]),
        )
      },
    )

    let llm_prompts = node(
      (2, 0),
      {
        set par(first-line-indent: 0pt, justify: false)
        set text(hyphenate: false)
        stack(dir: ttb, spacing: 3pt,
          align(center, text(weight: "bold", size: 9pt, fill: rgb(c_annot))[LLM 提示词]),
          grid(
            columns: (1fr, 1fr),
            column-gutter: 3pt,
            prompt_subbox(
              [A. 单帖提示词],
              [对每条帖文独立分类],
              [DSM-5、安全覆盖、行为优先于语调],
              [state, opposite\_pole\_symptoms, specifiers, confidence, reasoning],
            ),
            prompt_subbox(
              [B. 14 天趋势提示词],
              [分析每个 14 天周期],
              [整周期权衡、混合特征],
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

    // No inner background; JSON is left-aligned (raw lines inherit the
    // node's default centering otherwise, which looks like centered code).
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

        make_box((0, 0), icon_globe, c_data, [数据采集],
          ([Reddit API], [3 个 BD 子版块]), width: 20mm),
        edge((0, 0), (1, 0), "-|>", elabel[115 名\ 用户]),

        make_box((1, 0), icon_shield, c_verify, [患者验证],
          ([LLM 证据], [三级分类器]), width: 22mm),
        edge((1, 0), (2, 0), "-|>", elabel[100/115 名\ 已验证]),

        llm_prompts,
        edge((2, 0), (3, 0), "-|>"),

        make_box((3, 0), icon_brain, c_annot, [Gemini\ 3.1 Pro],
          ([基于 DSM-5], [的标注]), width: 22mm),

        // Brace-style fork; spine at x=3.3 (not 3.5) so the arrow tips
        // have visible length after fletcher clips them at the wide
        // output boxes' left edges. Outputs at ±0.55 to keep the gap
        // compact.
        edge((3, 0), (3.3, 0), "-"),
        edge((3.3, -0.55), (3.3, 0.55), "-"),
        edge((3.3, -0.55), (4, -0.55), "-|>"),
        edge((3.3,  0.55), (4,  0.55), "-|>"),

        json_box((4, -0.55), c_post, [帖文级输出],
          ("state", "specifiers", "confidence", "reasoning"), width: 30mm),

        json_box((4, 0.55), c_trend, [周期级输出],
          ("dominant_state", "trend_direction", "change_points", "trend_summary", "confidence"), width: 30mm),
      )
    ))
  },
  caption: [MoodTrail-BD 标注流水线。用户从三个 BD 相关子版块持续采集，并经过患者验证步骤（基于 LLM 证据的三级分类器）；通过验证的队列由 Gemini 3.1 Pro 使用两个基于 DSM-5 的提示词（单帖提示词与 14 天趋势提示词）标注，产出两个时间粒度的结构化 JSON：帖文级状态与 14 天周期趋势。],
) <fig-pipeline>

*数据采集。* 通过 Reddit API 持续监控三个 BD 相关子版块（r/bipolar、r/BipolarReddit、r/bipolar2）。对发现的每位活跃作者，获取其完整发帖历史（投稿与评论），并按可配置冷却时间定期重新抓取以捕获持续活动。

*患者验证。* 在 BD 相关子版块发帖是自我披露 BD 诊断的必要而非充分条件：许多此类发帖来自临床工作者、家属或与本人诊断状态无关的社群讨论。为筛选候选池，我们应用一个基于 LLM 的三级分类器（Gemini 3.1 Pro，与标注框架分离的独立提示词），扫描每位作者完整发帖历史中对 BD 诊断的明示性自我披露，返回三类标签之一并附支持性文本证据：`verified`（明确的第一人称诊断陈述，如"我 2019 年被确诊为 II 型双相"，或具体的治疗 / 住院叙述）、`probable`（通过症状描述、用药提及或社群归属语气持续自我标识，但缺乏明确诊断陈述）、`unverified`（无诊断信号、第三方讨论或题外活动）。只有 `verified` 或 `probable` 两个等级的用户被纳入标注队列。该验证步骤为 LLM 筛查自我披露，并非临床确诊（见局限性）；其与已有 BD 社交媒体数据集 @sekulic2018not @jagfeld2021understanding 的纳入模型一致，但相比"曾在子版块发过一条帖"的简单规则，施加了更严格的逐用户证据闸门。

*规模。* `verified` + `probable` 队列共 115 名用户。具有帖文的 14 天周期不足两个（即纵向跨度不够）的用户被排除。剩余 105 名用户贡献 2,642 条投稿与 12,847 条评论，时间跨度 2019 年 4 月至 2026 年 5 月，产出 1,794 个有效分析周期。

== 标注框架 <frameworksec>

标注框架基于 DSM-5 发作定义 @apa2013dsm5，构建面向 LLM 标注的结构化提示。下文描述的框架与一项针对外部专家标签的错误分析（见 @errorsec）共同发展，后者刻画了框架的已知失败模式。框架在两个时间粒度产出标注：

=== 帖文级状态分类

对每条帖文（投稿或评论），LLM 从五个类别中指定心境状态：

- *躁狂：* 夸大、急促书写（连写句、过度大写）、思维奔逸（话题跳跃）、极端易激惹或欣快。
- *轻躁狂：* 能量与节奏升高但保持连贯、社交脱抑制、异常强烈而无精神病性特征。
- *抑郁：* 语言收缩、绝对化用语（「从不」「什么也没有」）、高自我聚焦（第一人称）、认知扭曲、自杀意念。
- *稳定：* 情绪基调平衡、元认知反思、反应适度、社群支持性语言。
- *不确定：* 保留给确实无法分类的帖文；LLM 须先尝试分类再使用此标签。

框架还支持 `with_mixed_features` 说明符（符合 DSM-5 混合特征标准）。应用前，提示词要求 LLM 提取明确的对极症状列表，仅在三个以上对极症状有据可查时才赋予该说明符，防止混合极性被用作模糊的中性标签。

=== 周期级趋势分析

为纵向心境轨迹建模，将每位用户的发帖历史切分为连续固定长度周期（默认：14 天）。周期以用户首帖为锚点（day 0），按严格的半开区间 $[t_(k), t_(k) + 14)$ 推进；投稿与评论按时间戳一并归入所属周期。从首帖到末帖的所有周期均被定义；无帖文的周期标记为 `NO_DATA` 而非跳过，以保留供轨迹建模使用的连续时间网格。@fig-period-slicing 展示该切片机制。

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
      width: 100%, height: 13mm,
      stroke: 0.4pt + black, inset: 3pt,
      align(center + horizon, body),
    )
    let nodata_cell = box(
      width: 100%, height: 13mm,
      stroke: 0.4pt + black, fill: luma(240), inset: 3pt,
      align(center + horizon, text(size: 7pt, style: "italic", fill: luma(80))[NO\_DATA]),
    )

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

      text(size: 6pt, fill: luma(110))[day 0--13],
      text(size: 6pt, fill: luma(110))[day 14--27],
      text(size: 6pt, fill: luma(110))[day 28--41],
      text(size: 6pt, fill: luma(110))[day 42--55],
      text(size: 6pt, fill: luma(110))[day 56--69],
      text(size: 6pt, fill: luma(110))[day 70--83],

      cell(dots("S", "C", "S", "C")),
      cell(dots("C", "C")),
      nodata_cell,
      cell(dots("S", "C")),
      cell(dots("C", "C", "C", "C")),
      cell(dots("S")),
    )
  },
  caption: [单一用户的周期切分示意。每个方框为一个 14 天固定窗口，以用户首帖为锚点（day 0）。投稿（实心圆）与评论（空心圆）按时间戳一并归入所属周期。无帖文的周期（如周期 3）以 `NO_DATA` 保留而非跳过，确保下游轨迹模型看到的是连续时间网格。],
) <fig-period-slicing>

对每个含至少一条帖文的周期，LLM 分析其中帖文并产出：

- *主导状态：* 该周期的主要心境状态（躁狂、轻躁狂、抑郁或稳定），使用与帖文级相同的临床标准，但在窗口内跨帖文聚合证据。
- *趋势方向：* 周期内心境变化的轨迹：`NO_TREND`（维持同一状态）；`TOWARDS_MANIA`（向躁狂恶化）；`TOWARDS_DEPRESSION`（向抑郁恶化）；`FLUCTUATING`（状态间交替但无明确方向）。
- *变化点：* 发生心境转变的具体日期或事件，记录转变前后状态。
- *趋势总结：* 简明的叙事性描述，刻画周期内的情绪轨迹及支持主导状态的证据。
- *DSM-5 说明符：* 当对极症状在周期内同时共存（区别于时序交替）时标记 `with_mixed_features`。

帖文级状态与周期级趋势结合，支持事件级分析（如什么触发了状态变化）和纵向轨迹建模（如从当前序列预测下一周期的主导状态）。显式的变化点字段还支持在文本层面进行变化点检测分析 @truong2020selective。

=== Few-Shot 示例构造 <fewshotsec>

帖文级提示词配以八个由作者手工编写的合成 Few-Shot 示例（标号 A--H），均不取自 BD-Risk。每个示例针对提示词为应对某一在原型阶段观察到的失败模式而引入的具体规则（失败模式的完整论证见 @errorsec）：示例 A 演示 _行为优先于语气_ 规则，处理对躁狂侧行为的回顾性懊悔叙述；B 与 E 演示 _安全覆盖_ 规则及其在夸大 / 精神病性躁狂语境下的窄豁免；C 与 D 在表面相似的"恢复线索"上对比 _改善叙事_ 规则与 _全文主导_ 规则；F 在短冲动型帖文上抵消默认归入"不确定"的倾向；G 演示物质诱发轻躁狂的 _复现模式豁免_；H 通过 _严重度描述符_ 区分轻躁狂激活与稳定的生产力。每条示例同时给出输入帖文与完整的预期 JSON 输出（包含结构化的 `opposite_pole_symptoms` 证据列表与 reasoning 字符串），使模型同时学习目标标签与支撑其判断的证据链。完整示例文本见附录。

== 基于 BD-Risk 的外部验证 <validsec>

为确立帖文级状态分类的质量，以 Lee 等 @lee2024detecting 在 NAACL 2024 发布的 BD-Risk 数据集进行验证。周期级趋势分析在本文中未经外部验证，因无现有数据集提供周期级专家标注心境轨迹。

=== BD-Risk 数据集

BD-Risk 数据集包含 7,346 条 Reddit 帖文，来自 1,025 名用户，采集自心理健康子版块（r/Depression、r/bipolar、r/BipolarReddit、r/BipolarSOs），跨度 2008--2023。用户分为仅 MDD（569 人）与 MDD$arrow$BD（456 人）两组。由于两组均从 MDD 初诊招募而非来自活跃 BD 队列，数据集在结构上偏向抑郁极内容，88.9% 帖文的心境标签 $lt.eq 0$。MoodTrail-BD 则从活跃的 BD 主题子版块采样，在每位用户的纵向历史中保留更广谱的心境状态分布。

每条帖文带有 7 点心境标签（$-$3 至 $+$3），由标注员在精神科医师指导下完成，经两名临床专家验证（Krippendorff $alpha$ = 0.87，专家间 Cohen $kappa$ = 0.63--0.69）@lee2024detecting。

=== 金标准状态推导

BD-Risk 仅提供有序心境标签，未直接标注类别状态。为获取金标准状态（gold states），由心境标签按 @tab-mapping 所示映射推导。

#figure(
  table(
    columns: 3,
    align: (center, center, left),
    stroke: none,
    table.hline(),
    table.header(
      [*BD-Risk 心境标签*], [*推导金标准状态*], [*说明*],
    ),
    table.hline(stroke: 0.5pt),
    [$-$3, $-$2, $-$1], [抑郁], [],
    [0, $+$1], [稳定], [$+$1 = 正常范围内的正向心境],
    [$+$2], [轻躁狂], [无精神病性特征的躁狂侧激活],
    [$+$3], [躁狂], [伴精神病性特征的严重躁狂表现],
    table.hline(),
  ),
  caption: [BD-Risk 7 点心境标签到推导金标准状态的映射。$+$1 视为正常正向范围（稳定）。],
) <tab-mapping>

=== 评估集构建

BD-Risk 完整数据集心境分布严重偏斜（88.9% 帖文 $lt.eq$ 0）。鉴于部署任务是 BD 风险检测而非一般心境分类，我们刻意对躁狂极进行过采样，使代表不足类别上的各类指标具备实质统计功效。

我们将带标签的帖文分为两个互不相交的子集。一个 _开发子集_（314 条）用于框架设计与失败模式分析。一个 _留出子集_（145 条）专用于下文报告的最终评估；它与开发子集 *作者完全不重叠*，从未出现在开发子集中的 BD-Risk 作者中以分层抽样得到，以确保四个推导金标准状态各具充足支持数的配额（抑郁 $60$ 条、稳定 $40$ 条、轻躁狂 $30$ 条、躁狂 $15$ 条）。@bdresultsec 中的所有指标均在留出子集上计算；开发子集从不用于生成报告数字。BD-Risk 中躁狂极金标准帖文几乎全部来自 MDD$arrow$BD 组，故留出子集的躁狂侧样本在结构上由 MDD$arrow$BD 群体衍生（局限性见 @discussionsec）。

== LLM 配置

使用 Gemini 3.1 Pro，通过官方 API 访问结构化 JSON 输出。选择该模型因其大上下文窗口和原生结构化输出生成能力，均为标注流水线所需。每条帖文独立处理，所用提示词包含完整标注框架（基于 DSM-5 的规则、输出格式）与 8 个针对开发过程中刻画的失败模式的合成 few-shot 示例（见 @errorsec）。提示词作为系统指令；模型返回包含 `state`、`opposite_pole_symptoms`、`specifiers`、`confidence`（高/中/低）与 `reasoning` 字段的 JSON 对象。`opposite_pole_symptoms` 字段承载明确证据列表，是赋予 `with_mixed_features` 说明符的前提（见 @frameworksec）。周期级标注另返回 `trend_direction`、`change_points` 与 `trend_summary` 叙事字段，`confidence` 为 0--1 数值（而非帖文级的高/中/低）。温度设为默认值。Few-shot 示例由作者合成构造，并非取自 BD-Risk；模型未经微调。

Gemini 3.1 Pro 为本文的主标注模型。@resultsec 报告了一项 GPT-5.5 跨模型探查，以考察框架的可移植性及提供商级内容政策差异对标注可行性的影响。

== 评估指标 <metricssec>

本文将 BD-Risk 临床标签称为金标准标签，LLM 输出称为预测。金标准状态由 BD-Risk 心境标签按 @tab-mapping 推导。

报告各类精确率、召回率与 F1，以及总体准确率、宏平均 F1 和混淆矩阵。报告两种准确率口径：_排除不确定_ 的准确率将不确定输出视为弃权并从分子分母中移除（常用评测惯例）；_含不确定_ 的准确率将不确定记为错误，提供保守下界。各类精确率、召回率与 F1 采用排除不确定的口径。所有指标在完整评估集上计算。


= 结果 <resultsec>

== 帖文级 BD-Risk 验证 <bdresultsec>

首先以 BD-Risk 专家标签验证帖文级状态分类。@tab-state-metrics 为各类指标，@tab-state-summary 为总体汇总。

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
    [抑郁],  [0.630], [*0.879*], [*0.734*], [58],
    [稳定],  [0.659], [0.784], [0.716], [37],
    [轻躁狂], [*0.833*], [0.357], [0.500], [28],
    [躁狂],  [*1.000*], [0.067], [0.125], [15],
    table.hline(),
  ),
  caption: [留出子集（n=145，排除 7 条「不确定」输出）上的各类状态分类指标。躁狂精确率为 1.0 是因为 LLM 仅输出的一条「躁狂」预测正好正确；召回率（0.067）反映 15 条金标准躁狂中有 14 条被划入其他类别。],
) <tab-state-metrics>

#figure(
  table(
    columns: 2,
    align: (left, right),
    stroke: none,
    table.hline(),
    table.header([*指标*], [*数值*]),
    table.hline(stroke: 0.5pt),
    [准确率（排除不确定）], [65.9%],
    [准确率（含不确定）], [62.8%],
    [宏平均 F1], [0.519],
    [宏平均精确率], [0.781],
    [宏平均召回率], [0.522],
    table.hline(),
  ),
  caption: [留出子集（n=145）上的总体状态分类汇总。由于留出子集刻意按分层抽样设计，宏平均 F1（而非总体准确率）为主指标。],
) <tab-state-summary>

抑郁召回率较高（87.9%），稳定召回率中等（78.4%）；轻躁狂与躁狂召回率较低（35.7% 与 6.7%），表明 LLM 能正确识别多数抑郁极与稳定极帖文，但遗漏多数躁狂极案例。混淆矩阵（@tab-state-cm）显示主要错误流向：30 条金标准轻躁狂中 12 条被判为抑郁、6 条被判为稳定；15 条金标准躁狂中 11 条被判为抑郁、2 条被判为稳定。躁狂被误判为抑郁这一反复出现的错误模式可能源于标签—文本一致性问题，详见 @discussionsec。

#figure(
  table(
    columns: 7,
    align: (left, right, right, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*金标准 $backslash$ 预测*], [*DEP*], [*STA*], [*HYP*], [*MAN*], [*UNC*], [*合计*],
    ),
    table.hline(stroke: 0.5pt),
    [*抑郁*],  [*51*],  [7],    [0],   [0],   [2],  [60],
    [*稳定*],  [7],    [*29*], [1],   [0],   [3],  [40],
    [*轻躁狂*], [12],   [6],    [*10*], [0],   [2],  [30],
    [*躁狂*],  [11],   [2],    [1],   [*1*], [0],  [15],
    table.hline(),
  ),
  caption: [留出子集上的状态混淆矩阵（行：推导金标准状态；列：LLM 预测）。DEP = 抑郁，STA = 稳定，HYP = 轻躁狂，MAN = 躁狂，UNC = 不确定。],
) <tab-state-cm>

轻躁狂错误集中在金标准 $+$2 的帖文被 LLM 判为抑郁或稳定，表明提示词仍难以处理躁狂侧激活被负面语气掩盖的帖文。

== 「不确定」标签作为质量控制

LLM 对 7 条帖文（4.8%）输出「不确定」，在内容不足以评估时弃权。非零比例反映标注框架明确要求在帖文真正不可解读时弃权，而非强行猜测。

「不确定」标签起到质量过滤作用，避免证据不足时强行标注。留出评估中「不确定」输出按金标准类别分布（抑郁 2 条、稳定 3 条、轻躁狂 2 条、躁狂 0 条），未在单一极上明显集中。

== 框架贡献：与零样本基线的对比

为量化结构化标注框架在 LLM 自身能力之上的贡献，我们用同一模型（Gemini 3.1 Pro）在留出子集上重跑一次极简零样本提示词：仅含任务定义（帖文 $arrow.r$ 五类状态之一），不含 DSM-5 规则、不含 SAFETY OVERRIDE、不含 Severity Descriptors、不含 few-shot 示例。输出 JSON 字段保持一致，确保对照公平。@tab-zeroshot 给出并排指标。

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*指标*], [*零样本*], [*完整框架*], [*$Delta$*],
    ),
    table.hline(stroke: 0.5pt),
    [准确率（含不确定）], [51.7%], [*62.8%*], [#text()[$+$11.1 pp]],
    [准确率（排除不确定）], [63.6%], [65.9%],   [#text()[$+$2.3 pp]],
    [宏平均 F1],         [0.459], [*0.519*], [#text()[$+$0.060]],
    [「不确定」数],         [27],    [*7*],     [#text()[$-$20]],
    [抑郁 F1],            [*0.738*], [0.734],  [#text()[$-$0.004]],
    [稳定 F1],            [0.600],   [*0.716*], [#text()[$+$0.116]],
    [轻躁狂 F1],          [0.500],   [0.500],   [$plus.minus$ 0.000],
    [躁狂 F1],            [0.000],   [*0.125*], [#text()[$+$0.125]],
    table.hline(),
  ),
  caption: [留出子集（n=145）上的框架贡献评估。两次运行使用同一模型（Gemini 3.1 Pro）和同一输出 JSON 模式；唯一变化是系统提示词。零样本提示词仅含任务定义，不含临床规则；完整框架包含 SAFETY OVERRIDE、Severity Descriptors、Clinical Guidance 各子节及 8 个合成 few-shot 示例。],
) <tab-zeroshot>

从中可归纳出三点观察。第一，最大的单一效应是**「不确定」减少为原来的 1/4**（27 $arrow.r$ 7）：结构化框架给了 LLM 落定标签的依据而不是回避，这也解释了为什么*含*「不确定」时准确率涨 11.1 pp、*排除*「不确定」时只涨 2.3 pp。第二，**稳定类别的 F1 增益最大**（+0.116），源于 Severity Descriptors 中"STABLE 包含轻度正向激活"的显式规则，避免了 LLM 把非病理性正向帖文错判为抑郁或不确定。第三，**抑郁与轻躁狂 F1 基本不变**，说明 LLM 在这两类上凭基础能力已经处理得不错；**两次运行中躁狂召回率都很低**（零样本 0/15 vs 框架 1/15，将「不确定」计为错误），印证躁狂极的限制是结构性的（标签—文本一致性，见 @discussionsec），并非靠更丰富的提示词所能修复。

这一对比表明：框架的核心贡献是*覆盖度与决策性*（防止弃权、为边界类别提供锚点），而不是在 LLM 已有信心的样本上提升原始分类准确率。

== 跨模型可用性

为考察框架是否能在 Gemini 之外的模型上工作，我们以同一完整框架提示词在同一 145 条留出子集上额外评估 OpenAI 的 GPT-5.5（`reasoning_effort = "high"`）。提示词与 JSON 输出格式完全一致，唯一变化是底层模型。

**内容政策拒答。** GPT-5.5 对 145 条留出帖文中的 103 条（71.0%）作出内容政策性拒答——原文响应为 `"I'm sorry, but I cannot assist with that request."`——对这些帖文未产出结构化输出。拒答集中于含明确自伤或自杀内容的帖文，即 BD-Risk 按临床设计纳入、且 SAFETY OVERRIDE 规则正是为处理这类内容而设计的安全相关子集。提示词中的临床研究框架（框架开头即声明"You are an expert AI assistant specializing in linguistic analysis for psychiatric research"）并未解除该拒答。Gemini 3.1 Pro 在同一提示词下对全部 145 条均产出结构化输出。

**非拒答子集上的表现。** 在 GPT-5.5 接受的 42 条上，两个模型的分数都高于全 145 条，因为该子集偏离了抑郁危机内容（子集金标准分布：抑郁 16、稳定 10、轻躁狂 12、躁狂 4）。@tab-crossmodel 给出该子集上的逐项对比。

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*指标（42 条非拒答帖文）*], [*Gemini*], [*GPT-5.5*],
    ),
    table.hline(stroke: 0.5pt),
    [准确率（排除不确定）],         [72.5%],  [*73.2%*],
    [宏平均 F1],                  [0.649],  [*0.710*],
    [宏平均精确率],                [0.827],  [*0.838*],
    [宏平均召回率],                [0.656],  [*0.679*],
    [抑郁 F1],                    [*0.800*], [0.769],
    [稳定 F1],                    [0.727],  [*0.737*],
    [轻躁狂 F1],                  [0.667],  [0.667],
    [躁狂 F1],                    [0.400],  [*0.667*],
    [「不确定」数],                [2],      [*1*],
    table.hline(),
  ),
  caption: [在 GPT-5.5 接受的 42 条帖文（145 条留出中）上的跨模型对比。GPT-5.5 宏平均 F1 略高，主要由躁狂 F1 拉动（4 中对 2，Gemini 4 中对 1）。**此对比并非干净的 head-to-head**：42 条是 GPT-5.5 内容政策过滤后剩下的帖文，被系统性地剔除了抑郁危机帖文。剩余 103 条（占留出 71%）GPT-5.5 未标注，未列入此表。],
) <tab-crossmodel>

**解读。** 三点结论。第一，当 GPT-5.5 作出响应时，框架能产出合理的结构化输出，证实框架本身并非 Gemini 特异。第二，非拒答子集上的 head-to-head 数字看似 GPT-5.5 略优，但**子集选择本身是主导效应**：GPT-5.5 系统性地过滤掉了在全 145 条上驱动 Gemini 大部分错误的"难"抑郁危机帖文，因此直接的宏平均 F1 对比夸大了 GPT-5.5 在临床心理语料上的实际表现。第三，对实际应用最为重要的是，**生产级安全过滤器可能令一个 LLM 不适合作为精神病学语料的标注者**——在留出子集上 71% 的拒答率使得 GPT-5.5 在当前安全策略下无法独立担任 MoodTrail-BD 的标注模型，无论其原始能力如何。LLM 提供商的选择对标注可行性的影响超出准确率本身。

== 帖文级预测的作者级聚合

帖文级标签的常见下游用法之一是按时间聚合，例如取用户在 14 天窗口内所有帖文的主导状态。为考察聚合在多大程度上能平滑帖文级误差，我们在留出子集上计算作者主导预测：对每位作者，将其所有帖文 LLM 预测（排除「不确定」）取众数为预测主导状态，将其所有 BD-Risk 金标准取众数为金标准主导状态。145 条留出帖文来自 120 名唯一作者。@tab-author-state 汇总相应指标。

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.hline(),
    table.header([*指标*], [*帖文级（n=145）*], [*作者主导（n=120）*]),
    table.hline(stroke: 0.5pt),
    [准确率（排除不确定）], [65.9%], [*66.7%*],
    [宏平均 F1], [0.519], [0.485],
    [躁狂召回率], [6.7%（1/15）], [7.1%（1/14）],
    [$gt.eq 2$ 帖作者：帖文级准确率], [54.8%（23/42）], [—],
    [$gt.eq 2$ 帖作者：作者主导准确率], [—], [*60.0%（12/20）*],
    table.hline(),
  ),
  caption: [留出子集上帖文级与作者级（多数投票）指标对比。作者主导聚合带来适度的准确率提升（最明显的是 20 名可评估的 $gt.eq$ 2 帖作者，约提升 5 个百分点）。宏平均 F1 未提升，躁狂召回率本质上未变——聚合可平滑随机的帖文级噪声，但无法修复 @discussionsec 中讨论的躁狂侧类别特异性失败模式。],
) <tab-author-state>

这一模式——准确率适度提升、躁狂召回未改善——说明下游时序聚合系统可放心使用帖文级输出并恢复部分帖文级噪声，但残留的躁狂极漏检不是一种噪声性质，无法在任何基于相同帖文级输入的聚合下消除。

== 资源标注：周期级心境趋势 <pilotsec>

帖文级可靠性确认后，转向周期级趋势标注。@fig-user-timeline 展示两名代表性用户的双粒度标注：每行为一名用户，彩色条形表示 14 天周期（颜色 = 主导状态，填充纹理 = 趋势方向），散点表示帖文级状态标注。

#figure(
  image("fig_timeline.svg", width: 100%),
  caption: [两名匿名化 BD 用户的多年发帖历史心境轨迹可视化。彩色条形表示 14 天周期（条形颜色 = 主导状态；填充纹理 = 趋势方向；`with_mixed_features` 说明符以细黑边框标记）。条形上方的散点表示各周期内的帖文级状态标注，按帖文状态着色。],
) <fig-user-timeline>

@tab-trend-dist 为已标注周期的趋势方向分布。

#figure(
  table(
    columns: 4,
    align: (left, right, right, left),
    stroke: none,
    table.hline(),
    table.header(
      [*趋势方向*], [*周期数*], [*百分比*], [*含义*],
    ),
    table.hline(stroke: 0.5pt),
    [NO\_TREND],             [1,506], [83.9%], [周期内维持同一心境状态],
    [FLUCTUATING],          [106],   [5.9%],  [状态间交替，无明确方向],
    [TOWARDS\_DEPRESSION],  [105],   [5.9%],  [向抑郁极渐进恶化],
    [TOWARDS\_MANIA],       [77],    [4.3%],  [向躁狂极渐进恶化],
    table.hline(),
  ),
  caption: [14 天周期趋势方向分布（$n = 1794$，来自 105 名用户）。NO\_TREND 占主导符合预期：多数 14 天窗口捕获单一持续发作或稳定阶段。],
) <tab-trend-dist>

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*主导状态*], [*周期数*], [*百分比*],
    ),
    table.hline(stroke: 0.5pt),
    [稳定],   [765], [42.6%],
    [抑郁],   [564], [31.4%],
    [轻躁狂], [157], [8.8%],
    [躁狂],   [54],  [3.0%],
    [不确定], [254], [14.2%],
    table.hline(),
  ),
  caption: [14 天周期主导状态分布（$n = 1794$）。`with_mixed_features` 说明符应用于 84 个周期（4.7%）。],
) <tab-state-dist>

多数 14 天窗口为 NO\_TREND，符合预期：BD 心境发作典型持续时间为数周至数月（抑郁）或 1--4 周（躁狂），DSM-5 @apa2013dsm5，故单个 14 天窗口内的状态转变不常见。TOWARDS\_DEPRESSION 与 TOWARDS\_MANIA 虽罕见，但标记发作起始或升级，是对早期干预最为相关的信号。

稳定与抑郁状态占主导，躁狂极（轻躁狂与躁狂之和）占其余部分。这与已知的 BD 不对称一致：抑郁发作更频繁且持续更久，用户在抑郁与稳定期可能发帖更多 @jagfeld2021understanding。

*帖文级状态分布。* @tab-post-state-dist 报告帖文级分类器赋予的主导心境状态，按内容类型拆分。两种分布显著不同：投稿是作者用于披露困扰或恢复的较长篇内容，其中标记为极态（躁狂、轻躁狂或抑郁）的合计占 51.2%，稳定不到一半；评论作为线程内回复，以稳定为主（88.1%），极态合计仅 8.9%。两者的不确定率均较低（$lt.eq$3.0%），反映模型在发布版语料上的置信水平。

#figure(
  table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*状态*], [*投稿*], [*百分比*], [*评论*], [*百分比*],
    ),
    table.hline(stroke: 0.5pt),
    [躁狂],   [98],    [3.8%],  [93],     [0.7%],
    [轻躁狂], [277],   [10.6%], [292],    [2.3%],
    [稳定],   [1,217], [46.6%], [11,287], [88.1%],
    [抑郁],   [961],   [36.8%], [755],    [5.9%],
    [不确定], [58],    [2.2%],  [385],    [3.0%],
    table.hline(),
  ),
  caption: [105 用户队列上的帖文级状态分布，按内容类型分列。投稿（$n = 2{,}611$）作为较长篇情绪披露，承载多数极态标签；评论（$n = 12{,}812$）以会话性回复为主，以稳定为主。],
) <tab-post-state-dist>


= 错误分析 <errorsec>

本节刻画标注框架须应对的六种失败模式，通过对 LLM 预测与 BD-Risk 金标准之间分歧的人工分析归纳而来。每种模式以其表面成因命名，配以代表性案例，并指向框架中相应的约束规则。在本框架下，躁狂或轻躁狂帖文被误判为抑郁或稳定仍是主要的残留失败模式；@bdresultsec 的留出各类指标量化了其出现频率。

== 模式 1：忽视回顾性行为线索

*主导的躁狂侧错误模式。* 当用户以悔恨或自责口吻回顾躁狂发作行为（冲动消费、激烈冲突、活动过多）时，LLM 依据 _当前情绪基调_ 赋予抑郁标签，而未识别 _所述行为的临床意义_。

_代表性案例（合成）：_ 用户回顾一段持续一周的鲁莽消费与冲动决策经历，以深深的悔恨与自我谴责口吻书写。金标准状态为轻躁狂，所描述的行为（冲动消费、抑制力下降）为典型躁狂症状。LLM 判为抑郁，锚定于自我贬低的叙事基调。根本原因：LLM 将文本当情感而非临床证据处理，把 _叙述者的情感_ 与 _所描述的临床状态_ 混为一谈。

== 模式 2：混合特征与中性混淆

当帖文同时呈现两极症状（如严重睡眠障碍与无法集中伴攻击性爆发）时，LLM 有时默认为稳定，将对立信号并存视为相互抵消。依 DSM-5 @apa2013dsm5，混合特征应作为主要状态上的说明符，状态应反映主导极。

_代表性案例（合成）：_ 用户在同一篇帖文里写自己三天没睡、工作无法集中、又因琐事冲伴侣发火。金标准为轻躁狂伴混合特征（睡眠需求减少与烦躁性 dysphoria 并存）。LLM 判为稳定，认为正负信号「相互抵消」。根本原因：LLM 把两极症状视为相消而非以混合特征说明符共存。

== 模式 3：平静文风掩盖自杀意念

安全关键模式。部分帖文在平静、反思或教育性文体中表达自杀意念（「I want to die」）。LLM 将语域解读为稳定并据此分类。金标准状态为抑郁（推导自专家心境标签 $-$3）。教训很具体：平静文风不排除自杀危机，任何部署系统都须在任意语气下检测危机级语言。框架以显式安全覆盖规则处理该模式。

_代表性案例（合成）：_ 用户发表一篇结构完整、逻辑连贯的散文，反思公众对抑郁的常见误解；在第二段中以同样平静的语气嵌入一句：自己其实大多数早上都悄悄想着不再醒来。金标准为抑郁（$-$3）。若无安全覆盖规则，LLM 会以整体语域为准而判为稳定。

== 模式 4：文末希望压倒全程损害

描述严重功能受损（学业崩溃、无法维持日常、社交退缩）的帖文有时以单句希望作结（如「治疗师说也许我不该放弃」）。LLM 锚定末尾积极信号判为稳定，而金标准反映全文的普遍损害证据。提示 LLM 文本处理存在近因偏差。

_代表性案例（合成）：_ 用户描述过去一个月每节课都缺席、本周几乎没怎么吃东西、无法回复朋友的消息，并以一句「也许明天会不一样」收尾。金标准基于全文普遍的功能受损证据判为抑郁。LLM 锚定末句乐观信号判为稳定。

== 模式 5：物质诱发激活与内源性心境

当用户描述物质所致心境升高（如咖啡因诱发欣快、感觉「世界之巅」）时，LLM 可能将其视为轻躁狂证据。金标准区分药理学诱发激活与内源性心境状态，依据用户基线心境而非短暂物质效应标注。框架以显式的物质—心境消歧规则处理该边界，并涵盖反复模式情形——若用户对常见物质表现出反复且不寻常的反应性，该反应性本身即为双相谱系指标。

_代表性案例（合成）：_ 用户写道，今天喝完第四杯咖啡后突然觉得自己无所不能、想要把整个公寓彻底翻新；明确指出这股冲动来自咖啡因，预计傍晚就会跌回低谷。金标准为稳定（或抑郁性基线），因为激活是急性、外因驱动且作者自觉地归因为物质。若无规则，LLM 会被表层「无所不能 / 翻新公寓」信号误导而判为轻躁狂。

== 模式 6：「不确定」掩盖嵌入的临床信号

少数情况下，LLM 正确将帖文识别为元评论或信息性内容，却未识别其中嵌入的临床信号。一则批评「抑郁美学化」的帖文可能含明确自杀表述，却被「不确定」分类掩盖。虽然「不确定」在多数情形中运作正常，框架仍以安全覆盖规则缓解该模式：当存在危机级语言时，无论帖文整体框架如何，均强制判为抑郁。

_代表性案例（合成）：_ 用户撰写一篇元评论，批评社交媒体上对康复叙事的呈现方式，举例论证该叙事的负面影响。在论证中段，作者以括注形式提及自己最近也在想结束这一切。若无安全覆盖规则，LLM 会因为帖文主导语域是元讨论而非第一人称心境陈述而判为「不确定」，掩盖嵌入的危机级信号。金标准为抑郁。


= 讨论 <discussionsec>

== 周期级趋势

先前 BD 数据集提供用户级标签 @cohan2018smhd @sekulic2018not 或帖文级评分 @lee2024detecting，但不提供心境 _轨迹_。本资源的周期级标注增加了这一维度：每个 14 天窗口不仅记录主导状态，还记录心境是否在变化（趋势方向）及何时变化（变化点）。

从趋势分布（@pilotsec），四个观察值得注意。（1）TOWARDS\_MANIA 与 TOWARDS\_DEPRESSION 趋势罕见但临床上最重要，因其标记发作起始，即干预影响最大的时间点。（2）FLUCTUATING 周期可能对应快速循环或混合呈现，单帖标签无法捕获。（3）帖文级状态与周期级趋势结合使层次化建模成为可能：从帖文级特征序列预测下一周期的轨迹。（4）主导状态分布（@tab-state-dist）保留了显著的躁狂极表征，与 BD-Risk 等从 MDD 招募的队列（88.9% 帖文落于抑郁或中性区间）形成对比。这种均衡对下游建模工作至关重要——模型必须学会区分躁狂极与抑郁极，而非简单地预测抑郁多数类。

趋势分布与临床预期一致（见 @pilotsec）；直接的外部验证须依赖周期级专家标注。

一个互补的方向是建模本框架目前未覆盖的信号：`NO_DATA` 周期（见 @fig-period-slicing）因无可用文本而被排除于心境状态标注之外。社交媒体活动减少在数字表型研究中有时与抑郁相关 @faurholt2018smartphone，但这一关系具有异质性——部分用户在抑郁期反而发帖更多（反刍、寻求支持），部分发帖减少，且许多无帖文的周期反映与心境无关的因素（平台兴趣变化、线下生活事件、账号被封禁）。将"缺席"作为心境信号处理，因此需要相对每位用户基线活动度量的发帖频率特征，超出基于文本的标注流水线的范围。

== 投稿与评论的帖文级分布不对称

@tab-post-state-dist 表明投稿与评论的心境状态分布显著不同。51.2% 的投稿被标记为极态（躁狂、轻躁狂或抑郁），而评论中仅 8.9%；评论以稳定为主（88.1%）。这反映了平台的功能差异：投稿是作者用于披露困扰、康复或治疗变化的较长篇内容，评论则是对他人线程的简短回复（如建议、事实性回答、表达支持）。该不对称对下游产生两点影响。其一，在以评论为主的语料上评估的帖文级分类器会因多数评论本属会话性内容而显得对"稳定"过度自信；因此按内容类型分别报告指标比单一聚合更可取。其二，将帖文级状态流聚合为周期级特征的轨迹模型，应将投稿赋更高权重，或直接将周期级主导状态（其已在 14 天窗口内跨内容类型聚合证据）作为轨迹的主要信号。

== 躁狂极漏检

在留出子集上，LLM 对抑郁状态召回率 87.9%，而轻躁狂仅 35.7%、躁狂 6.7%。两类因素叠加产生该模式。第一类是模型属性：抑郁语言有模式化的表面标记（负性、自我聚焦、无望感），而躁狂极状态常通过 _描述的行为_（消费失控、睡眠需求减少、夸大计划）表现，叙述时可带任意语气（悔恨、困惑或幽默）。LLM 读取语气而非识别所述行为的临床意义（见 @errorsec 模式 1）。

第二类是源于 BD-Risk 标注规则的标签—文本一致性问题。@lee2024detecting 3.2 节明确：「同时呈现躁狂与抑郁心境的帖文视为躁狂心境」，即一条不对称的裁决规则，将任何同时含两极内容的帖文上调到躁狂端。结合数据集对 MDD$arrow$BD 用户的筛选，该规则会产生数量可观的躁狂（$+$3）金标准帖文，其文本内容恰好匹配 BD-Risk 自身对 $-$3 的定义（「极度焦虑伴自杀意念」）。坚持临床安全先验的单帖 LLM——将明确自伤内容判为抑郁——在这些帖文上必然系统性地表现欠佳，因为模型仅能见到的恰是被标注规则"覆盖"的内容本身。@tab-state-metrics 中 6.7% 的躁狂召回上限反映了这一结构性错位，并非单纯的模型局限。其对下游使用的含义见局限性节。

= 局限性

MoodTrail-BD 存在若干局限，分为评估、标注与资源构建三方面。

*跨模型覆盖有限。* 主 BD-Risk 验证报告单一标注者（Gemini 3.1 Pro）。补充的 GPT-5.5 跨模型探查（见 @tab-crossmodel）表明该框架在原则上并非 Gemini 特异，但在 OpenAI 当前内容政策下无法在临床心理语料上规模化应用（留出子集 71% 拒答率）。全 145 条留出子集上报告的各类表现因此应解读为 Gemini 特异性。

*帖文级评估而非纵向评估。* 定量验证在帖文层面，而临床心境评估通常考虑纵向模式。帖文级设置之所以采用，是因 BD-Risk 是唯一具有足够规模、每帖均带专家心境标签的现有数据集；周期级趋势——本资源的主要贡献——则未经外部验证，因周期级外部金标准尚不存在。

*金标准为推导而非专家直接标注。* 解读评估结果时最需注意：金标准状态由 BD-Risk 心境标签经确定性映射推导（@tab-mapping），而非专家直接标注类别状态。该映射引入若干不精确来源：（a）相邻类别边界具有内在不确定性（心境标签 $+$1 可能反映轻度轻躁狂而非稳定，但映射将其确定性地归为稳定）；（b）BD-Risk 心境标签是有序强度评分而非类别临床判断，两者并非一一对应（如持续抑郁中出现的恢复叙事帖文可能获中性心境评分但临床上仍属抑郁）；（c）7 点量表上的专家间一致性（Krippendorff $alpha$ = 0.87）在有序层面度量，映射到类别后在边界处放大分歧。因此部分表观误分类可能反映映射偏差而非 LLM 失误，报告准确率应理解为框架真实可靠性的下界。

*躁狂极代表不足。* 留出子集（145 条）的构建是为了让每个推导金标准状态都有足够支持以计算各类指标，但躁狂（$n=15$）在绝对数上仍较小，原因是整个 BD-Risk 数据集只有 28 条心境 $+$3 帖文。在 $n=15$ 时，躁狂 F1 估计的 95% 置信区间宽约 $plus.minus$ 13 个百分点，故小幅躁狂 F1 差异不应被解读为显著。要进一步提高躁狂统计功效需对额外来源进行重新标注，超出本工作的范围。

*躁狂极的标签—文本一致性。* 6.7% 的躁狂召回上限受限于 BD-Risk 不对称裁决规则与单帖分类器可见文本证据之间的结构性错位（完整论证见 @discussionsec）。要恢复躁狂检测的标签—文本一致性，需在仅文本标准下重新标注，或采用一种能向模型提供标注员所见时序背景的纵向评估方案。

*自我披露的诊断。* 患者验证基于 LLM，从用户完整发帖历史中筛查 BD 诊断的自我披露，并不构成临床确诊。该做法与已有 BD 社交媒体数据集 @sekulic2018not @jagfeld2021understanding 的纳入模型一致，但相比"曾在子版块发过一条帖"的简单规则施加了更严格的逐用户证据闸门。`verified` 与 `probable` 等级中部分用户可能在未经临床确诊的情况下声称患有 BD；反之，从未在公开发帖中披露诊断的 BD 患者亦被排除在外。需要临床确诊 BD 状态的下游使用应将该队列视为经 LLM 筛查的自我披露样本，而非临床队列。

*发布版标注尚无人工环节验证。* 全部周期级标注（1,794 条）与帖文级标注（15,423 条）均由 LLM 产出。我们尚未在分层样本（按心境状态、置信度与趋势方向分层）上进行人工抽检。

*生态效度。* Reddit 帖文是自选、异步的沟通通道；其与临床访谈所观察心境状态的关系仍需进一步研究。

*实际可靠性。* 资源中抑郁状态标签可靠（留出子集上召回率 87.9%、F1 73.4%）；轻躁狂标签具中等可靠性（召回率 35.7%、F1 50.0%），LLM 一旦给出预测则精确率较高（83.3%）；考虑到样本量较小及上述标签—文本一致性问题，躁狂标签需谨慎使用。

= 结论

验证结果将所提出方法的两种失败来源区分开来：87.9% 的抑郁侧召回率表明本框架能可靠锚定抑郁极的主导线索，而 6.7% 的躁狂召回则主要受限于躁狂极的结构性标签—文本一致性问题，并非可通过 prompt 调整修复（见 @discussionsec）。由于周期级缺乏外部纵向金标准，所发布语料的 1,794 个周期级轨迹仅能通过其帖文级构成获得间接验证。后续三项工作随之优先：（1）周期级趋势的专家标注，以实现直接的纵向验证；（2）按心境状态、置信度与趋势方向分层的人工抽检审计，作为标注者间一致性形式报告；（3）将跨模型探查扩展至 Anthropic Claude 与开源 reasoning 模型，刻画其在躁狂极的行为——目前因 GPT-5.5 所示的生产侧安全拒答模式而受限。所发布的框架、标注与去标识化方案，意在作为社交媒体纵向心境状态研究的方法学起点，而非临床诊断工具。

= 伦理考量

本研究涉及分析公开发布的、讨论敏感心理健康经历的社交媒体内容。研究方案已通过筑波大学研究伦理委员会审查并获批准（批准号 25-188）。同时遵守 Reddit 隐私政策及社交媒体研究伦理规范 @harrigian2021state。

*非识别化。* 发布前，所有帖文内容经 LLM 非识别化处理。我们按识别风险将个人识别信息分为五类：_识别子_（单独可识别特定个人的姓名等）、_准识别子_（组合后可识别个人的信息，如具体地点、机构、日期或独特个人经历）、_联系方式_、_连结符号_及_个人识别符号_。LLM 检测每个 PII 片段并替换为类别占位符（如 `[IDENTIFIER]`、`[QUASI_ID]`）。基于 LLM 的非识别化还能检测长跨度准识别子，即多个单独无害的细节（职业、地点、家庭结构）累积后可将身份缩小到单一个体的段落，这是规则方法或传统 NER 难以捕获的。所有非识别化输出经人工抽查，验证检测覆盖率与临床相关内容的保留（药物名称、诊断类型、症状描述及相对时间表达均予保留）。

*数据最小化。* 资源仅保留心境状态标注所需的文本内容与时间戳。作者用户名替换为匿名标识符；可能促进再识别的子版块成员身份与帖文元数据在发布数据集中排除。

*使用限制。* 本资源仅供计算心理健康研究使用，不得用于个人再识别、商业画像或无适当专家监督的临床决策。

#pagebreak()

= 附录：标注提示词 <appendix>

本附录完整收录标注流水线中使用的三个系统提示词。所有提示词作为系统指令提供，用户消息仅包含待分类的帖文文本。

== 帖文级标注提示词（完整框架） <prompt-full>

#set text(size: 6.5pt)
#set par(leading: 0.45em)

#raw(
  read("prompts/batch.single.md").split("---").slice(2).join("---").trim(),
  block: true,
)

#set text(size: 10pt)
#set par(leading: 0.65em)

== 帖文级标注提示词（零样本基线） <prompt-zeroshot>

#set text(size: 6.5pt)
#set par(leading: 0.45em)

#raw(
  read("prompts/batch.single.zero_shot.md").split("---").slice(2).join("---").trim(),
  block: true,
)

#set text(size: 10pt)
#set par(leading: 0.65em)

== 周期级趋势分析提示词 <prompt-trend>

#set text(size: 6.5pt)
#set par(leading: 0.45em)

#raw(
  read("prompts/trend_analysis.md").split("---").slice(2).join("---").trim(),
  block: true,
)

#set text(size: 10pt)
#set par(leading: 0.65em)
