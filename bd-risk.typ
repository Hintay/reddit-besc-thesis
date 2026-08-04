#import "@preview/fine-lncs:0.6.5": lncs, institute, author, theorem, proof

#let inst_tsukuba = institute("University of Tsukuba",
  addr: "1-2 Kasuga, Tsukuba, Ibaraki 305-8550, Japan",
  email: "lin.jiefeng.tkb_ge@u.tsukuba.ac.jp",
)

#show: lncs.with(
  title: "Few-Shot Prompt-Based Longitudinal Mood-State Analysis of Bipolar Disorder on Social Media",
  running-title: "Few-Shot BD Mood-State Analysis",
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
    Bipolar disorder (BD) is frequently misdiagnosed as major depressive disorder, and monitoring mood-state _transitions_ over time is critical for timely intervention. Existing social media datasets for BD research typically provide only binary diagnostic labels or per-post mood scores; few capture mood trajectories. Because expert annotation is costly and fine-tuning requires scarce labeled data, we propose a few-shot prompt-based LLM method that requires no task-specific training. The annotation schema is grounded in DSM-5 episode criteria and accompanied by eight synthetic few-shot examples, making the method directly applicable to other BD corpora. The method labels posts at two granularities: per-post mood state and 14-day period-level trends (dominant state, trend direction, change points), enabling trajectory modeling that per-post labels alone cannot support. Post-level classification is externally validated against the BD-Risk dataset @lee2024detecting on a held-out, author-disjoint, stratified subset of 145 posts, achieving macro F1 of 0.519 with high depressive recall (87.9%) and lower manic-pole recall (35.7%/6.7%). Six error patterns are characterized, including a structural label-text consistency issue at the manic pole that bounds achievable manic recall. Using Gemini 3.1 Pro, we apply the method to 105 self-identified BD users on BD-focused subreddits (1,794 14-day periods, 15,423 posts and comments, April 2019--May 2026), observing depressive-pole predominance broadly consistent with clinical expectations for BD-related online discussion.
  ],
  keywords: ("Bipolar Disorder", "Large Language Models", "Few-Shot Prompting", "Social Media", "Clinical NLP", "Mood Trajectory"),
  bibliography: bibliography("refs.bib", style: "splncs.csl"),
)

#set heading(supplement: [Sect.])

= Introduction

Bipolar disorder (BD) is characterized by recurrent episodes of mania, hypomania, and depression, affecting 1--2% of the global population @grande2016bipolar. An estimated 17--50% of BD cases are initially misdiagnosed as major depressive disorder (MDD), because patients typically seek help during depressive episodes and may not recognize manic or hypomanic states as pathological @hirschfeld2002guideline @vieta2018misdiagnosis. This misdiagnosis leads to inappropriate treatment (e.g., antidepressant monotherapy, which may trigger manic switching) and delays proper intervention.

Social media platforms such as Reddit host BD communities (e.g., r/bipolar, r/BipolarReddit) where users openly discuss symptoms, treatment, and daily functioning. Prior work has used these data for BD and MDD classification @cohan2018smhd @coppersmith2015clpsych @sekulic2018not, yet existing datasets provide only binary diagnosis labels (BD vs.~MDD) or user-level risk scores. Few resources offer post-level mood state labels tracked over time, limiting computational research on mood trajectories and, in turn, on BD progression and early intervention.

Constructing expert-annotated BD corpora is costly: mood-state labeling requires psychiatric expertise, and the scarcity of labeled data makes fine-tuning approaches difficult to scale. At the same time, recent advances in large language models (LLMs) suggest that they can follow human-written guidelines with reasonable accuracy on text annotation tasks @gilardi2023chatgpt. This motivates our approach: if LLMs can internalize clinical guidelines presented in a prompt, then a carefully designed DSM-5-grounded prompt with synthetic few-shot examples should enable mood-state annotation _without task-specific fine-tuning or labeled training data_, making the method directly applicable to new BD corpora.

Recent work has applied LLMs to mental health NLP tasks @xu2024mental @yang2024mentallama; however, whether they can classify BD mood states at expert-level accuracy, especially manic-pole states that are difficult to detect from text, has not been established.

This paper proposes a few-shot prompt-based LLM method for longitudinal mood-state analysis of BD on social media and demonstrates its application to a Reddit cohort. We collect Reddit posts from BD-focused subreddits (r/bipolar, r/BipolarReddit, r/bipolar2), targeting users who self-identify as having a BD diagnosis, and annotate them at two granularities: (1) per-post mood state (_Depressive_, _Stable_, _Hypomanic_, _Manic_) and (2) 14-day period-level mood trends (dominant state, trend direction, change points). The annotation schema follows DSM-5 episode criteria and is implemented as an LLM pipeline (Gemini 3.1 Pro). We validate the post-level annotations against the BD-Risk dataset @lee2024detecting on a held-out, author-disjoint, stratified subset of 145 posts, achieving macro F1 of 0.519 with 87.9% depressive recall and 35.7%/6.7% recall on hypomania/mania. The recall asymmetry across poles reflects both a known model property (manic-side states often manifest through described behaviors rather than affective tone) and a structural label-text consistency issue with the source dataset's manic-pole labels.

Our contributions:
+ *Method:* A DSM-5-grounded few-shot prompt schema for LLM-based mood-state annotation at two temporal granularities (per-post state and 14-day period-level trend), requiring no fine-tuning or labeled training data.
+ *Evaluation:* External validation of post-level state classification against the BD-Risk expert-labeled dataset @lee2024detecting on a held-out, author-disjoint, stratified subset, with macro F1 of 0.519 (87.9% depressive recall, 35.7% hypomanic recall, 6.7% manic recall), complemented by a zero-shot baseline comparison, a supervised fine-tuning baseline, and a cross-model portability evaluation across five additional LLMs from five providers (macro F1 0.432--0.564).
+ *Demonstration:* Application of the method to 105 self-identified BD users from BD-focused subreddits (1,794 14-day periods, 15,423 posts and comments spanning April 2019 through May 2026), producing longitudinal mood trajectory annotations with distributions aligning with clinical BD literature.


