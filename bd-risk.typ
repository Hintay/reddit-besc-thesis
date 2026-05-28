#import "@preview/fine-lncs:0.6.3": lncs, institute, author, theorem, proof

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
    Bipolar disorder (BD) is frequently misdiagnosed as major depressive disorder (MDD), and monitoring mood state _transitions_ over time is critical for timely intervention. Existing social media datasets for BD research typically provide only binary diagnostic labels or per-post mood scores; few capture mood trajectories, i.e., the temporal dynamics of state transitions that define BD clinically. Because constructing expert-annotated BD corpora is costly and fine-tuning requires scarce labeled data, we propose a few-shot prompt-based LLM method that requires no task-specific training: the annotation schema is grounded entirely in DSM-5 episode criteria and eight synthetic few-shot examples, making it directly applicable to other BD corpora. The method annotates social media posts at two granularities: per-post categorical mood state classification and 14-day period-level mood trend analysis. The latter captures dominant mood state, trend direction (stable, worsening toward mania or depression, or fluctuating), and clinical change points within each period, enabling computational modeling of mood trajectories that per-post labels alone cannot support. Implemented with Gemini 3.1 Pro, we apply the method to 105 self-identified BD users drawn from BD-focused subreddits (1,794 14-day periods, 2,642 submissions, 12,847 comments spanning April 2019 through May 2026) and observe mood distributions consistent with known BD epidemiology. Post-level state classification is externally validated against the BD-Risk dataset @lee2024detecting on a held-out, author-disjoint, stratified subset of 145 posts, achieving macro F1 of 0.519 with high depressive recall (87.9%) and lower manic-pole recall (35.7%/6.7%). Six clinically significant error patterns are characterized, and we identify a structural label-text consistency issue at the manic pole that bounds achievable per-post manic recall.
  ],
  keywords: ("Bipolar Disorder", "Large Language Models", "Few-Shot Prompting", "Social Media", "Clinical NLP", "Mood Trajectory"),
  bibliography: bibliography("refs.bib"),
)


= Introduction

Bipolar disorder (BD) is characterized by recurrent episodes of mania, hypomania, and depression, affecting 1--2% of the global population @grande2016bipolar. An estimated 17--50% of BD cases are initially misdiagnosed as major depressive disorder (MDD), because patients typically seek help during depressive episodes and may not recognize manic or hypomanic states as pathological @hirschfeld2003misdiagnosis @vieta2018misdiagnosis. This misdiagnosis leads to inappropriate treatment (e.g., antidepressant monotherapy, which may trigger manic switching) and delays proper intervention.

Social media platforms such as Reddit host BD communities (e.g., r/bipolar, r/BipolarReddit) where users openly discuss symptoms, treatment, and daily functioning. Prior work has used these data for BD and MDD classification @cohan2018smhd @coppersmith2015clpsych @sekulic2018not, yet existing datasets provide only binary diagnosis labels (BD vs.~MDD) or user-level risk scores. Few resources offer post-level mood state labels tracked over time, which limits computational research on mood trajectories --- a capability important for understanding BD progression and identifying early intervention opportunities.

Constructing expert-annotated BD corpora is costly: mood-state labeling requires psychiatric expertise, and the scarcity of labeled data makes fine-tuning approaches difficult to scale. At the same time, recent advances in large language models (LLMs) suggest that they can follow human-written guidelines with reasonable accuracy on text annotation tasks @gilardi2023chatgpt. This motivates our approach: if LLMs can internalize clinical guidelines presented in a prompt, then a carefully designed DSM-5-grounded prompt with synthetic few-shot examples should enable mood-state annotation _without task-specific fine-tuning or labeled training data_, making the method directly applicable to new BD corpora.

Recent work has applied LLMs to mental health NLP tasks @xu2024mental @yang2024mentallama; however, whether they can classify BD mood states at expert-level accuracy, especially manic-pole states that are difficult to detect from text, has not been established.

This paper proposes a few-shot prompt-based LLM method for longitudinal mood-state analysis of BD on social media and demonstrates it by constructing a longitudinal mood-state-labeled corpus. We collect Reddit posts from users who self-identify as having a BD diagnosis in BD-focused subreddits (r/bipolar, r/BipolarReddit, r/bipolar2) and annotate them at two granularities: (1) per-post mood state (Depressive, Stable, Hypomanic, Manic) and (2) 14-day period-level mood trends (dominant state, trend direction, change points). The annotation schema follows DSM-5 episode criteria and is implemented as an LLM pipeline (Gemini 3.1 Pro). We validate the post-level annotations against the BD-Risk dataset @lee2024detecting on a held-out, author-disjoint, stratified subset of 145 posts, achieving macro F1 of 0.519 with 87.9% depressive recall and 35.7%/6.7% recall on hypomania/mania. The recall asymmetry across poles reflects both a known model property (manic-side states often manifest through described behaviors rather than affective tone) and a structural label-text consistency issue with the source dataset's manic-pole labels.

Our contributions:
+ *Method:* A DSM-5-grounded few-shot prompt schema for LLM-based mood-state annotation at two temporal granularities (per-post state and 14-day period-level trend), requiring no fine-tuning or labeled training data.
+ *Evaluation:* External validation of post-level state classification against the BD-Risk expert-labeled dataset @lee2024detecting on a held-out, author-disjoint, stratified subset, with macro F1 of 0.519 (87.9% depressive recall, 35.7% hypomanic recall, 6.7% manic recall), complemented by a zero-shot baseline comparison and a cross-model feasibility probe.
+ *Demonstration:* Application of the method to 105 self-identified BD users from BD-focused subreddits (1,794 14-day periods, 15,489 posts and comments spanning April 2019 through May 2026), producing longitudinal mood trajectory annotations with distributions consistent with clinical expectations.


= Related Work

== Longitudinal Mood Monitoring in BD

Clinical efforts to track BD mood trajectories rely heavily on ecological momentary assessment (EMA) and digital phenotyping with smartphone sensors and self-report apps @faurholt2018smartphone @torous2016new. These approaches yield dense, high-frequency mood signals; however, they require active patient enrollment and consent, limiting cohort size and external use. Social media offers a complementary unobtrusive source: it provides passive, naturally produced language data over months to years for users already discussing their condition. To date, however, mood trajectory annotations of social media data at the period level have not been released as a public resource.

== Social Media in Mental Health Detection

De Choudhury et al.~@dechoudhury2013predicting showed that social media signals can predict depression onset. The SMHD dataset @cohan2018smhd covers nine mental health conditions via self-reported diagnoses; Coppersmith et al.~@coppersmith2015clpsych established shared tasks for depression and PTSD detection from X (formerly Twitter).

