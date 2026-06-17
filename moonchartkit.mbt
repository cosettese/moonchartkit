///|
pub(all) struct ChartSize {
  width : Int
  height : Int
  padding : Int
} derive(Eq, Debug)

///|
pub(all) struct DataPoint {
  label : String
  value : Int
} derive(Eq, Debug)

///|
pub(all) struct ChartTheme {
  background : String
  foreground : String
  accent : String
  accent_alt : String
  grid : String
  font_family : String
  radius : Int
} derive(Eq, Debug)

///|
pub(all) struct PlotArea {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Eq, Debug)

///|
pub(all) struct ChartSummary {
  count : Int
  total : Int
  max : Int
  average : Int
} derive(Eq, Debug)

///|
pub fn ChartSize::new(width : Int, height : Int, padding : Int) -> ChartSize {
  {
    width: normalize_positive(width, 640),
    height: normalize_positive(height, 360),
    padding: normalize_positive(padding, 32),
  }
}

///|
pub fn DataPoint::new(label : String, value : Int) -> DataPoint {
  { label, value }
}

///|
pub fn ChartTheme::atelier() -> ChartTheme {
  {
    background: "#fbfaf7",
    foreground: "#243b53",
    accent: "#2f80ed",
    accent_alt: "#f2994a",
    grid: "#d9e2ec",
    font_family: "Inter, Segoe UI, sans-serif",
    radius: 6,
  }
}

///|
pub fn ChartTheme::midnight() -> ChartTheme {
  {
    background: "#111827",
    foreground: "#f9fafb",
    accent: "#38bdf8",
    accent_alt: "#f472b6",
    grid: "#374151",
    font_family: "Inter, Segoe UI, sans-serif",
    radius: 6,
  }
}

///|
pub fn ChartSize::plot_area(self : ChartSize) -> PlotArea {
  {
    x: self.padding,
    y: self.padding,
    width: self.width - self.padding * 2,
    height: self.height - self.padding * 2,
  }
}

///|
pub fn max_value(points : Array[DataPoint]) -> Int {
  if points.length() == 0 {
    return 0
  }
  let mut best = points[0].value
  for i = 1; i < points.length(); i = i + 1 {
    if points[i].value > best {
      best = points[i].value
    }
  }
  best
}

///|
pub fn total_value(points : Array[DataPoint]) -> Int {
  let mut total = 0
  for i = 0; i < points.length(); i = i + 1 {
    total = total + points[i].value
  }
  total
}

///|
pub fn ChartSummary::from_points(points : Array[DataPoint]) -> ChartSummary {
  let total = total_value(points)
  let count = points.length()
  {
    count,
    total,
    max: max_value(points),
    average: if count == 0 {
      0
    } else {
      total / count
    },
  }
}

///|
pub fn ChartSummary::to_json(self : ChartSummary) -> String {
  "{\"count\":\{self.count},\"total\":\{self.total},\"max\":\{self.max},\"average\":\{self.average}}"
}

///|
pub fn percent_of(value : Int, total : Int) -> Int {
  if value <= 0 || total <= 0 {
    0
  } else {
    value * 100 / total
  }
}

///|
fn scale_value(value : Int, max : Int, height : Int) -> Int {
  if max <= 0 || value <= 0 {
    0
  } else {
    value * height / max
  }
}

///|
fn escape_xml(value : String) -> String {
  value
  .replace(old="&", new="&amp;")
  .replace(old="<", new="&lt;")
  .replace(old=">", new="&gt;")
  .replace(old="\"", new="&quot;")
}

///|
pub fn escape_label(value : String) -> String {
  escape_xml(value)
}