= Related Work

== Longitudinal Mood Monitoring in BD

Clinical tracking of BD mood trajectories relies heavily on ecological momentary assessment (EMA) and digital phenotyping via smartphone sensors and self-report apps @faurholt2018smartphone @torous2016new, which yield dense mood signals yet require active enrollment and consent, limiting cohort size and external use. Social media offers a complementary unobtrusive source of passive, naturally produced language over months to years for users already discussing their condition; however, public corpora with period-level mood-trajectory annotations remain limited, constraining longitudinal BD method development.

== Social Media in Mental Health Detection

#cite(<dechoudhury2013predicting>, form: "prose") showed that social media signals can predict depression onset. The SMHD dataset @cohan2018smhd covers nine mental health conditions via self-reported diagnoses; #cite(<coppersmith2015clpsych>, form: "prose") established shared tasks for depression and PTSD detection from X (formerly Twitter).

For BD, #cite(<sekulic2018not>, form: "prose") proposed Reddit-based classification and #cite(<jagfeld2021understanding>, form: "prose") compiled a large BD Reddit corpus; however, both rely on self-reported diagnoses without expert validation @harrigian2021state @chancellor2020methods. The BD-Risk dataset @lee2024detecting provides per-post mood labels validated by a psychiatrist and a clinical psychologist; we use it as the gold standard for our post-level validation.

== LLMs for Clinical NLP and Mental Health

#cite(<xu2024mental>, form: "prose") evaluated LLMs on mental health prediction from online text; #cite(<yang2024mentallama>, form: "prose") fine-tuned MentalLLaMA for interpretable mental health analysis. #cite(<lee2024detecting>, form: "prose") found that ChatGPT achieved only an F1 of 0.130 on BD risk detection (vs.~0.578 for their multi-task model), showing that off-the-shelf LLMs struggle with BD-specific tasks. On the more general question of LLM annotation quality, #cite(<gilardi2023chatgpt>, form: "prose") show that ChatGPT can match or exceed crowd workers on text annotation tasks; our work follows this line by treating the LLM as an annotator (not a classifier) and grounding its outputs in an explicit DSM-5-derived schema.

Unlike these diagnosis-prediction evaluations, we propose a prompt-based method that _annotates_ per-post mood states and period-level trends, and validate the annotations against expert labels; the error analysis (@errorsec) characterizes the failure modes the schema must address.


= Methodology

== Method Overview <resourcesec>

The proposed method takes as input a user's posting history from mental-health-related social media communities and produces mood-state annotations at two temporal granularities (per-post state and 14-day period-level trend). @fig-pipeline shows the end-to-end flow: candidate identification through LLM-based patient verification, followed by structured annotation with two DSM-5-grounded prompts.

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
          align(left, text(size: 5.5pt, fill: luma(40))[• *Task:*\ #task]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *Rules:*\ #rules]),
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
          align(center, text(weight: "bold", size: 9pt, fill: rgb(c_annot))[LLM prompts]),
          grid(
            columns: (1fr, 1fr),
            column-gutter: 3pt,
            prompt_subbox(
              [Single-post prompt],
              [classify each post independently],
              [DSM-5, safety override, behavior over tone],
            ),
            prompt_subbox(
              [14-day trend prompt],
              [analyze each 14-day period],
              [whole-period weighting, mixed features],
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
        edge((-2.5, 0), <verify>, "-|>", elabel[user posting\ history], label-pos: 0.25),

        // Row 0: main pipeline.
        make_box((-0.8, 0), icon_shield, c_verify, [Patient verification],
          ([LLM evidence], [3-tier classifier]), width: 16mm, name: <verify>),
        edge(<verify>, <prompts>, "-|>", elabel[verified\ cohort], label-side: left),

        llm_prompts,
        edge(<prompts>, <gemini>, "-|>"),

        make_box((2, 0), icon_brain, c_annot, [Gemini\ 3.1 Pro],
          ([DSM-5-guided], [annotation]), width: 17mm, name: <gemini>),

        // Brace-style fork from Gemini to the two outputs.
        // All fork coordinates are relative to <gemini> via (rel:, to:).
        // edge(<gemini>, (rel: (0.2, 0), to: <gemini>), "-"),
        edge((rel: (0.2, -0.55), to: <gemini>), (rel: (0.2, 0.55), to: <gemini>), "-"),
        edge((rel: (0.2, -0.55), to: <gemini>), <post-out>, "-|>", mark-scale: 120%),
        edge((rel: (0.2,  0.55), to: <gemini>), <trend-out>, "-|>", mark-scale: 120%),

        json_box((3, -0.55), c_post, [Post-level output],
          ("state", "specifiers", "confidence", "reasoning"), width: 29mm, name: <post-out>),

        json_box((3, 0.55), c_trend, [Period-level output],
          ("dominant_state", "trend_direction", "change_points", "trend_summary", "confidence"), width: 29mm, name: <trend-out>),
      )
    ))
  },
  caption: [Annotation pipeline producing structured mood-state labels at two temporal granularities (post-level and 14-day period-level).],
) <fig-pipeline>

Posting to a mental-health-related subreddit is a necessary yet insufficient signal of a BD diagnosis: many such posts come from clinicians, family members, or general community participants. To screen the candidate pool, we apply an LLM three-tier classifier (Gemini 3.1 Pro, separate prompt) that scans each author's full posting history and returns `verified` (explicit first-person diagnostic statements, e.g., "I was diagnosed with bipolar II in 2019", or specific treatment/hospitalization narratives), `probable` (consistent self-identification through symptoms, medication, or community-membership tone without an explicit diagnosis statement), or `unverified` (no diagnostic signal). Only the `verified` and `probable` tiers are admitted to the annotation cohort; this matches the inclusion model used in prior BD social-media datasets @sekulic2018not @jagfeld2021understanding with stricter per-user evidence gating than a one-post membership rule.

== Annotation Schema <frameworksec>