For BD, Sekuli\'c et al.~@sekulic2018not proposed Reddit-based classification and Jagfeld et al.~@jagfeld2021understanding compiled a large BD Reddit corpus; however, both rely on self-reported diagnoses without expert validation @harrigian2021state @stanton2020critical. The BD-Risk dataset @lee2024detecting provides per-post mood labels validated by a psychiatrist and a clinical psychologist; we use it as the gold standard for our post-level validation.

== LLMs for Clinical NLP and Mental Health

Xu et al.~@xu2024mental evaluated LLMs on mental health prediction from online text; Yang et al.~@yang2024mentallama fine-tuned MentalLLaMA for interpretable mental health analysis. Lee et al.~@lee2024detecting found that ChatGPT achieved only an F1 of 0.130 on BD risk detection (vs.~0.578 for their multi-task model), showing that off-the-shelf LLMs struggle with BD-specific tasks. On the more general question of LLM annotation quality, Gilardi et al.~@gilardi2023chatgpt show that ChatGPT can match or exceed crowd workers on text annotation tasks; our work follows this line by treating the LLM as an annotator (not a classifier) and grounding its outputs in an explicit DSM-5-derived schema.

Our work differs from these evaluations in that we do not predict diagnosis. Instead, we propose a prompt-based method that _annotates_ per-post mood states and period-level trends, and validate the annotations against expert labels. The error analysis (@errorsec) characterizes the failure modes that the schema must address and that downstream users should remain aware of.


= Methodology

== Method Overview <resourcesec>

