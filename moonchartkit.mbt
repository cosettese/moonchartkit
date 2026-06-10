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