Our annotation schema draws on DSM-5 episode definitions @apa2013dsm5, operationalizing them as a structured prompting framework for LLM-based annotation. The rules below were developed iteratively against an error analysis on external expert labels (see @errorsec); each clinical-guidance rule named below is the schema's response to a recurring failure mode characterized there. Because BD-Risk posts contain sensitive mental health disclosures, the error analysis illustrates each pattern with a synthetic case rather than verbatim post text, preserving the clinically relevant structure of the original disagreement.

=== Post-Level State Classification
For each individual post (submission or comment), the LLM assigns a categorical mood state from five options:

- *Manic:* Grandiosity, pressured writing (run-on sentences, excessive capitalization), flight of ideas (tangential topic shifts), extreme irritability or euphoria.
- *Hypomanic:* Elevated energy and pace with maintained coherence, social disinhibition, uncharacteristic intensity without psychotic features.
- *Depressive:* Linguistic constriction, absolutist language ("never," "nothing"), high self-focus (first-person pronouns), cognitive distortions, suicidal ideation.
- *Stable:* Balanced emotional tone, metacognitive reflection, proportionate responses, community-supportive language.
- *Uncertain:* Reserved for truly uninterpretable posts; the LLM must attempt classification before resorting to this label.

The framework also supports a `with_mixed_features` specifier (following DSM-5 mixed-features criteria). Before applying this specifier, the prompt requires the LLM to extract an explicit list of opposite-pole symptoms, and only assigns `with_mixed_features` when three or more clear opposite-pole symptoms are documented. This evidence-extraction step prevents the mixed-features specifier from being used as a vague neutral label.

=== Period-Level Trend Analysis
For longitudinal mood trajectory modeling, we partition each user's posting history into consecutive fixed-length periods (default: 14~days). The 14-day window length was set in consultation with clinical advisors and is grounded in DSM-5 episode-duration criteria, which define a major depressive episode as lasting at least two weeks and a manic episode as lasting at least one week @apa2013dsm5; a 14-day window therefore captures the minimum duration of a full depressive episode and allows observation of manic-episode onset and progression. Periods are anchored at the user's first post (day 0) and advance in strict half-open intervals $[t_(k), t_(k) + 14)$; submissions and comments are jointly assigned to the period containing their timestamp. All periods from the user's first to last post are defined; periods without posts receive a `NO_DATA` label rather than being skipped, preserving a continuous time grid for trajectory modeling. @fig-period-slicing illustrates the segmentation.

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

      text(weight: "bold", size: 7pt)[Period 1],
      text(weight: "bold", size: 7pt)[Period 2],
      text(weight: "bold", size: 7pt)[Period 3],
      text(weight: "bold", size: 7pt)[Period 4],
      text(weight: "bold", size: 7pt)[Period 5],
      text(weight: "bold", size: 7pt)[Period 6],

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
  caption: [Period segmentation (illustrative). Submissions (filled circles) and comments (open circles) fall in the period containing their timestamp; empty periods carry the `NO_DATA` label.],
) <fig-period-slicing>

For each period containing at least one post, the LLM analyzes the collected posts and produces:

- *Dominant state:* The primary mood state across the period (same five-class set as post-level), aggregated across the posts in the window.
- *Trend direction:* `NO_TREND` (state maintained), `TOWARDS_MANIA` / `TOWARDS_DEPRESSION` (progressive worsening toward the respective pole), or `FLUCTUATING` (alternation without a clear direction).
- *Change points:* Specific dates or events where a mood shift occurred, with pre- and post-shift states documented.
- *Trend summary:* A concise narrative describing the period's trajectory and the evidence supporting the dominant state.
- *DSM-5 specifiers:* `with_mixed_features` when opposite-pole symptoms co-occur within the period (distinguished from sequential fluctuation).

The two granularities support both event-level analysis (e.g., what preceded a state change) and longitudinal trajectory modeling, with the explicit change-point fields enabling change-point detection @truong2020selective at the textual level.

=== Few-Shot Example Construction
The post-level prompt is paired with eight synthetic few-shot examples (labeled A--H), written by the authors. Each exercises a schema rule targeting a failure mode observed during development (full analysis in @errorsec): A demonstrates _Behavior Over Tone_ on retrospective manic-side narration; B and~E demonstrate the _SAFETY OVERRIDE_ rule with its grandiose-mania exception; C and~D contrast _Improvement-Narrative_ against _Whole-Post Evidence Weighting_; F counters the default-to-_Uncertain_ tendency on short posts; G demonstrates the _Recurrent-Pattern Exception_ for substance-triggered hypomania; H exercises _Severity Descriptors_ for _Hypomanic_-vs-_Stable_ boundaries. Each example provides the input text with the full expected JSON output (including the `opposite_pole_symptoms` evidence list and reasoning), so the model observes both the target label and the evidence chain. The full prompt texts are available in the supplementary repository (see the Appendix).

= Validation Experiments

== External Validation Against BD-Risk <validsec>

The BD-Risk dataset @lee2024detecting comprises 7,346 Reddit posts from 1,025 users, each carrying a psychiatrist-guided mood level label on a 7-point scale ($-$3 to $+$3). Because the dataset selects users based on an initial MDD presentation (MDD-only and MDD$arrow$BD groups), it is structurally enriched for depressive-pole content (89.0% of posts $lt 0$).

The BD-Risk dataset provides only ordinal mood labels; categorical states are not directly annotated. To obtain gold states for evaluation, we derive them from BD-Risk mood labels using the mapping shown in @tab-mapping.

#figure(
  table(
    columns: 3,
    align: (center, center, left),
    stroke: none,
    table.hline(),
    table.header(
      [*BD-Risk mood label*], [*Derived gold state*], [*Notes*],
    ),
    table.hline(stroke: 0.5pt),
    [$-$3, $-$2, $-$1], [Depressive], [],
    [0, $+$1], [Stable], [$+$1 = high motivation / positive mood within normal range],
    [$+$2], [Hypomanic], [Clear manic-side activation without psychosis],
    [$+$3], [Manic], [Severe manic expression with psychotic features],
    table.hline(),
  ),
  caption: [Mapping from BD-Risk 7-point mood labels to derived gold states.],
) <tab-mapping>