We construct a longitudinal mood-state-labeled corpus by applying the proposed method to Reddit data from users who self-identify as having a BD diagnosis in BD-focused subreddits. The pipeline produces annotations at two temporal granularities: (1) per-post mood state classification and (2) 14-day period-level mood trend analysis. @fig-pipeline illustrates the end-to-end flow from data collection through LLM-based annotation.

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

    // Sub-box inside the LLM prompts compound (one per prompt).
    // `justify: false` prevents single-word wrapped lines (e.g. "A.") from
    // being stretched to the box width, which would read as a left indent;
    // `hyphenate: false` blocks mid-word breaks like "rea-soning".
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
          align(left, text(size: 5.5pt, fill: luma(40))[• *Task:* #task]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *Rules:* #rules]),
          align(left, text(size: 5.5pt, fill: luma(40))[• *Output schema:* #schema]),
        )
      },
    )

    // The "LLM prompts" compound node wraps the two sub-boxes (A above B)
    // with a single dashed border so it reads as one stage.
    let llm_prompts = node(
      (2, 0),
      {
        set par(first-line-indent: 0pt, justify: false)
        set text(hyphenate: false)
        stack(dir: ttb, spacing: 3pt,
          align(center, text(weight: "bold", size: 9pt, fill: rgb(c_annot))[LLM prompts]),
          grid(
            columns: (1fr, 1fr),
            column-gutter: 3pt,
            prompt_subbox(
              [A. Single-post prompt],
              [classify each post independently],
              [DSM-5, safety override, behavior over tone],
              [state, opposite\_pole\_symptoms, specifiers, confidence, reasoning],
            ),
            prompt_subbox(
              [B. 14-day trend prompt],
              [analyze each 14-day period],
              [whole-period weighting, mixed features],
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

    // JSON-style output box (monospace, code-like).
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

    // The diagram's natural width exceeds the LNCS column, so we render it
    // at full size then scale uniformly to fit. `reflow: true` makes the
    // bounding box collapse to the scaled size (otherwise the surrounding
    // layout would still reserve the un-scaled width).
    align(center, scale(x: 74%, y: 74%, reflow: true,
      diagram(
        spacing: (5mm, 2mm),
        edge-stroke: 0.6pt + black,
        mark-scale: 60%,

        // Row 0: main pipeline (Gemini sits left of the output column).
        make_box((0, 0), icon_globe, c_data, [Data collection],
          ([Reddit API], [3 BD subreddits]), width: 20mm),
        edge((0, 0), (1, 0), "-|>", elabel[115\ users]),

        make_box((1, 0), icon_shield, c_verify, [Patient verification],
          ([LLM evidence], [3-tier classifier]), width: 22mm),
        edge((1, 0), (2, 0), "-|>", elabel[100/115\ verified]),

        llm_prompts,
        edge((2, 0), (3, 0), "-|>"),

        make_box((3, 0), icon_brain, c_annot, [Gemini\ 3.1 Pro],
          ([DSM-5-guided], [annotation]), width: 22mm),

        // Brace-style fork from Gemini to the two outputs. The vertical
        // spine sits at x=3.3 (not 3.5) so the arrow tips have visible
        // length after fletcher clips them at the wide output boxes'
        // left edges. Drawn as separate edges so fletcher renders the
        // arrowheads at the output ends; outputs at rows ±0.55 to keep
        // the vertical gap compact.
        edge((3, 0), (3.3, 0), "-"),
        edge((3.3, -0.55), (3.3, 0.55), "-"),
        edge((3.3, -0.55), (4, -0.55), "-|>", mark-scale: 120%),
        edge((3.3,  0.55), (4,  0.55), "-|>", mark-scale: 120%),

        json_box((4, -0.55), c_post, [Post-level output],
          ("state", "specifiers", "confidence", "reasoning"), width: 30mm),

        json_box((4, 0.55), c_trend, [Period-level output],
          ("dominant_state", "trend_direction", "change_points", "trend_summary", "confidence"), width: 30mm),
      )
    ))
  },
  caption: [Annotation pipeline. Users are continuously collected from three BD-focused subreddits and screened by a patient-verification step (LLM-evidence-based three-tier classifier). The verified cohort is then annotated by Gemini 3.1 Pro using two DSM-5-grounded prompts --- a single-post prompt and a 14-day trend prompt --- yielding structured JSON outputs at two temporal granularities: per-post states and 14-day period trends.],
) <fig-pipeline>

*Data collection.* We continuously monitor three BD-focused subreddits (r/bipolar, r/BipolarReddit, r/bipolar2) using the Reddit API. For each active author discovered, we retrieve their complete posting history (submissions and comments) and schedule periodic re-crawls with a configurable cooldown to capture ongoing activity.

*Patient verification.* Posting to a BD-focused subreddit is necessary but not sufficient for self-identification: many such posts come from clinicians, family members, or community discussion that does not reflect the author's own diagnostic status. To screen the candidate pool, we apply an LLM-based three-tier classifier (Gemini 3.1 Pro, separate prompt from the annotation schema) that scans each author's complete posting history for explicit self-disclosure of BD diagnosis. The classifier returns one of three labels with supporting textual evidence: `verified` (explicit first-person diagnostic statements such as "I was diagnosed with bipolar II in 2019" or specific treatment / hospitalization narratives), `probable` (consistent self-identification through symptom descriptions, medication mentions, or community membership tone without an explicit diagnosis statement), or `unverified` (no diagnostic signal, third-party discussion, or off-topic activity). Only users in the `verified` or `probable` tiers are admitted to the annotation cohort. The verification step is LLM-based and screens for self-disclosure rather than clinician-confirmed diagnosis (see Limitations); it matches the inclusion model used in prior BD social-media datasets @sekulic2018not @jagfeld2021understanding while applying tighter per-user evidence gating than a one-post membership rule.

*Scale.* The verified+probable cohort comprises 115 users. Users with fewer than two 14-day periods containing posts (i.e., insufficient longitudinal span for trend analysis) are excluded. The remaining 105 users contribute 2,642 submissions and 12,847 comments spanning April 2019 through May 2026, yielding 1,794 valid analysis periods.

== Annotation Schema <frameworksec>

Our annotation schema draws on DSM-5 episode definitions @apa2013dsm5, operationalizing them as a structured prompting framework for LLM-based annotation. The schema described below was developed alongside an error analysis against external expert labels (see @errorsec) that characterizes its known failure modes. It produces annotations at two temporal granularities:

=== Post-Level State Classification

For each individual post (submission or comment), the LLM assigns a categorical mood state from five options:

- *Manic:* Grandiosity, pressured writing (run-on sentences, excessive capitalization), flight of ideas (tangential topic shifts), extreme irritability or euphoria.
- *Hypomanic:* Elevated energy and pace with maintained coherence, social disinhibition, uncharacteristic intensity without psychotic features.
- *Depressive:* Linguistic constriction, absolutist language ("never," "nothing"), high self-focus (first-person pronouns), cognitive distortions, suicidal ideation.
- *Stable:* Balanced emotional tone, metacognitive reflection, proportionate responses, community-supportive language.
- *Uncertain:* Reserved for truly uninterpretable posts; the LLM must attempt classification before resorting to this label.

The framework also supports a `with_mixed_features` specifier (following DSM-5 mixed-features criteria). Before applying this specifier, the prompt requires the LLM to extract an explicit list of opposite-pole symptoms, and only assigns `with_mixed_features` when three or more clear opposite-pole symptoms are documented. This evidence-extraction step prevents the mixed-features specifier from being used as a vague neutral label.

=== Period-Level Trend Analysis

For longitudinal mood trajectory modeling, we partition each user's posting history into consecutive fixed-length periods (default: 14~days). The 14-day window length is informed by DSM-5 diagnostic criteria, which define a major depressive episode as lasting at least two weeks and a manic episode as lasting at least one week @apa2013dsm5; a 14-day window therefore captures the minimum duration of a full depressive episode and allows observation of manic episode onset and progression. Periods are anchored at the user's first post (day 0) and advance in strict half-open intervals $[t_(k), t_(k) + 14)$; submissions and comments are jointly assigned to the period containing their timestamp. All periods from the user's first to last post are defined; periods without posts receive a `NO_DATA` label rather than being skipped, preserving a continuous time grid for trajectory modeling. @fig-period-slicing illustrates the segmentation.

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
  caption: [Period segmentation for a single user (illustrative). Each box is a fixed 14-day window anchored to the user's first post (day 0). Submissions (filled circles) and comments (open circles) are jointly assigned to the period containing their timestamp. A period without posts (Period 3) is retained with a `NO_DATA` label rather than skipped, ensuring that downstream trajectory models see a continuous time grid.],
) <fig-period-slicing>

For each period containing at least one post, the LLM analyzes the collected posts and produces:

- *Dominant state:* The primary mood state across the period (Manic, Hypomanic, Depressive, or Stable), using the same clinical criteria as post-level classification while aggregating evidence across multiple posts within the window.
- *Trend direction:* The trajectory of mood change during the period:
  - `NO_TREND`: the user maintains the same state throughout;
  - `TOWARDS_MANIA`: progressive worsening toward manic/hypomanic symptoms;
  - `TOWARDS_DEPRESSION`: progressive worsening toward depressive symptoms;
  - `FLUCTUATING`: alternation between states without a clear directional trend.
- *Change points:* Specific dates or events where a mood shift occurred, with pre- and post-shift states documented.
- *Trend summary:* A concise narrative describing the period's emotional trajectory and the evidence supporting the dominant state.
- *DSM-5 specifiers:* `with_mixed_features` when opposite-pole symptoms co-occur simultaneously within the period (as distinguished from sequential fluctuation).

Together, post-level states and period-level trends support event-level analysis (e.g., what preceded a state change) and longitudinal trajectory modeling (e.g., predicting the next period's dominant state from the current sequence). The explicit change-point fields additionally support change-point detection analyses @truong2020selective at the textual level.

=== Few-Shot Example Construction <fewshotsec>

The post-level prompt is paired with eight synthetic few-shot examples (labeled A--H), written by the authors and never drawn from BD-Risk. Each example exercises a specific rule that the schema introduces in response to a failure mode observed during prompt development (full failure-mode analysis in @errorsec): Example~A demonstrates _Behavior Over Tone_ on retrospectively narrated manic-side behaviors with remorse; B and~E demonstrate the _SAFETY OVERRIDE_ rule and its narrow grandiose / psychotic-mania exception; C and~D contrast the _Improvement-Narrative_ rule against the _Whole-Post dominance_ rule on superficially similar recovery cues; F counters the default-to-Uncertain tendency on short impulsive posts; G demonstrates the _Recurrent-Pattern Exception_ for substance-triggered hypomania; H exercises the _Severity Descriptors_ that distinguish Hypomanic activation from Stable productivity. Each example provides the input post text together with the full expected JSON output (including the structured `opposite_pole_symptoms` evidence list and a reasoning string), so the model learns both the target label and the evidence chain that justifies it. The full example texts are reproduced in the Appendix.

== LLM Configuration

We use Gemini 3.1 Pro, accessed through the official API with structured JSON output. We selected this model for its large context window and native structured output generation, both required for the annotation pipeline. Each post is processed independently using a prompt containing the full annotation schema (DSM-5-grounded rules, output format) and eight synthetic few-shot examples targeting the failure modes characterized during prompt development (see @errorsec). The prompt is supplied as a system instruction; the model returns a JSON object with `state`, `opposite_pole_symptoms`, `specifiers`, `confidence` (High/Medium/Low), and `reasoning` fields. The `opposite_pole_symptoms` field carries the explicit evidence list required before the `with_mixed_features` specifier can be assigned (see @frameworksec). For period-level annotation, the LLM additionally returns `trend_direction`, `change_points`, and a `trend_summary` narrative, with a `confidence` value on a 0--1 scale rather than the post-level High/Medium/Low. Temperature is set to the default value. The few-shot examples are synthetic constructions written by the authors, not drawn from BD-Risk, and the model is not fine-tuned.

== External Validation Against BD-Risk <validsec>

To establish the quality of the post-level state classification, we validate it against the BD-Risk dataset @lee2024detecting.

=== The BD-Risk Dataset

The BD-Risk dataset @lee2024detecting comprises 7,346 Reddit posts from 1,025 users, each carrying a psychiatrist-guided mood level label on a 7-point scale ($-$3 to $+$3). Because the dataset recruits users via an initial MDD presentation (MDD-only and MDD$arrow$BD groups), it is structurally enriched for depressive-pole content (88.9% of posts $lt.eq 0$).

=== Gold State Derivation

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
  caption: [Mapping from BD-Risk 7-point mood labels to derived gold states. This mapping treats $+$1 as within the normal positive range (Stable) rather than pathological activation.],
) <tab-mapping>


=== Evaluation Set Construction

The full BD-Risk dataset exhibits a heavily skewed mood distribution (88.9% of posts $lt.eq$ 0). Because the deployment task is BD risk detection rather than general mood classification, we deliberately oversample manic-pole posts so that per-class metrics on the underrepresented classes are computed with sufficient support.

We separate the labeled posts into two disjoint subsets. A _development_ subset (314 posts) is used during prompt design and failure-mode analysis. A _held-out_ subset (145 posts) is used exclusively for the evaluation reported below; it is *author-disjoint* from the development subset, drawn by stratified sampling from BD-Risk authors not present in the development subset, with quotas ensuring sufficient per-class support across the four derived gold states ($60$ Depressive, $40$ Stable, $30$ Hypomanic, $15$ Manic). All metrics in @bdresultsec are computed on the held-out subset; the development subset is never used to produce reported numbers. Manic-pole gold posts in BD-Risk come almost exclusively from the MDD$arrow$BD group, so the held-out manic-side samples are structurally MDD$arrow$BD-derived (a limitation discussed in @discussionsec).

== Evaluation Metrics <metricssec>

Throughout this paper, we refer to the expert-assigned labels from the BD-Risk dataset as gold labels and the LLM outputs as predictions. Gold states are derived from BD-Risk mood labels via the mapping in @tab-mapping.

We report per-class precision, recall, and F1, along with overall accuracy and macro F1, plus the confusion matrix. Two accuracy variants are reported: accuracy _excluding_ Uncertain treats Uncertain outputs as abstentions and removes them from both numerator and denominator (typical evaluator convention); accuracy _including_ Uncertain counts Uncertain as incorrect, providing a conservative lower bound. Per-class precision, recall, and F1 follow the excluding-Uncertain convention. All metrics are computed on the full evaluation set.

== Evaluation Design <evaldesignsec>

Beyond the main BD-Risk holdout validation, we conduct two additional evaluations to characterize the schema's properties:

- *Zero-shot baseline comparison:* To quantify how much the structured annotation schema (DSM-5 rules, few-shot examples) contributes beyond the LLM's base capability, we re-evaluate the same model with a minimal zero-shot prompt containing only the task definition and output format.
- *Cross-model feasibility probe:* To test whether the schema generalizes beyond a single LLM provider, we additionally evaluate the full schema with OpenAI's GPT-5.5, characterizing schema portability and the impact of provider-level content-policy differences on annotation feasibility.


= Results <resultsec>

== Post-Level Validation Against BD-Risk <bdresultsec>

We first validate the post-level state classification against BD-Risk expert labels (@tab-state-metrics: per-class metrics with macro-aggregated summary).

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
  caption: [Per-class state classification metrics with macro-aggregated summary on the held-out subset (n=145; 138 after excluding 7 Uncertain outputs). Accuracy excluding Uncertain = 65.9 %; including Uncertain = 62.8 %. Macro F1 (rather than overall accuracy) is the primary metric because the held-out subset is intentionally stratified. Manic precision is 1.0 because the single Manic prediction the LLM emitted was correct; recall (0.067) reflects that 14 of 15 gold-Manic posts were classified into another category.],
) <tab-state-metrics>

Depressive recall is high (87.9%) and Stable recall is moderate (78.4%), while Hypomanic and Manic recall remain low (35.7% and 6.7%), indicating that the LLM correctly recognizes most depressive-pole and stable-pole posts while missing a majority of manic-pole cases. The confusion matrix (@tab-state-cm) makes the dominant error flow explicit: among the 30 gold-Hypomanic posts, 12 are predicted as Depressive and 6 as Stable; among the 15 gold-Manic posts, 11 are predicted as Depressive and 2 as Stable. The Manic-to-Depressive error flow is a recurring pattern with a likely label-text origin that we discuss in @discussionsec.

#figure(
  table(
    columns: 7,
    align: (left, right, right, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [], table.cell(colspan: 6)[#align(center)[*Predicted*]],
      [*Gold*], [*DEP*], [*STA*], [*HYP*], [*MAN*], [*UNC*], [*Total*],
    ),
    table.hline(stroke: 0.5pt),
    [*Depressive*],  [*51*],  [7],    [0],   [0],   [2],  [60],
    [*Stable*],      [7],    [*29*], [1],   [0],   [3],  [40],
    [*Hypomanic*],   [12],   [6],    [*10*], [0],   [2],  [30],
    [*Manic*],       [11],   [2],    [1],   [*1*], [0],  [15],
    table.hline(),
  ),
  caption: [State confusion matrix on the held-out subset (rows: derived gold state; columns: LLM prediction). DEP = Depressive, STA = Stable, HYP = Hypomanic, MAN = Manic, UNC = Uncertain.],
) <tab-state-cm>

These Hypomanic errors are concentrated on gold $+$2 posts whose manic-side activation is masked by negative tone, a pattern the prompt still struggles with.

== The Uncertain Label as Quality Control

The LLM output Uncertain for 7 posts (4.8%), abstaining when post content was insufficient for state assessment. The non-zero rate reflects the prompt's explicit instruction to abstain on truly uninterpretable content rather than force a best-effort guess.

The Uncertain label serves as a quality filter preventing forced labeling when evidence is insufficient. The Uncertain emissions in the held-out evaluation are distributed across gold classes (2 Depressive, 3 Stable, 2 Hypomanic, 0 Manic), with no strong concentration on a single pole.

== Schema Contribution: Comparison with a Zero-Shot Baseline

To quantify how much the structured annotation schema contributes beyond the LLM's base capability, we re-evaluate the same Gemini 3.1 Pro model on the held-out subset with a minimal zero-shot prompt: task definition only (post $arrow.r$ one of five states), no DSM-5 rules, no SAFETY OVERRIDE, no Severity Descriptors, and no few-shot examples. The output JSON fields are unchanged so the comparison is directly comparable. @tab-zeroshot reports the side-by-side metrics.

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
  caption: [Schema contribution on the held-out subset (n=145). Both runs use the same model (Gemini 3.1 Pro) and the same output JSON fields; the only variable is the system prompt. The zero-shot prompt is a minimal task definition with no clinical rules; the full schema includes SAFETY OVERRIDE, Severity Descriptors, Clinical Guidance sections, and eight synthetic few-shot examples.],
) <tab-zeroshot>

Three observations frame the schema's value. First, the largest single effect is a **4$times$ reduction in Uncertain emissions** (27 $arrow.r$ 7): the structured schema gives the LLM the vocabulary to commit to a label rather than abstain, which explains why the accuracy gain *including* Uncertain (+11.1 pp) is much larger than the gain *excluding* Uncertain (+2.3 pp). Second, **STABLE classification benefits the most** in per-class F1 (+0.116), driven by the Severity Descriptors' explicit "STABLE includes mild positive activation" rule that prevents the LLM from defaulting non-pathological positive posts to DEPRESSIVE or UNCERTAIN. Third, **DEPRESSIVE and HYPOMANIC F1 are essentially unchanged**, suggesting the LLM already handles those categories competently from base capability alone, and **MANIC remains poorly recalled in both runs** (0/15 zero-shot vs. 1/15 schema, counting Uncertain as incorrect), confirming that the manic-pole limitation is structural (label-text consistency, @discussionsec) rather than something a richer prompt can repair.

The comparison establishes that the schema's primary contribution is *coverage and decisiveness* (preventing abstention, anchoring border-class decisions) rather than raw classification accuracy on the cases the LLM is already confident about.

== Cross-Model Annotation Feasibility

To probe whether the schema generalizes beyond Gemini, we additionally evaluated the full schema with OpenAI's GPT-5.5 (`reasoning_effort = "high"`) on the same 145 held-out posts. The schema and JSON output format were identical to the main run; only the underlying model changed.

**Refusal under content policy.** GPT-5.5 declined to classify 103 of 145 held-out posts (71.0%) with a content-policy refusal --- the verbatim response was `"I'm sorry, but I cannot assist with that request."` --- and produced no structured output for those posts. The refusals concentrated on posts containing explicit self-harm or suicidal content, exactly the safety-relevant subset that BD-Risk includes by clinical design and that the SAFETY OVERRIDE rule is built to handle. The prompt's clinical-research framing (the schema opens with "You are an expert AI assistant specializing in linguistic analysis for psychiatric research") did not overcome the refusal. Gemini 3.1 Pro produced a structured output for all 145 posts under the same prompt.

**Performance on the non-refused subset.** On the 42 posts GPT-5.5 did classify, both models score higher than on the full 145, because the subset is skewed away from depressive-crisis content (gold distribution within the subset: 16 Depressive, 10 Stable, 12 Hypomanic, 4 Manic). @tab-crossmodel reports the head-to-head metrics on this subset.

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*Metric (on 42 non-refused posts)*], [*Gemini*], [*GPT-5.5*],
    ),
    table.hline(stroke: 0.5pt),
    [Accuracy (excl. Uncertain)],     [72.5%],  [*73.2%*],
    [Macro F1],                       [0.649],  [*0.710*],
    [Macro Precision],                [0.827],  [*0.838*],
    [Macro Recall],                   [0.656],  [*0.679*],
    [DEPRESSIVE F1],                  [*0.800*], [0.769],
    [STABLE F1],                      [0.727],  [*0.737*],
    [HYPOMANIC F1],                   [0.667],  [0.667],
    [MANIC F1],                       [0.400],  [*0.667*],
    [Uncertain emissions],            [2],      [*1*],
    table.hline(),
  ),
  caption: [Cross-model comparison on the 42 posts GPT-5.5 accepted (out of 145 held-out). GPT-5.5 reaches a higher macro F1, driven mostly by Manic F1 (2 of 4 correct vs. 1 of 4 for Gemini). The result is *not* a clean head-to-head: the 42-post subset is the post set that survived GPT-5.5's content-policy filter, which selectively excluded depressive-crisis posts. The remaining 103 posts (71% of the held-out set) are unlabeled by GPT-5.5 and excluded from this table.],
) <tab-crossmodel>

