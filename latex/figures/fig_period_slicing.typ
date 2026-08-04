// Standalone export of the period-segmentation illustration (Fig. 2 of the paper).
// Compile:  typst compile fig_period_slicing.typ fig_period_slicing.svg
//           typst compile fig_period_slicing.typ fig_period_slicing.pdf
// Page width = LNCS text width (12.2 cm); font matches the LaTeX CM look.
#set page(width: 12.2cm, height: auto, margin: 0pt, fill: white)
#set text(font: "New Computer Modern", size: 10pt)

#{
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
}