The full BD-Risk dataset exhibits a heavily skewed mood distribution (89.0% of posts $lt$ 0). Because the deployment task is BD risk detection rather than general mood classification, we deliberately oversample manic-pole posts so that per-class metrics on the underrepresented classes are computed with sufficient support.

We separate the labeled posts into two disjoint subsets. A _development_ subset (314 posts) is used during prompt design and failure-mode analysis. A _held-out_ subset (145 posts) is used exclusively for the evaluation reported below; it is _author-disjoint_ from the development subset, drawn by stratified sampling from BD-Risk authors not present in the development subset, with quotas ensuring sufficient per-class support across the four derived gold states ($60$ _Depressive_, $40$ _Stable_, $30$ _Hypomanic_, $15$ _Manic_). All metrics in @bdresultsec are computed on the held-out subset; the development subset is never used to produce reported numbers. Manic-pole gold posts in BD-Risk come almost exclusively from the MDD$arrow$BD group, so the held-out manic-side samples are structurally MDD$arrow$BD-derived (a limitation discussed in @discussionsec).

== Evaluation Metrics <metricssec>

We report per-class precision, recall, and F1, along with overall accuracy and macro F1. Two accuracy variants are reported: accuracy _excluding_ _Uncertain_ treats _Uncertain_ outputs as abstentions and removes them from both numerator and denominator; accuracy _including_ _Uncertain_ counts _Uncertain_ as incorrect, providing a conservative lower bound. Per-class metrics are computed on the excluding-Uncertain basis.

== Evaluation Design <evaldesignsec>

Beyond the main BD-Risk holdout validation, we conduct three additional evaluations to characterize the schema's properties and situate its performance relative to supervised alternatives:

- *Zero-shot baseline comparison:* To quantify how much the structured annotation schema (DSM-5 rules, few-shot examples) contributes beyond the LLM's base capability, we re-evaluate the same model with a minimal zero-shot prompt containing only the task definition and output format.
- *Cross-model portability evaluation:* To test whether the schema generalizes beyond the primary annotator, we evaluate the full schema with five additional LLMs spanning five providers (Gemini 3.5 Flash, Claude Opus 4.8, DeepSeek V4 Pro, GLM-5.1, and GPT-5.5), characterizing schema portability, per-model manic-pole behavior, and the impact of provider-level content-policy differences on annotation feasibility.
- *Supervised fine-tuning baseline:* To assess whether task-specific fine-tuning with labeled data outperforms the proposed few-shot approach, we fine-tune ModernBERT-base @warner2025modernbert on progressively larger subsets of the 314-example training pool ($n in {50, 100, 200, 314}$) and evaluate on the same 145-example held-out set, providing a direct comparison under identical test conditions.

== LLM Configuration

We use Gemini 3.1 Pro @team2024gemini through the official API with structured JSON output; the model was selected for its large context window and native structured-output generation. Each post is processed independently with the full annotation schema and the few-shot examples described above as the system instruction; the model returns a JSON object with `state`, `opposite_pole_symptoms`, `specifiers`, `confidence` (High/Medium/Low), and `reasoning` fields, where `opposite_pole_symptoms` carries the explicit evidence list required before `with_mixed_features` can be assigned (see @frameworksec). For period-level annotation the LLM additionally returns `trend_direction`, `change_points`, and a `trend_summary` narrative, with `confidence` on a 0--1 scale. We use the Gemini-recommended default temperature of 1.0; Google's documentation for Gemini 3 models advises against lower values, as they may cause looping or degraded performance on complex reasoning tasks. The model is not fine-tuned.

== Validation Results <bdresultsec>

We first validate the post-level state classification against BD-Risk expert labels (@tab-state-metrics: per-class metrics with macro-aggregated summary); because the held-out subset is intentionally stratified across classes, macro F1 is the primary metric.

#figure(
  table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*State*], [*Precision*], [*Recall*], [*F1*], [*Support*],
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
  caption: [Per-class metrics with macro summary on the held-out subset (n=145; 138 excluding 7 _Uncertain_). Accuracy excluding/including _Uncertain_ = 65.9 % / 62.8 %.],
) <tab-state-metrics>

_Depressive_ recall is high (87.9%) and _Stable_ recall is moderate (78.4%), while _Hypomanic_ and _Manic_ recall remain low (35.7% and 6.7%), indicating that the LLM correctly recognizes most depressive and stable posts while missing a majority of manic-pole cases. The dominant error flow runs from the manic pole to _Depressive_: among the 30 gold-_Hypomanic_ posts, 12 are predicted _Depressive_ and 6 _Stable_; among the 15 gold-_Manic_ posts, 11 are predicted _Depressive_ and 2 _Stable_. These errors are concentrated on manic-pole posts whose activation is masked by negative tone, a pattern that the current prompt does not fully resolve. The Manic-to-Depressive error flow is a recurring pattern with a likely label-text origin that we discuss in @discussionsec.

== Supervised Fine-Tuning Baseline <bertsec>

To contextualize the few-shot LLM results, we compare against a supervised baseline. We fine-tune ModernBERT-base @warner2025modernbert (149M parameters) on the same BD-Risk training pool using progressively larger labeled subsets ($n in {50, 100, 200, 314}$), evaluating on the identical 145-example held-out set. Each tier is trained for 10 epochs with a learning rate of $2 times 10^(-5)$ and a maximum sequence length of 2,048 tokens; for tiers 50--200, we report the mean and standard deviation over five random training-set samples (seeds 42--46), while tier 314 uses all available training examples and reports variance over five random initializations. @tab-bert-baseline summarizes the results alongside the LLM conditions.

#figure(
  table(
    columns: 4,
    align: (left, left, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*Method*], [*Training data*], [*Macro F1*], [*$Delta$ vs. few-shot*],
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
  caption: [Supervised fine-tuning baseline vs.\ LLM annotation on the held-out subset ($n = 145$). ModernBERT results report mean $plus.minus$ std over 5 seeds. The few-shot LLM uses eight synthetic examples and requires no labeled training data.],
) <tab-bert-baseline>