**Interpretation.** Three things follow. First, when GPT-5.5 does respond, the schema produces sensible structured output, confirming that it is not Gemini-specific in spirit. Second, the head-to-head numbers favor GPT-5.5 on the non-refused subset; however, the subset selection itself is the dominant effect: GPT-5.5 systematically filtered out the hard depressive-crisis posts that drive most of Gemini's error rate on the full held-out, so a direct macro-F1 comparison overstates GPT-5.5's effective competence on a clinical mental-health corpus. Third, and most important in practice, **production safety filters can render an LLM unsuitable as an annotator for psychiatric corpora**: a 71% refusal rate on the held-out subset makes GPT-5.5 infeasible as a stand-alone annotator for our corpus under its current safety policy, regardless of intrinsic capability. The choice of LLM provider has annotation-feasibility consequences beyond accuracy.

== Error Analysis <errorsec>

This section characterizes six failure modes identified through manual analysis of disagreements between the LLM's predictions and the BD-Risk gold labels. Each pattern is named by its surface cause and tied to the schema rule that constrains it; manic-pole posts misclassified as depressive or stable remain the dominant residual failure mode under the schema, with the held-out per-class numbers in @bdresultsec quantifying how often it occurs.

*Pattern 1: Retrospective behavioral cues ignored (dominant manic-side error).* When users describe manic-episode behaviors --- impulsive spending, aggressive confrontations, hyperactivity --- in a retrospective post written with remorse or self-blame, the LLM anchors on the _current emotional tone_ rather than the _clinical significance of the described behaviors_, and predicts Depressive. The schema's *Behavior Over Tone* rule directly targets this conflation. _Synthetic case:_ a user recounts a week of reckless spending and impulsive decisions in a tone of deep regret and self-condemnation; gold is Hypomanic (the behaviors are hallmark manic symptoms), the LLM predicts Depressive (anchored on the self-deprecating tone).