///|
pub fn render_bar_chart(
  points : Array[DataPoint],
  title? : String = "",
  size? : ChartSize = ChartSize::new(640, 360, 44),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> String {
  let area = size.plot_area()
  let max = normalize_positive(max_value(points), 1)
  let buf = StringBuilder()
  buf.write_string(svg_header(size, theme))
  buf.write_string(svg_background(size, theme))
  buf.write_string(svg_title(title, size, theme))
  buf.write_string(
    "<line x1=\"\{area.x}\" y1=\"\{area.y + area.height}\" x2=\"\{area.x + area.width}\" y2=\"\{area.y + area.height}\" stroke=\"\{theme.grid}\"/>",
  )
  if points.length() > 0 {
    let gap = 10
    let slot = area.width / points.length()
    let bar_width = normalize_positive(slot - gap, 1)
    for i = 0; i < points.length(); i = i + 1 {
      let bar_height = scale_value(points[i].value, max, area.height)
      let x = area.x + i * slot + gap / 2
      let y = area.y + area.height - bar_height
      let fill = if i % 2 == 0 { theme.accent } else { theme.accent_alt }
      buf.write_string(
        "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{bar_width}\" height=\"\{bar_height}\" rx=\"\{theme.radius}\" fill=\"\{fill}\"/>",
      )
      buf.write_string(
        "<text x=\"\{x + bar_width / 2}\" y=\"\{area.y + area.height + 18}\" text-anchor=\"middle\" font-size=\"11\" fill=\"\{theme.foreground}\">\{escape_xml(points[i].label)}</text>",
      )
    }
  }
  buf.write_string("</svg>")
  buf.to_string()
}

///|
pub fn render_line_chart(
  points : Array[DataPoint],
  title? : String = "",
  size? : ChartSize = ChartSize::new(640, 360, 44),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> String {
  let area = size.plot_area()
  let max = normalize_positive(max_value(points), 1)
  let buf = StringBuilder()
  buf.write_string(svg_header(size, theme))
  buf.write_string(svg_background(size, theme))
  buf.write_string(svg_title(title, size, theme))
  buf.write_string(
    "<line x1=\"\{area.x}\" y1=\"\{area.y + area.height}\" x2=\"\{area.x + area.width}\" y2=\"\{area.y + area.height}\" stroke=\"\{theme.grid}\"/>",
  )
  if points.length() > 0 {
    let step = if points.length() == 1 {
      0
    } else {
      area.width / (points.length() - 1)
    }
    let path = StringBuilder()
    for i = 0; i < points.length(); i = i + 1 {
      let x = area.x + i * step
      let y = area.y +
        area.height -
        scale_value(points[i].value, max, area.height)
      if i == 0 {
        path.write_string("M \{x} \{y}")
      } else {
        path.write_string(" L \{x} \{y}")
      }
      buf.write_string(
        "<circle cx=\"\{x}\" cy=\"\{y}\" r=\"4\" fill=\"\{theme.accent_alt}\"/>",
      )
    }
    buf.write_string(
      "<path d=\"\{path.to_string()}\" fill=\"none\" stroke=\"\{theme.accent}\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>",
    )
  }
  buf.write_string("</svg>")
  buf.to_string()
}

///|
pub fn render_sparkline(
  values : Array[Int],
  size? : ChartSize = ChartSize::new(180, 48, 6),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> String {
  let points : Array[DataPoint] = []
  for i = 0; i < values.length(); i = i + 1 {
    points.push(DataPoint::new("", values[i]))
  }
  let area = size.plot_area()
  let max = normalize_positive(max_value(points), 1)
  let buf = StringBuilder()
  buf.write_string(svg_header(size, theme))
  buf.write_string(svg_background(size, theme))
  if values.length() > 0 {
    let step = if values.length() == 1 {
      0
    } else {
      area.width / (values.length() - 1)
    }
    let path = StringBuilder()
    for i = 0; i < values.length(); i = i + 1 {
      let x = area.x + i * step
      let y = area.y + area.height - scale_value(values[i], max, area.height)
      if i == 0 {
        path.write_string("M \{x} \{y}")
      } else {
        path.write_string(" L \{x} \{y}")
      }
    }
    buf.write_string(
      "<path d=\"\{path.to_string()}\" fill=\"none\" stroke=\"\{theme.accent}\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>",
    )
  }
  buf.write_string("</svg>")
  buf.to_string()
}

///|
pub fn render_metric_card(
  title : String,
  value : String,
  caption? : String = "",
  size? : ChartSize = ChartSize::new(360, 180, 28),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> String {
  let buf = StringBuilder()
  buf.write_string(svg_header(size, theme))
  buf.write_string(svg_background(size, theme))
  buf.write_string(
    "<circle cx=\"\{size.width - 40}\" cy=\"40\" r=\"18\" fill=\"\{theme.accent}\" opacity=\"0.18\"/>",
  )
  buf.write_string(
    "<text x=\"\{size.padding}\" y=\"48\" font-size=\"13\" font-weight=\"700\" fill=\"\{theme.foreground}\" opacity=\"0.78\">\{escape_xml(title)}</text>",
  )
  buf.write_string(
    "<text x=\"\{size.padding}\" y=\"104\" font-size=\"40\" font-weight=\"800\" fill=\"\{theme.foreground}\">\{escape_xml(value)}</text>",
  )
  if caption != "" {
    buf.write_string(
      "<text x=\"\{size.padding}\" y=\"140\" font-size=\"12\" fill=\"\{theme.foreground}\" opacity=\"0.68\">\{escape_xml(caption)}</text>",
    )
  }
  buf.write_string("</svg>")
  buf.to_string()
}

///|
pub fn render_progress_bar(
  label : String,
  value : Int,
  max : Int,
  size? : ChartSize = ChartSize::new(420, 110, 24),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> String {
  let area = size.plot_area()
  let safe_max = normalize_positive(max, 1)
  let filled = scale_value(value, safe_max, area.width)
  let pct = percent_of(value, safe_max)
  let buf = StringBuilder()
  buf.write_string(svg_header(size, theme))
  buf.write_string(svg_background(size, theme))
  buf.write_string(
    "<text x=\"\{size.padding}\" y=\"34\" font-size=\"13\" font-weight=\"700\" fill=\"\{theme.foreground}\">\{escape_xml(label)}</text>",
  )
  buf.write_string(
    "<rect x=\"\{area.x}\" y=\"54\" width=\"\{area.width}\" height=\"16\" rx=\"8\" fill=\"\{theme.grid}\" opacity=\"0.55\"/>",
  )
  buf.write_string(
    "<rect x=\"\{area.x}\" y=\"54\" width=\"\{filled}\" height=\"16\" rx=\"8\" fill=\"\{theme.accent}\"/>",
  )
  buf.write_string(
    "<text x=\"\{area.x + area.width}\" y=\"34\" text-anchor=\"end\" font-size=\"13\" font-weight=\"700\" fill=\"\{theme.foreground}\">\{pct}%</text>",
  )
  buf.write_string("</svg>")
  buf.to_string()
}

///|
pub fn render_dashboard(
  title : String,
  points : Array[DataPoint],
  trend : Array[Int],
  size? : ChartSize = ChartSize::new(760, 420, 32),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> String {
  let summary = ChartSummary::from_points(points)
  let area = size.plot_area()
  let bar_top = area.y + 156
  let bar_height = area.height - 176
  let bar_width_area = area.width / 2
  let trend_left = area.x + bar_width_area + 52
  let trend_width = area.width - bar_width_area - 52
  let max = normalize_positive(summary.max, 1)
  let buf = StringBuilder()
  buf.write_string(svg_header(size, theme))
  buf.write_string(svg_background(size, theme))
  buf.write_string(svg_title(title, size, theme))
  write_kpi(buf, area.x, area.y + 36, "Total", summary.total.to_string(), theme)
  write_kpi(
    buf,
    area.x + 152,
    area.y + 36,
    "Average",
    summary.average.to_string(),
    theme,
  )
  write_kpi(
    buf,
    area.x + 304,
    area.y + 36,
    "Max",
    summary.max.to_string(),
    theme,
  )
  buf.write_string(
    "<text x=\"\{area.x}\" y=\"\{bar_top - 18}\" font-size=\"12\" font-weight=\"700\" fill=\"\{theme.foreground}\" opacity=\"0.78\">Breakdown</text>",
  )
  if points.length() > 0 {
    let slot = bar_width_area / points.length()
    for i = 0; i < points.length(); i = i + 1 {
      let h = scale_value(points[i].value, max, bar_height)
      let x = area.x + i * slot + 6
      let y = bar_top + bar_height - h
      let w = normalize_positive(slot - 12, 1)
      let fill = if i % 2 == 0 { theme.accent } else { theme.accent_alt }
      buf.write_string(
        "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{w}\" height=\"\{h}\" rx=\"\{theme.radius}\" fill=\"\{fill}\"/>",
      )
      buf.write_string(
        "<text x=\"\{x + w / 2}\" y=\"\{bar_top + bar_height + 18}\" text-anchor=\"middle\" font-size=\"10\" fill=\"\{theme.foreground}\">\{escape_xml(points[i].label)}</text>",
      )
    }
  }
  buf.write_string(
    "<text x=\"\{trend_left}\" y=\"\{bar_top - 18}\" font-size=\"12\" font-weight=\"700\" fill=\"\{theme.foreground}\" opacity=\"0.78\">Trend</text>",
  )
  write_trend_path(
    buf,
    trend,
    { x: trend_left, y: bar_top, width: trend_width, height: bar_height },
    theme,
  )
  buf.write_string("</svg>")
  buf.to_string()
}

///|
fn write_kpi(
  buf : StringBuilder,
  x : Int,
  y : Int,
  label : String,
  value : String,
  theme : ChartTheme,
) -> Unit {
  buf.write_string(
    "<text x=\"\{x}\" y=\"\{y}\" font-size=\"11\" font-weight=\"700\" fill=\"\{theme.foreground}\" opacity=\"0.62\">\{escape_xml(label)}</text>",
  )
  buf.write_string(
    "<text x=\"\{x}\" y=\"\{y + 44}\" font-size=\"32\" font-weight=\"800\" fill=\"\{theme.foreground}\">\{escape_xml(value)}</text>",
  )
}

///|
fn write_trend_path(
  buf : StringBuilder,
  values : Array[Int],
  area : PlotArea,
  theme : ChartTheme,
) -> Unit {
  buf.write_string(
    "<rect x=\"\{area.x}\" y=\"\{area.y}\" width=\"\{area.width}\" height=\"\{area.height}\" rx=\"\{theme.radius}\" fill=\"none\" stroke=\"\{theme.grid}\"/>",
  )
  if values.length() == 0 {
    return
  }
  let max = normalize_positive(max_int(values), 1)
  let step = if values.length() == 1 {
    0
  } else {
    area.width / (values.length() - 1)
  }
  let path = StringBuilder()
  for i = 0; i < values.length(); i = i + 1 {
    let x = area.x + i * step
    let y = area.y + area.height - scale_value(values[i], max, area.height)
    if i == 0 {
      path.write_string("M \{x} \{y}")
    } else {
      path.write_string(" L \{x} \{y}")
    }
  }
  buf.write_string(
    "<path d=\"\{path.to_string()}\" fill=\"none\" stroke=\"\{theme.accent}\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>",
  )
}

///|
fn max_int(values : Array[Int]) -> Int {
  if values.length() == 0 {
    return 0
  }
  let mut best = values[0]
  for i = 1; i < values.length(); i = i + 1 {
    if values[i] > best {
      best = values[i]
    }
  }
  best
}

///|
fn svg_header(size : ChartSize, theme : ChartTheme) -> String {
  "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\{size.width}\" height=\"\{size.height}\" viewBox=\"0 0 \{size.width} \{size.height}\" role=\"img\" style=\"font-family:\{escape_xml(theme.font_family)}\">"
}

///|
fn svg_background(size : ChartSize, theme : ChartTheme) -> String {
  "<rect x=\"0\" y=\"0\" width=\"\{size.width}\" height=\"\{size.height}\" rx=\"\{theme.radius}\" fill=\"\{theme.background}\"/>"
}

///|
fn svg_title(title : String, size : ChartSize, theme : ChartTheme) -> String {
  if title == "" {
    ""
  } else {
    "<text x=\"\{size.width / 2}\" y=\"24\" text-anchor=\"middle\" font-size=\"16\" font-weight=\"700\" fill=\"\{theme.foreground}\">\{escape_xml(title)}</text>"
  }
}

///|
fn normalize_positive(value : Int, fallback : Int) -> Int {
  if value > 0 {
    value
  } else {
    fallback
  }
}