ModernBERT macro F1 increases monotonically with training size (0.306 $arrow.r$ 0.398), yet even at the maximum available training size ($n = 314$), it falls short of Gemini few-shot (0.519) by 0.121 and barely approaches the Gemini zero-shot level (0.459). We additionally explored training for 15 and 20 epochs on the full 314-example set: 15 epochs reaches $0.454 plus.minus 0.038$ and 20 epochs $0.445 plus.minus 0.010$, narrowing the gap yet remaining below the few-shot result in both cases.

Per-class analysis reveals that ModernBERT shares the same manic-pole difficulty observed in the LLM results (@bdresultsec): across the five tier-314 runs, _Manic_ recall averages 0.04 (2 of 5 runs produce zero _Manic_ recall), while _Depressive_ and _Stable_ F1 average 0.51 and 0.62 respectively. This parallel suggests that the manic-pole limitation is rooted in the BD-Risk label--text relationship (@errorsec, Pattern~1) rather than in the choice of model architecture.

Labeling 314 training examples for BD mood-state classification required psychiatrist-guided annotation; the few-shot LLM approach outperforms this baseline using only eight synthetic prompt examples and no manual labeling.

== Interpretation of Validation Results

The LLM assigned _Uncertain_ to 7 posts (4.8%), abstaining when post content was insufficient for state assessment, consistent with the prompt's explicit instruction to prefer abstention over forced classification. _Uncertain_ emissions are distributed across gold classes (2 _Depressive_, 3 _Stable_, 2 _Hypomanic_, 0 _Manic_), with no strong concentration on a single pole.

=== Schema Contribution: Comparison with a Zero-Shot Baseline
Following the design in @evaldesignsec, we compare the full schema against a minimal zero-shot prompt on the held-out subset. The zero-shot prompt retains only the task definition (post $arrow.r$ one of five states) and the output JSON fields; all DSM-5 rules, _SAFETY OVERRIDE_, _Severity Descriptors_, and few-shot examples are removed. @tab-zeroshot reports the side-by-side metrics.

#figure(
  table(
    columns: 4,
    align: (left, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*Metric*], [*Zero-shot*], [*Full schema*], [*$Delta$*],
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
  caption: [Schema contribution on the held-out subset (n=145). Both runs use Gemini 3.1 Pro with identical JSON output; the only variable is the system prompt (minimal zero-shot versus the full schema).],
) <tab-zeroshot>

The schema's primary effect is reducing abstention and anchoring border-class decisions: _Uncertain_ emissions drop 4$times$ (27 $arrow.r$ 7) and _Stable_ F1 improves by +0.116 (driven by the Severity Descriptors' explicit rule that mild positive activation falls within _Stable_), which explains why the accuracy gain including _Uncertain_ (+11.1 pp) far exceeds the gain excluding it (+2.3 pp). _Depressive_ and _Hypomanic_ F1 are unchanged, and _Manic_ remains poorly recalled in both runs (0/15 zero-shot vs. 1/15 schema, counting _Uncertain_ as incorrect), indicating that the manic-pole limitation is structural (label-text consistency, @discussionsec) rather than a limitation resolved by this richer prompt.

=== Cross-Model Schema Portability <crossmodelsec>
To test generalization beyond Gemini 3.1 Pro, we apply the identical prompt and JSON format to five additional LLMs from five providers on the same 145-post subset. @tab-crossmodel reports the four with complete annotations; GPT-5.5, which declined a majority of posts, is reported in-text.

#figure(
  table(
    columns: 7,
    align: (left, right, right, right, right, right, right),
    stroke: none,
    inset: (x: 5pt, y: 2.2pt),
    table.hline(),
    table.header(
      [*Model*], [*N*], [*Macro F1*], [*Dep Rec*], [*Hyp Rec*], [*Man Rec*], [*Unc*],
    ),
    table.hline(stroke: 0.5pt),
    [Gemini 3.5 Flash],    [145], [$bold(0.564)$], [$0.850$], [$0.379$], [$0.200$], [3],
    [Gemini 3.1 Pro],      [145], [$0.519$],       [$0.879$], [$0.357$], [$0.067$], [7],
    [Claude Opus 4.8],     [145], [$0.535$],       [$0.932$], [$0.429$], [$0.067$], [7],
    [GLM-5.1],             [145], [$0.456$],       [$0.881$], [$0.286$], [$0.000$], [4],
    [DeepSeek V4 Pro],     [145], [$0.432$],       [$0.833$], [$0.241$], [$0.000$], [2],
    table.hline(),
  ),
  caption: [Cross-model evaluation on the held-out subset ($n = 145$), identical 8-example few-shot prompt. Macro F1 is over the four target classes, excluding _Uncertain_ (see @bdresultsec).],
) <tab-crossmodel>

The comparison yields three observations. First, the schema produces valid structured output across all five tabulated models with zero refusal (macro F1 0.432--0.564), indicating it is not provider-specific; GPT-5.5, by contrast, refused 103 of 145 posts under the identical prompt and reached 0.710 only on the 42 it answered, so we report it separately as not directly comparable. Second, manic-pole underdetection is consistent across families (zero _Manic_ recall for DeepSeek V4 Pro and GLM-5.1; 6.7% for Claude Opus 4.8 and Gemini 3.1 Pro; 20.0% for Gemini 3.5 Flash), reinforcing the structural interpretation (@discussionsec) that the difficulty stems from the BD-Risk label--text relationship rather than any single model. Third, _Hypomanic_ recall varies more (0.241--0.429), consistent with manic-side detection hinging on the model's ability to read behavioral cues over affective tone (Pattern~1, @errorsec).

Gemini 3.5 Flash achieves the highest macro F1 (0.564) among models evaluated on the full held-out subset, exceeding Gemini 3.1 Pro by 0.045. Because the corpus was annotated with Gemini 3.1 Pro prior to this cross-model comparison, the existing annotations remain unchanged; the result indicates that schema performance improves with model capability and that re-annotation with newer models could improve manic-pole coverage.