*Pattern 2: Mixed features conflated with neutrality.* When a post carries symptoms from both poles simultaneously (e.g., severe sleep disruption and inability to concentrate alongside aggressive outbursts), the LLM sometimes treats the coexistence as cancellation and defaults to Stable. Under DSM-5 @apa2013dsm5, mixed features should instead surface as a `with_mixed_features` specifier on the dominant pole. _Synthetic case:_ a user writes that they have not slept in three days, cannot focus at work, and snapped at their partner, all in the same post; gold is Hypomanic with mixed features (decreased need for sleep alongside dysphoric irritability), the LLM predicts Stable on the reasoning that the signals "balance out".

*Pattern 3: Calm writing style masking suicidal ideation (safety-critical).* Some posts express suicidal ideation ("I want to die") in calm, reflective, or educational prose; the LLM reads the linguistic register as stable and classifies accordingly, while the gold state is Depressive ($-$3). Calm writing does not rule out suicidal crisis, and the schema's explicit *SAFETY OVERRIDE* rule forces Depressive whenever crisis-level language is present regardless of surrounding tone. _Synthetic case:_ a user posts a coherent essay about public misconceptions of depression; embedded in the second paragraph, in the same calm register, is a single sentence noting that the writer quietly thinks about not waking up most mornings.

