///|
/// Renders a declarative Cartesian chart with SVG, Markdown, alt text, and
/// structural accessibility audit output.
pub fn render_chart(spec : ChartSpec) -> ChartArtifact {
  let plot = ChartRect::new(0, 0, spec.size.width, spec.size.height).inset(
    spec.margins,
  )
  let domain = NumericDomain::from_points(spec.all_points()).include_zero()
  let y_scale = LinearScale::new(domain, plot.bottom(), plot.y)
  let svg = render_chart_svg(spec, plot, y_scale)
  let markdown = render_chart_markdown(spec)
  let alt_text = render_chart_alt_text(spec, domain)
  { svg, markdown, alt_text, audit: audit_svg(svg) }
}

///|
fn render_chart_svg(
  spec : ChartSpec,
  plot : ChartRect,
  y_scale : LinearScale,
) -> String {
  let buf = StringBuilder()
  let title_id = "moonchartkit-chart-title"
  let description_id = "moonchartkit-chart-description"
  buf.write_string(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\{spec.size.width}\" height=\"\{spec.size.height}\" viewBox=\"0 0 \{spec.size.width} \{spec.size.height}\" role=\"img\" aria-labelledby=\"\{title_id} \{description_id}\" style=\"font-family:\{escape_xml(spec.theme.font_family)}\">",
  )
  buf.write_string(
    "<title id=\"\{title_id}\">\{escape_xml(spec.title)}</title>",
  )
  buf.write_string(
    "<desc id=\"\{description_id}\">\{escape_xml(spec.description)}</desc>",
  )
  buf.write_string(svg_background(spec.size, spec.theme))
  write_spec_title(buf, spec)
  write_y_axis(buf, spec, plot, y_scale)
  write_x_axis(buf, spec, plot)
  match spec.kind {
    Bar => write_bar_series(buf, spec, plot, y_scale)
    Line => write_line_series(buf, spec, plot, y_scale, false)
    Area => write_line_series(buf, spec, plot, y_scale, true)
    Scatter => write_scatter_series(buf, spec, plot, y_scale)
  }
  if spec.show_legend {
    write_legend(buf, spec, plot)
  }
  buf.write_string("</svg>")
  buf.to_string()
}

///|
fn write_spec_title(buf : StringBuilder, spec : ChartSpec) -> Unit {
  buf.write_string(
    "<text x=\"\{spec.size.padding}\" y=\"30\" font-size=\"18\" font-weight=\"700\" fill=\"\{spec.theme.foreground}\">\{escape_xml(spec.title)}</text>",
  )
  if spec.description != "" {
    buf.write_string(
      "<text x=\"\{spec.size.padding}\" y=\"48\" font-size=\"12\" fill=\"\{spec.theme.foreground}\" opacity=\"0.72\">\{escape_xml(spec.description)}</text>",
    )
  }
}

///|
fn write_y_axis(
  buf : StringBuilder,
  spec : ChartSpec,
  plot : ChartRect,
  scale : LinearScale,
) -> Unit {
  let ticks = scale.ticks(5)
  for value in ticks.values {
    let y = scale.map(value)
    if spec.show_grid {
      buf.write_string(
        "<line x1=\"\{plot.x}\" y1=\"\{y}\" x2=\"\{plot.right()}\" y2=\"\{y}\" stroke=\"\{spec.theme.grid}\" stroke-dasharray=\"3 4\" opacity=\"0.8\"/>",
      )
    }
    buf.write_string(
      "<text x=\"\{plot.x - 8}\" y=\"\{y + 4}\" text-anchor=\"end\" font-size=\"10\" fill=\"\{spec.theme.foreground}\">\{value}</text>",
    )
  }
  buf.write_string(
    "<line x1=\"\{plot.x}\" y1=\"\{plot.y}\" x2=\"\{plot.x}\" y2=\"\{plot.bottom()}\" stroke=\"\{spec.theme.grid}\"/>",
  )
}

///|
fn write_x_axis(
  buf : StringBuilder,
  spec : ChartSpec,
  plot : ChartRect,
) -> Unit {
  buf.write_string(
    "<line x1=\"\{plot.x}\" y1=\"\{plot.bottom()}\" x2=\"\{plot.right()}\" y2=\"\{plot.bottom()}\" stroke=\"\{spec.theme.grid}\"/>",
  )
  if spec.series.length() == 0 {
    return
  }
  let points = spec.series[0].points
  let bands = BandScale::new(
    plot.x,
    plot.right(),
    points.length(),
    inner_padding=8,
  )
  for i = 0; i < points.length(); i = i + 1 {
    let max_chars = if bands.slot_width() < 44 { 5 } else { 12 }
    buf.write_string(
      "<text x=\"\{bands.center_for(i)}\" y=\"\{plot.bottom() + 18}\" text-anchor=\"middle\" font-size=\"10\" fill=\"\{spec.theme.foreground}\">\{escape_xml(truncate_label(points[i].label, max_chars))}</text>",
    )
  }
}