GPT-5.5 declined to classify 103 of 145 held-out posts (71.0%) with a verbatim refusal (`"I'm sorry, but I cannot assist with that request."`), concentrated on posts containing explicit self-harm or suicidal content. The prompt's clinical-research framing did not overcome the refusal. On the 42 posts GPT-5.5 did classify (skewed away from depressive-crisis content: 16 _Depressive_, 10 _Stable_, 12 _Hypomanic_, 4 _Manic_), it achieved macro F1 of 0.710, driven primarily by higher _Manic_ recall (2/4). The subset selection is the dominant effect: GPT-5.5 systematically filtered out the hard depressive-crisis posts that drive most of Gemini's error rate, so the macro-F1 comparison overstates GPT-5.5's effective competence. A 71% refusal rate renders GPT-5.5 infeasible as a stand-alone annotator for psychiatric corpora regardless of intrinsic capability.

=== Error Analysis <errorsec>
We characterize six failure modes identified through manual analysis of LLM-vs-BD-Risk disagreements on the development subset. For each pattern, we name the schema rule designed to mitigate it and note whether the rule resolves the pattern on the held-out subset or whether it remains a residual error. Manic-pole posts misclassified as depressive or stable remain the dominant residual failure mode (quantified in @bdresultsec).

Pattern 1, the dominant manic-side error, is the LLM ignoring retrospective behavioral cues. When users describe manic-episode behaviors (impulsive spending, aggressive confrontations, hyperactivity) in a retrospective post written with remorse or self-blame, the LLM anchors on the _current emotional tone_ rather than the _clinical significance of the described behaviors_, and predicts _Depressive_. The schema's _Behavior Over Tone_ rule directly targets this conflation; however, it remains the dominant residual error on the held-out subset, indicating that the rule reduces the pattern without fully eliminating it. _Synthetic case:_ a user recounts a week of reckless spending and impulsive decisions in a tone of deep regret and self-condemnation; gold is _Hypomanic_ (the behaviors are hallmark manic symptoms), the LLM predicts _Depressive_ (anchored on the self-deprecating tone).

Pattern 2 is the conflation of mixed features with neutrality. When a post carries symptoms from both poles simultaneously (e.g., severe sleep disruption and inability to concentrate alongside aggressive outbursts), the LLM sometimes treats the coexistence as cancellation and defaults to _Stable_. Under DSM-5 @apa2013dsm5, mixed features should instead surface as a `with_mixed_features` specifier on the dominant pole. The schema's mixed-features rules reduce this conflation, though residual instances remain when symptom signals are subtle. _Synthetic case:_ a user writes that they have not slept in three days, cannot focus at work, and snapped at their partner, all in the same post; gold is _Hypomanic_ with mixed features (decreased need for sleep alongside dysphoric irritability), the LLM predicts _Stable_ on the reasoning that the signals "balance out".

Pattern 3, a safety-critical case, is calm writing style masking suicidal ideation. Some posts express suicidal ideation ("I want to die") in calm, reflective, or educational prose; the LLM reads the linguistic register as stable and classifies accordingly, while the gold state is _Depressive_ ($-$3). Calm writing does not rule out suicidal crisis, and the schema's explicit _SAFETY OVERRIDE_ rule forces _Depressive_ whenever crisis-level language is present regardless of surrounding tone. On the held-out subset, no _Stable_ or _Uncertain_ predictions were observed for posts with explicit suicidal content, suggesting that the rule addresses this pattern on the evaluated subset. _Synthetic case:_ a user posts a coherent essay about public misconceptions of depression; embedded in the second paragraph, in the same calm register, is a single sentence noting that the writer quietly thinks about not waking up most mornings.

Pattern 4 is end-of-post hope overriding pervasive impairment. Posts describing severe functional impairment (academic collapse, inability to maintain daily routines, social withdrawal) sometimes close with a single hopeful sentence (e.g., "my therapist said maybe I shouldn't give up"), and the LLM anchors on this terminal positive signal (consistent with a recency bias) to predict _Stable_ while the gold label tracks the pervasive impairment throughout. The schema's _Whole-Post Evidence Weighting_ rule addresses this by instructing the LLM to weigh the dominant clinical picture over terminal sentiment; the zero-shot comparison (@tab-zeroshot) shows that the full schema improves _Stable_ F1 by +0.116, consistent with reduced over-assignment of _Stable_ to impaired posts. _Synthetic case:_ a user reports missing every class for a month, eating almost nothing this week, and losing the ability to reply to friends, closing with "maybe tomorrow will be different"; gold is _Depressive_ on the pervasive impairment, the LLM predicts _Stable_.

Pattern 5 concerns substance-induced activation versus endogenous mood. When users describe mood elevation explicitly attributed to substances (e.g., caffeine-induced euphoria described as feeling "on top of the world"), the LLM may interpret these cues as hypomanic mood, while gold labels distinguish acute pharmacological activation from endogenous baseline. The schema's _Substance vs. Endogenous Mood_ rule addresses this boundary and also covers the _Recurrent-Pattern Exception_ where an unusual reactivity to a common substance is itself bipolar-spectrum. This pattern is rare in the held-out subset; the rule's primary effect is preventing false _Hypomanic_ predictions on substance-attributed posts. _Synthetic case:_ a user writes that after a fourth coffee they suddenly feel "unbeatable and ready to overhaul" their apartment, attributing the surge to caffeine and expecting an evening crash; gold is _Stable_ (acute, externally caused, self-labeled), the LLM predicts _Hypomanic_ on the surface cues.

Pattern 6 is _Uncertain_ masking embedded clinical signals. _Uncertain_ functions appropriately in the large majority of cases; the failure described here is rare. The LLM correctly identifies the post as metacommentary or informational, then fails to surface clinically significant content embedded inside. _Synthetic case:_ a user writes a meta-commentary criticizing how recovery is portrayed online and, mid-argument, notes parenthetically that they have been thinking about ending things; gold is _Depressive_, the LLM defaults to _Uncertain_ on the meta-discussion register. The _SAFETY OVERRIDE_ rule mitigates this pattern by forcing _Depressive_ on crisis-level language regardless of overall framing. Like Pattern 3, the rule appears effective on the held-out subset: no crisis-level posts were classified as _Uncertain_.