*Pattern 4: End-of-post hope overriding pervasive impairment.* Posts describing severe functional impairment (academic collapse, inability to maintain daily routines, social withdrawal) sometimes close with a single hopeful sentence (e.g., "my therapist said maybe I shouldn't give up"), and the LLM anchors on this terminal positive signal --- a recency bias --- to predict Stable while the gold label tracks the pervasive impairment throughout. The schema's *Whole-Post Evidence Weighting* rule addresses this. _Synthetic case:_ a user reports missing every class for a month, eating almost nothing this week, and losing the ability to reply to friends, closing with "maybe tomorrow will be different"; gold is Depressive on the pervasive impairment, the LLM predicts Stable.

*Pattern 5: Substance-induced activation vs.~endogenous mood.* When users describe mood elevation explicitly attributed to substances (e.g., caffeine-induced euphoria described as feeling "on top of the world"), the LLM may interpret these cues as hypomanic mood, while gold labels distinguish acute pharmacological activation from endogenous baseline. The schema's substance--mood disambiguation rule addresses this boundary and also covers the recurrent-pattern exception where an unusual reactivity to a common substance is itself bipolar-spectrum. _Synthetic case:_ a user writes that after a fourth coffee they suddenly feel "unbeatable and ready to overhaul" their apartment, attributing the surge to caffeine and expecting an evening crash; gold is Stable (acute, externally caused, self-labeled), the LLM predicts Hypomanic on the surface cues.

*Pattern 6: Uncertain masking embedded clinical signals.* In rare cases the LLM correctly identifies a post as metacommentary or informational, then fails to surface clinically significant content embedded inside. A post critiquing the "aestheticization of depression" may carry explicit suicidal statements that the Uncertain label hides; the *SAFETY OVERRIDE* rule mitigates this pattern by forcing Depressive on crisis-level language regardless of overall framing. _Synthetic case:_ a user writes a meta-commentary criticizing how recovery is portrayed online and, mid-argument, notes parenthetically that they have been thinking about ending things themselves; gold is Depressive, the LLM defaults to Uncertain on the meta-discussion register.


= Longitudinal Demonstration: Period-Level Mood Trends <pilotsec>

With post-level reliability confirmed, we turn to the period-level trend annotations. @fig-user-timeline shows the two-granularity annotation for four representative users selected to cover diverse BD presentations: each row is a user, colored bars represent 14-day periods (color = dominant state, hatch pattern = trend direction), and dots represent individual post-level state annotations.

#figure(
  image("fig_timeline.svg", width: 100%),
  caption: [Mood trajectory visualization for four anonymized BD users with diverse clinical presentations. Colored bars represent 14-day periods (bar color = dominant state; hatch pattern = trend direction; the `with_mixed_features` specifier is drawn with a thin black border). Dots above each bar represent individual post-level state annotations, color-coded by post state. Users were selected to illustrate contrasting BD patterns: predominantly depressive with fluctuation (User A, 49 periods), hypomanic-leaning with frequent manic transitions (User B, 75 periods), manic-dominant with rapid cycling (User C, 37 periods), and dense posting with high mixed-features incidence (User D, 25 periods).],
) <fig-user-timeline>

@tab-trend-dist presents the distribution of trend directions across the annotated periods.

#figure(
  table(
    columns: 4,
    align: (left, right, right, left),
    stroke: none,
    table.hline(),
    table.header(
      [*Trend direction*], [*Periods*], [*%*], [*Interpretation*],
    ),
    table.hline(stroke: 0.5pt),
    [NO\_TREND],             [1,506], [83.9%], [Mood state maintained throughout period],
    [FLUCTUATING],          [106],   [5.9%],  [Alternation between states, no clear direction],
    [TOWARDS\_DEPRESSION],  [105],   [5.9%],  [Progressive worsening toward depressive pole],
    [TOWARDS\_MANIA],       [77],    [4.3%],  [Progressive worsening toward manic pole],
    table.hline(),
  ),
  caption: [Distribution of 14-day period trend directions ($n = 1794$ periods from 105 users). The predominance of NO\_TREND is clinically expected: most 14-day windows capture a single ongoing episode or stable phase rather than a state transition.],
) <tab-trend-dist>

#figure(
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
  caption: [Distribution of dominant states across 14-day periods ($n = 1794$). The `with_mixed_features` specifier was applied to 84 periods (4.7%).],
) <tab-state-dist>

Most 14-day windows show NO\_TREND, which is expected: a typical BD mood episode lasts weeks to months (depressive) or 1--4 weeks (manic) per DSM-5 @apa2013dsm5, so state transitions within a single 14-day window are infrequent. The TOWARDS\_DEPRESSION and TOWARDS\_MANIA trends, though rare, mark episode onset or escalation, which are the signals most relevant for early intervention.

Stable and Depressive states dominate the dataset; manic-pole states (Hypomanic and Manic combined) account for the remainder. This matches the known BD asymmetry: depressive episodes are more frequent and longer, and users may post more during depressive and stable periods @jagfeld2021understanding.