///|
fn write_bar_series(
  buf : StringBuilder,
  spec : ChartSpec,
  plot : ChartRect,
  scale : LinearScale,
) -> Unit {
  let categories = spec.category_count()
  if categories == 0 || spec.series.length() == 0 {
    return
  }
  let bands = BandScale::new(plot.x, plot.right(), categories, inner_padding=8)
  let grouped_width = bands.band_width()
  let series_width = if spec.series.length() > 0 {
    max_chart_int(1, grouped_width / spec.series.length())
  } else {
    grouped_width
  }
  let baseline = scale.map(0)
  for series_index = 0
      series_index < spec.series.length()
      series_index = series_index + 1 {
    let series = spec.series[series_index]
    let color = chart_series_color(series, series_index, spec.theme)
    for point_index = 0
        point_index < series.points.length()
        point_index = point_index + 1 {
      let point = series.points[point_index]
      let value_y = scale.map(point.value)
      let y = if value_y < baseline { value_y } else { baseline }
      let height = absolute_chart_int(baseline - value_y)
      let x = bands.x_for(point_index) + series_index * series_width
      buf.write_string(
        "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{max_chart_int(1, series_width - 1)}\" height=\"\{max_chart_int(1, height)}\" rx=\"\{spec.theme.radius}\" fill=\"\{color}\"><title>\{escape_xml(series.name)}: \{escape_xml(point.label)} \{point.value}</title></rect>",
      )
    }
  }
}

///|
fn write_line_series(
  buf : StringBuilder,
  spec : ChartSpec,
  plot : ChartRect,
  scale : LinearScale,
  fill_area : Bool,
) -> Unit {
  let categories = spec.category_count()
  if categories == 0 {
    return
  }
  let bands = BandScale::new(plot.x, plot.right(), categories, inner_padding=0)
  for series_index = 0
      series_index < spec.series.length()
      series_index = series_index + 1 {
    let series = spec.series[series_index]
    if series.points.length() == 0 {
      continue
    }
    let color = chart_series_color(series, series_index, spec.theme)
    let path = StringBuilder()
    for i = 0; i < series.points.length(); i = i + 1 {
      let x = bands.center_for(i)
      let y = scale.map(series.points[i].value)
      if i == 0 {
        path.write_string("M \{x} \{y}")
      } else {
        path.write_string(" L \{x} \{y}")
      }
    }
    if fill_area {
      let last = series.points.length() - 1
      path.write_string(
        " L \{bands.center_for(last)} \{scale.map(0)} L \{bands.center_for(0)} \{scale.map(0)} Z",
      )
      buf.write_string(
        "<path d=\"\{path.to_string()}\" fill=\"\{color}\" opacity=\"0.20\"/>",
      )
    }
    buf.write_string(
      "<path d=\"\{path.to_string()}\" fill=\"none\" stroke=\"\{color}\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>",
    )
    for i = 0; i < series.points.length(); i = i + 1 {
      let point = series.points[i]
      buf.write_string(
        "<circle cx=\"\{bands.center_for(i)}\" cy=\"\{scale.map(point.value)}\" r=\"4\" fill=\"\{color}\"><title>\{escape_xml(series.name)}: \{escape_xml(point.label)} \{point.value}</title></circle>",
      )
    }
  }
}

///|
fn write_scatter_series(
  buf : StringBuilder,
  spec : ChartSpec,
  plot : ChartRect,
  scale : LinearScale,
) -> Unit {
  let categories = spec.category_count()
  if categories == 0 {
    return
  }
  let bands = BandScale::new(plot.x, plot.right(), categories, inner_padding=0)
  for series_index = 0
      series_index < spec.series.length()
      series_index = series_index + 1 {
    let series = spec.series[series_index]
    let color = chart_series_color(series, series_index, spec.theme)
    for i = 0; i < series.points.length(); i = i + 1 {
      let point = series.points[i]
      buf.write_string(
        "<circle cx=\"\{bands.center_for(i)}\" cy=\"\{scale.map(point.value)}\" r=\"6\" fill=\"\{color}\" opacity=\"0.82\"><title>\{escape_xml(series.name)}: \{escape_xml(point.label)} \{point.value}</title></circle>",
      )
    }
  }
}

///|
fn write_legend(
  buf : StringBuilder,
  spec : ChartSpec,
  plot : ChartRect,
) -> Unit {
  let mut x = plot.x
  let y = plot.y - 22
  for i = 0; i < spec.series.length(); i = i + 1 {
    let series = spec.series[i]
    let color = chart_series_color(series, i, spec.theme)
    buf.write_string(
      "<rect x=\"\{x}\" y=\"\{y - 9}\" width=\"10\" height=\"10\" rx=\"2\" fill=\"\{color}\"/>",
    )
    buf.write_string(
      "<text x=\"\{x + 15}\" y=\"\{y}\" font-size=\"11\" fill=\"\{spec.theme.foreground}\">\{escape_xml(series.name)}</text>",
    )
    x = x + 22 + series.name.length() * 7
  }
}

///|
fn render_chart_markdown(spec : ChartSpec) -> String {
  let buf = StringBuilder()
  buf.write_string("## \{escape_markdown(spec.title)}\n\n")
  buf.write_string("\{escape_markdown(spec.description)}\n\n")
  buf.write_string("| Series | Label | Value |\n| --- | --- | ---: |\n")
  for series in spec.series {
    for point in series.points {
      buf.write_string(
        "| \{escape_markdown(series.name)} | \{escape_markdown(point.label)} | \{point.value} |\n",
      )
    }
  }
  buf.to_string()
}

///|
fn render_chart_alt_text(spec : ChartSpec, domain : NumericDomain) -> String {
  "\{spec.title}. \{spec.description}. \{spec.series.length()} series, \{spec.category_count()} categories, values from \{domain.min} to \{domain.max}."
}

///|
fn max_chart_int(left : Int, right : Int) -> Int {
  if left > right {
    left
  } else {
    right
  }
}

///|
fn absolute_chart_int(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}