= Longitudinal Demonstration: Period-Level Mood Trends <pilotsec>

We continuously crawl three BD-focused subreddits (r/bipolar, r/BipolarReddit, r/bipolar2) via the Reddit API, retrieving each active author's full posting history (submissions and comments) with periodic re-crawls to capture ongoing activity. After the patient verification described in @resourcesec, the verified+probable cohort comprises 115 of 124 candidate authors. Users with fewer than two 14-day periods containing posts (i.e., insufficient longitudinal span for trend analysis) are excluded. The remaining 105 users contribute 2,611 submissions and 12,812 comments spanning April 2019 through May 2026, yielding 1,794 valid analysis periods.

#figure(
  image("fig_timeline.svg", width: 100%),
  caption: [Mood trajectories for four anonymized users (A: depressive with fluctuation, 49 periods; B: hypomanic-leaning with frequent manic transitions, 74 periods; C: manic-dominant with rapid cycling, 36 periods; D: dense posting with high mixed-features incidence, 25 periods). Each bar is a 14-day period; a thin black border marks `with_mixed_features`. Dots above bars are post-level annotations colored by post state. State and trend encodings follow the legend.],
) <fig-user-timeline>

Most 14-day windows show `NO_TREND` (83.9%); `TOWARDS_DEPRESSION` and `TOWARDS_MANIA` account for 5.9% and 4.3% respectively. _Stable_ and _Depressive_ states dominate (42.6% and 31.4% of periods), while manic-pole states are less frequent (_Hypomanic_ 8.8%, _Manic_ 3.0%). These distributions are interpreted in @discussionsec.

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
        [*Trend direction*], [*Periods*], [*%*],
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
        [*Dominant state*], [*Periods*], [*%*],
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
  caption: [Period-level distributions on the 105-user cohort ($n = 1,794$): trend directions (left) and dominant states (right). The `with_mixed_features` specifier was applied to 84 periods (4.7%).],
) <tab-pilot-dists>

Submissions ($n = 2,611$) carry the majority of polar-state labels: 36.8% _Depressive_, 10.6% _Hypomanic_, 3.8% _Manic_, 46.6% _Stable_, and 2.2% _Uncertain_. Comments ($n = 12,812$) are predominantly conversational replies labeled _Stable_ (88.1%), with polar states comprising only 8.9% of comments. The submission--comment asymmetry and its implications are discussed in @discussionsec.


= Discussion <discussionsec>

From the trend distribution (@pilotsec), four observations stand out. (1) `TOWARDS_MANIA` and `TOWARDS_DEPRESSION` trends are rare yet among the most clinically significant signals, as they mark episode onset where intervention has the most impact. (2) `FLUCTUATING` periods may correspond to rapid cycling or mixed presentations that single-post labels cannot capture. (3) Post-level states and period-level trends together enable hierarchical modeling: predicting the next period's trajectory from the sequence of post-level features. (4) The dominant-state distribution preserves sufficient manic-pole representation (_Hypomanic_ 8.8%, _Manic_ 3.0%), in contrast to MDD-selected cohorts (BD-Risk: 89.0% depressive-pole); this balance matters for downstream models that must distinguish manic-pole from depressive states. The trend distributions broadly match long-term BD cohort studies @grande2016bipolar while reflecting the selection and posting biases of Reddit communities; direct external validation would require period-level expert annotations. A complementary direction is to model the absence signal in `NO_DATA` periods: reduced posting is sometimes associated with depression in digital-phenotyping research @faurholt2018smartphone, yet the relationship is heterogeneous, so absence modeling would require posting-frequency baselines beyond a text-based pipeline.

Submissions and comments differ sharply: 51.2% of submissions carry a polar state vs.~8.9% of comments, which are dominated by _Stable_ (88.1%). Submissions are longer-form disclosures while comments are short replies. Two downstream implications: a per-post classifier on a comment-heavy corpus is likely to appear over-confident on _Stable_, so per-content-type metrics are preferable to a single aggregate; and trajectory models should either up-weight submissions or rely on the period-level dominant-state annotation (which already aggregates across content types within the window) as the primary trajectory signal.

The LLM achieves 87.9% recall for _Depressive_ yet only 35.7% for _Hypomanic_ and 6.7% for _Manic_ on the held-out subset. Two factors compound this asymmetry. First, a model property: depressive language has stereotypical surface markers (negativity, self-focus, hopelessness), while manic-pole states often manifest through _described behaviors_ (spending sprees, reduced sleep need, grandiose plans) narrated in any tone, and the LLM reads tone rather than the clinical significance of the behaviors described (see Pattern~1 in @errorsec). Second, a label--text consistency issue in the BD-Risk annotation rule: as specified by #cite(<lee2024detecting>, form: "prose") (Section~3.2), "posts exhibiting both manic and depressive moods are regarded as manic moods", an asymmetric tie-breaker that elevates any mixed manic+depressive post to the manic side. Combined with the dataset's MDD$arrow$BD selection criteria, this yields gold-label _Manic_ ($+$3) posts whose textual content matches BD-Risk's own definition of $-$3 ("extreme anxiety and having suicidal thoughts"). A single-post LLM applying clinical-safety priors (classifying explicit self-harm content as _Depressive_) will systematically underperform on these posts, since the only signal it has is the very content the labeling rule overrode. The cross-model evaluation (@crossmodelsec) provides direct evidence for the structural interpretation: across six LLMs from five providers, _Manic_ recall ranges from 0.0% (DeepSeek V4 Pro, GLM-5.1) to 20.0% (Gemini 3.5 Flash), and the supervised ModernBERT baseline averages 4.0% (@bertsec); all architectures converge on the same manic-pole floor. The Manic-recall ceiling in @tab-state-metrics thus reflects a structural mismatch, not solely a model limitation (downstream implications in Limitations).