*Post-level state distribution.* @tab-post-state-dist reports the dominant mood states assigned by the post-level classifier, split by content type. The two distributions differ sharply. Submissions, which authors typically use as a longer-form channel to disclose distress or recovery, carry the majority of polar-state labels (51.2% combined Manic, Hypomanic, and Depressive); under half are Stable. Comments, which serve as in-thread replies, are dominated by Stable (88.1%) and exhibit only 8.9% polar content. The Uncertain rate is low for both ($lt.eq$3.0%), reflecting the model's confidence on the released corpus.

#figure(
  table(
    columns: 5,
    align: (left, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*State*], [*Posts*], [*%*], [*Comments*], [*%*],
    ),
    table.hline(stroke: 0.5pt),
    [Manic],      [98],    [3.8%],  [93],     [0.7%],
    [Hypomanic],  [277],   [10.6%], [292],    [2.3%],
    [Stable],     [1,217], [46.6%], [11,287], [88.1%],
    [Depressive], [961],   [36.8%], [755],    [5.9%],
    [Uncertain],  [58],    [2.2%],  [385],    [3.0%],
    table.hline(),
  ),
  caption: [Post-level state distribution across the 105-user cohort, separated by content type. Posts (submissions, $n = 2{,}611$) function as longer-form emotional disclosures and carry the majority of polar-state labels; comments ($n = 12{,}812$) are predominantly conversational replies labeled Stable.],
) <tab-post-state-dist>


= Discussion <discussionsec>

== Period-Level Trends

Prior BD datasets provide per-user labels @cohan2018smhd @sekulic2018not or per-post scores @lee2024detecting, yet not mood _trajectories_. Our period-level annotations add this dimension: each 14-day window records not only the dominant state but also whether the user's mood is shifting (trend direction) and when shifts occur (change points).

From the trend distribution (@pilotsec), four observations stand out. (1) TOWARDS\_MANIA and TOWARDS\_DEPRESSION trends are rare yet clinically the most important signals, as they mark episode onset where intervention has the most impact. (2) FLUCTUATING periods may correspond to rapid cycling or mixed presentations that single-post labels cannot capture. (3) Post-level states and period-level trends together enable hierarchical modeling: predicting the next period's trajectory from the sequence of post-level features. (4) The dominant-state distribution (@tab-state-dist) preserves meaningful manic-pole representation, in contrast to MDD-recruited cohorts such as BD-Risk, where 88.9% of posts fall in the depressive-or-neutral range. This balance is important for downstream modeling work that must learn to distinguish manic-pole from depressive states rather than predicting the depressive majority class.

The trend distributions are consistent with clinical expectations (see @pilotsec); period-level expert annotations would be required for direct external validation.

A complementary direction is to model the signal currently missing from our schema: periods with `NO_DATA` (see @fig-period-slicing) are excluded from mood-state annotation because no text is available. Reduced social media activity is sometimes associated with depression in digital-phenotyping research @faurholt2018smartphone; however, the relationship is heterogeneous --- some users post more during depressive episodes (rumination, support-seeking), others post less, and many non-posting periods reflect factors unrelated to mood (changing platform interest, offline life events, account suspension). Treating absence as a mood signal would therefore require posting-frequency features benchmarked against per-user baseline activity, and is beyond the scope of a text-based annotation pipeline.

== Asymmetric Post-Level Distribution between Submissions and Comments

@tab-post-state-dist shows that submissions and comments carry very different mood-state distributions. 51.2% of submissions are labeled with a polar state (Manic, Hypomanic, or Depressive), while only 9.1% of comments are; comments are dominated by Stable (88.0%). This reflects the platform's affordances: submissions are longer-form posts authors use to disclose distress, recovery, or treatment changes, whereas comments are short replies to other users' threads (e.g., advice, factual answers, expressions of support). The disparity has two downstream implications. First, a per-post classifier evaluated on a comment-heavy corpus will appear over-confident on Stable simply because most comments are conversational; reporting per-content-type metrics is therefore preferable to a single aggregate. Second, trajectory models that aggregate the post-level state stream into period-level features should weight submissions more heavily than comments, or rely on the period-level dominant-state annotation (which already aggregates evidence across content types within the 14-day window) as the primary trajectory signal.

== Manic-Pole Underdetection

The LLM achieves 87.9% recall for Depressive states yet only 35.7% for Hypomanic and 6.7% for Manic on the held-out subset. Two factors compound to produce this pattern. The first is a model property: depressive language has stereotypical surface markers (negativity, self-focus, hopelessness), while manic-pole states often manifest through _described behaviors_ (spending sprees, reduced sleep need, grandiose plans) narrated in any tone (regret, confusion, or humor). The LLM reads tone rather than recognizing the clinical significance of the described behaviors (see Pattern~1 in @errorsec).

The second factor is a label-text consistency issue rooted in the BD-Risk annotation rule. As specified by @lee2024detecting (Section~3.2), "posts exhibiting both manic and depressive moods are regarded as manic moods," an asymmetric tie-breaking rule that elevates any post with mixed manic+depressive content to the manic side of the scale. In combination with the dataset's selection of MDD$arrow$BD users, this rule yields a non-trivial number of gold-label Manic ($+$3) posts whose textual content matches BD-Risk's own definition of $-$3 ("extreme anxiety and having suicidal thoughts"). A single-post LLM applying clinical-safety priors --- classifying explicit self-harm content as Depressive --- will systematically underperform on these specific posts, since the only signal the model has is the very content that the labeling rule overrode. The Manic-recall ceiling of 6.7% in @tab-state-metrics reflects this structural mismatch, not solely a model limitation. We discuss the implications for downstream use in Limitations.

= Limitations

The proposed method and corpus are subject to several constraints, which we group into evaluation, annotation, and resource-construction limitations.

*Limited cross-model coverage.* The main BD-Risk validation reports a single annotator (Gemini 3.1 Pro). A complementary cross-model probe with GPT-5.5 (see @tab-crossmodel) shows that the schema is not Gemini-specific in spirit; however, GPT-5.5 cannot be used at scale under OpenAI's current content policy (71% refusal rate on the held-out subset). The reported per-class behavior on the full 145-post held-out subset should therefore be read as Gemini-specific.

*Post-level rather than longitudinal evaluation.* Our quantitative validation is at the post level, whereas clinical mood assessment typically considers longitudinal patterns. The post-level setting was chosen because BD-Risk is the only existing dataset with per-post expert mood labels at sufficient scale; period-level trends, which are a key contribution of the method, are not externally validated because no external longitudinal ground truth exists at the period level.

