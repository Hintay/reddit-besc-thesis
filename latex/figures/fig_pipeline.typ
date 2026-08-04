// Standalone export of the annotation-pipeline diagram (Fig. 1, camera-ready).
// Watanabe-approved redesign: merged annotation stage, explicit input node.
// Compile:  typst compile fig_pipeline.typ fig_pipeline.svg  (and .pdf)
#set page(width: auto, height: auto, margin: 0pt, fill: white)
#set text(font: "New Computer Modern", size: 10pt)

#{
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
    let make_box(pos, icon_paths, color, title, body_lines, width: 22mm, name: none, dashed: false) = node(
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
      stroke: if dashed { (paint: rgb(color), thickness: 0.8pt, dash: "dashed") } else { (paint: rgb(color), thickness: 0.8pt) },
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
          align(center, text(weight: "bold", size: 9pt, fill: rgb(c_annot))[DSM-5-guided annotation]),
          align(center, text(size: 7pt, fill: luma(70))[(Gemini 3.1 Pro)]),
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
      width: 44mm,
      fill: white,
      stroke: (paint: rgb(c_annot), thickness: 0.9pt),
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
        spacing: (9mm, 2mm),
        edge-stroke: 0.6pt + black,
        mark-scale: 60%,

        // Incoming data source — same make_box style as other pipeline stages.
        make_box((-1, 0), icon_globe, c_data, [User posting\ history],
          ([BD subreddits], [full history]), width: 16mm, name: <input>),
        edge(<input>, <verify>, "-|>"),

        // Row 0: main pipeline.
        make_box((0, 0), icon_shield, c_verify, [Patient verification],
          ([LLM evidence], [3-tier classifier]), width: 16mm, name: <verify>),
        edge(<verify>, <prompts>, "-|>", elabel[verified\ cohort], label-side: left),

        llm_prompts,
        // Brace-style fork from annotation to the two outputs.
        edge(<prompts>, (rel: (0.3, 0), to: <prompts>), "-"),
        edge((rel: (0.3, -0.55), to: <prompts>), (rel: (0.3, 0.55), to: <prompts>), "-"),
        edge((rel: (0.3, -0.55), to: <prompts>), <post-out>, "-|>", mark-scale: 120%),
        edge((rel: (0.3,  0.55), to: <prompts>), <trend-out>, "-|>", mark-scale: 120%),

        json_box((2, -0.55), c_post, [Post-level output],
          ("state", "specifiers", "confidence", "reasoning"), width: 29mm, name: <post-out>),

        json_box((2, 0.55), c_trend, [Period-level output],
          ("dominant_state", "trend_direction", "change_points", "trend_summary", "confidence"), width: 29mm, name: <trend-out>),
      )
    ))
  }