= Limitations

The proposed method and corpus are subject to constraints that we group into evaluation scope, gold-state derivation, manic-pole interpretability, cohort framing, and release-time reliability.

The cross-model evaluation (@crossmodelsec) confirms schema portability across five additional LLMs (macro F1 0.432--0.564 on the full 145-post holdout), yet the corpus itself was annotated exclusively with Gemini 3.1 Pro; per-class reliability estimates thus remain Gemini-specific. The quantitative validation is also at the post level only, because few per-post expert-labeled BD datasets at sufficient scale are available for research use (BD-Risk was obtained through a formal data request and ethics review, and comparable shared-task corpora face similar access barriers); period-level trends, a key contribution of the method, are not externally validated.

Gold states are derived from BD-Risk ordinal mood labels via a deterministic mapping (@tab-mapping) rather than being directly annotated as categorical states. This introduces boundary imprecision (e.g., mood label $+$1 may reflect mild hypomania rather than stable mood, and an ordinal intensity score need not match a categorical clinical judgment), and mapping the ordinal labels (inter-expert Krippendorff's $alpha$ = 0.87) to categories amplifies disagreement at boundaries. Some apparent misclassifications may thus be mapping artifacts, and reported accuracies should be read as lower bounds on the schema's true reliability.

Two factors limit how the Manic-pole numbers can be read. First, the held-out _Manic_ class is small ($n=15$, because the entire BD-Risk dataset contains only 28 mood-$+$3 posts); the 95% confidence interval around the Manic-F1 estimate is wide ($plus.minus$ approximately 13 percentage points), and small Manic-F1 differences should not be interpreted as significant. Second, the Manic-recall ceiling of 6.7% is bounded by a structural mismatch between BD-Risk's asymmetric tie-breaking rule and the textual evidence available to a per-post classifier (full analysis in @discussionsec); recovering label-text consistency would require either re-annotation under text-only criteria or a longitudinal evaluation protocol that supplies the temporal context the annotators had access to.

Patient verification is LLM-based, screening for self-disclosed BD diagnosis in a user's posting history rather than providing clinical confirmation; it follows prior BD social-media datasets @sekulic2018not @jagfeld2021understanding with stricter per-user evidence gating than a one-post membership rule. The cohort may include `verified` or `probable` users describing an unconfirmed diagnosis and conversely exclude users with BD who never disclose it, and Reddit is a self-selected, asynchronous channel whose relationship to clinically observed mood states requires further study. Downstream uses requiring clinician-confirmed status should treat the cohort as an LLM-screened self-identified sample, not a clinical cohort.

All annotations are produced entirely by the LLM without manual spot-checking. Per-class reliability decreases from _Depressive_ through _Hypomanic_ to _Manic_ (see @tab-state-metrics); _Manic_ labels should be used with caution given both the small support and the manic-pole interpretability constraints above.

= Conclusion

The validation separates the proposed method's two failure sources: 87.9% depressive recall suggests that the schema captures dominant depressive-pole markers with reasonable coverage, while the 6.7% manic recall appears strongly influenced by a structural label-text consistency issue at the manic pole rather than by prompting alone (see @discussionsec). Because no external longitudinal ground truth exists at the period level, the corpus's 1,794 trajectories are validated only indirectly through their post-level constituents. Three near-term priorities follow: (1) expert annotation of period-level trends to enable direct longitudinal validation; (2) a stratified human-in-the-loop audit across mood states, confidence levels, and trend directions, reported as inter-annotator agreement; and (3) re-annotation of the corpus with a higher-performing model (e.g., Gemini 3.5 Flash, which achieved 0.564 in the cross-model evaluation) to improve manic-pole coverage, combined with targeted prompt revision for the behavioral-cue recognition failure documented in Pattern~1 of @errorsec. The resulting corpus is intended for computational mental health research and should not be used as a clinical diagnostic tool.

= Ethical Considerations <ethicssec>

This study involves analysis of publicly posted social media content discussing sensitive mental health experiences. The study protocol was reviewed and approved by the Research Ethics Committee of the University of Tsukuba (approval no.~25-188). We additionally adhere to Reddit's privacy policy and social media research ethics guidelines @harrigian2021state.

Before public release, all post content undergoes LLM-based de-identification across five risk-ranked PII categories (identifiers, quasi-identifiers, contact information, linkage codes, personal identification codes), each detected span replaced by a category-specific placeholder. Unlike rule-based or NER approaches, the LLM also detects accumulated long-span quasi-identifiers (individually innocuous details such as occupation, location, and family structure that jointly narrow identification to one person) while preserving clinically relevant content (medications, diagnoses, symptoms, relative temporal expressions). The full taxonomy and prompt are provided in the supplementary repository.

The dataset retains only text content and temporal information necessary for mood-state annotation; author usernames are replaced with anonymized identifiers, and subreddit membership and post metadata that could facilitate re-identification are excluded from the published dataset. To reduce search-based re-identification risk, released timelines use relative temporal offsets rather than exact posting times. Because LLM-based de-identification may miss residual quasi-identifiers, public release is conditioned on a pre-release privacy audit of a stratified sample. The dataset is intended solely for computational mental-health research and must not be used for re-identification, commercial profiling, or clinical decision-making without appropriate expert oversight.

// Appendix: per the Springer proceedings instructions, a single appendix is
// designated "Appendix" (unnumbered), placed before the references, and
// referred to in the text. (Multiple appendices would be "Appendix 1", etc.)
#set heading(numbering: none)

= Appendix

Four system prompts drive the pipeline: (A) the post-level annotation prompt with the full DSM-5-grounded schema and eight synthetic few-shot examples; (B) the 14-day period-level trend prompt; (C) the patient verification prompt; and (D) the de-identification prompt. A minimal zero-shot variant of prompt~(A) is used for the schema contribution comparison (@evaldesignsec). Full prompt texts, pipeline source, and evaluation scripts are released at #link("https://anonymous.4open.science/r/bd-state-annotation/").