*Gold-state derivation, not direct expert annotation.* Most importantly for interpreting the evaluation results, gold states are derived from BD-Risk mood labels via a deterministic mapping (@tab-mapping) rather than being directly annotated by experts as categorical states. This mapping introduces several sources of imprecision: (a) the boundary between adjacent categories is inherently uncertain (a post with BD-Risk mood label $+$1 may reflect genuine mild hypomania rather than stable mood, yet the mapping deterministically assigns it to Stable); (b) the BD-Risk mood label itself is an ordinal intensity score, not a categorical clinical judgment, and the two dimensions do not always correspond one-to-one (for example, a recovery-narrative post within an ongoing depressive episode might receive a neutral or mildly positive mood score from an expert while remaining clinically depressive); (c) inter-expert agreement on the BD-Risk 7-point scale (Krippendorff's $alpha$ = 0.87) is measured at the ordinal level; mapping this to categorical states amplifies disagreement at category boundaries. Consequently, some apparent misclassifications in our evaluation may reflect mapping artifacts rather than genuine LLM failures, and the reported accuracy figures should be interpreted as lower bounds on the schema's true reliability.

*Underrepresented manic pole.* The held-out subset (145 posts) was constructed to give each derived gold state enough support for per-class metrics; however, Manic ($n=15$) remains small in absolute terms because the entire BD-Risk dataset contains only 28 mood-$+$3 posts. With $n=15$, the 95% confidence interval around the Manic-F1 estimate is wide ($plus.minus$ approximately 13 percentage points), and small Manic-F1 differences should not be interpreted as significant. Increasing Manic statistical power would require re-annotation of additional sources, which is outside the scope of this work.

*Label-text consistency on the Manic pole.* The Manic-recall ceiling of 6.7% is bounded by a structural mismatch between BD-Risk's asymmetric tie-breaking rule and the textual evidence available to a per-post classifier (full analysis in @discussionsec). Recovering label-text consistency for Manic detection would require either re-annotation under text-only criteria or a longitudinal evaluation protocol supplying the temporal context the annotators had access to.

*Self-identified diagnosis.* Patient verification is LLM-based and screens for self-disclosure of a BD diagnosis in the user's posting history; it does not constitute clinical confirmation. This follows the inclusion model used in prior BD social-media datasets @sekulic2018not @jagfeld2021understanding, with stricter per-user evidence gating than a one-post membership rule. Some users in the `verified` or `probable` tiers may describe a BD diagnosis without one having been clinically established, and conversely the cohort excludes users with BD who never disclose the diagnosis in their public posting history. Downstream uses that require clinician-confirmed BD status should treat the cohort as an LLM-screened self-identified sample rather than a clinical cohort.

*No human-in-the-loop verification of the dataset's annotations.* All period-level annotations (1,794) and post-level annotations (15,423) are produced entirely by the LLM. We have not yet conducted manual spot-checking on a stratified sample across mood states, confidence levels, and trend directions.

*Ecological validity.* Reddit is a self-selected, asynchronous communication channel; the relationship between its posts and clinical mood states observed in interview settings requires further investigation.

*Practical reliability.* Depressive-state labels in the resource are reliable (87.9% recall, 73.4% F1 on the held-out subset); Hypomanic labels have moderate reliability (35.7% recall, 50.0% F1) with high precision (83.3%) when the label is assigned; Manic labels should be used with caution given both the small support and the label-text consistency issue described above.

= Conclusion

The validation results separate the proposed method's two failure sources: a depressive-side recall of 87.9% shows the schema can reliably anchor on the dominant depressive-pole markers, while the 6.7% manic recall is dominated by a structural label-text consistency issue at the manic pole rather than by a fixable prompting choice (see @discussionsec). Because no external longitudinal ground truth exists at the period level, the corpus' 1,794 period-level trajectories are validated only indirectly through their post-level constituents. Three near-term priorities follow: (1) expert annotation of period-level trends to enable direct longitudinal validation; (2) a stratified human-in-the-loop audit of the LLM outputs across mood states, confidence levels, and trend directions, reported as inter-annotator agreement; and (3) extending the cross-model probe (Anthropic Claude, open-weight reasoning models) to characterize manic-pole behavior beyond the single-vendor evaluation, currently constrained by the production-safety refusal pattern documented for GPT-5.5. The released schema, annotations, and de-identification protocol are intended as a methodological starting point for longitudinal mood-state research on social media, not as a clinical diagnostic tool.

= Ethical Considerations

This study involves analysis of publicly posted social media content discussing sensitive mental health experiences. The study protocol was reviewed and approved by the Research Ethics Committee of the University of Tsukuba (approval no.~25-188). We additionally adhere to Reddit's privacy policy and social media research ethics guidelines @harrigian2021state.

*De-identification.* Before public release, all post content in the resource undergoes LLM-based de-identification. We classify personally identifiable information into five categories by identification risk: _identifiers_ (names that directly identify an individual), _quasi-identifiers_ (information that in combination could identify an individual, such as specific locations, organizations, dates, or unique personal circumstances), _contact information_, _linkage codes_, and _personal identification codes_. The LLM detects and replaces each PII span with a category-specific placeholder (e.g., `[IDENTIFIER]`, `[QUASI_ID]`). LLM-based de-identification can also detect long-span quasi-identifiers --- passages where the accumulation of individually innocuous details (occupation, location, family structure) could jointly narrow identification to a single individual --- that rule-based or traditional NER approaches may miss. All de-identified outputs undergo manual spot-checking to verify both detection coverage and preservation of clinically relevant content (medication names, diagnosis types, symptom descriptions, and relative temporal expressions are retained).

*Data minimization.* The resource retains only the text content and timestamps necessary for mood state annotation. Author usernames are replaced with anonymized identifiers; subreddit membership and post metadata that could facilitate re-identification are excluded from the published dataset.

*Intended use.* The resource is intended solely for computational mental health research. It must not be used for re-identification of individuals, commercial profiling, or clinical decision-making without appropriate expert oversight.

#pagebreak()

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

= Appendix: Annotation Prompts <appendix>

The annotation pipeline uses three system prompts: (A) a post-level annotation prompt containing the full DSM-5-grounded schema, clinical guidance rules (Safety Override, Behavior Over Tone, Whole-Post Evidence Weighting, Improvement-Narrative, Substance vs.~Endogenous Mood), mixed-features specifier rules, and eight synthetic few-shot examples; (B) a minimal zero-shot baseline prompt containing only the task definition and output format; and (C) a period-level trend analysis prompt for 14-day mood trajectory annotation. All prompts are supplied as system instructions; the user message contains only the post text(s) to be classified. Full prompt texts are available at _TBD_ (anonymous deposit).
