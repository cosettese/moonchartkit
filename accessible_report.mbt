///|
/// Structural accessibility and safety checks for generated SVG.
pub(all) struct SvgAudit {
  has_title : Bool
  has_description : Bool
  has_aria_labelledby : Bool
  has_role_img : Bool
  has_unsafe_script : Bool
  issue_count : Int
} derive(Eq, Debug)

///|
/// A report bundle with visual and non-visual representations.
pub(all) struct ReportArtifact {
  svg : String
  markdown : String
  alt_text : String
  summary : ChartSummary
  audit : SvgAudit
} derive(Eq, Debug)

///|
pub fn SvgAudit::passed(self : SvgAudit) -> Bool {
  self.issue_count == 0
}

///|
/// Audits the accessibility contract used by MoonChartKit report artifacts.
pub fn audit_svg(svg : String) -> SvgAudit {
  let has_title = svg.contains("<title")
  let has_description = svg.contains("<desc")
  let has_aria_labelledby = svg.contains("aria-labelledby=")
  let has_role_img = svg.contains("role=\"img\"")
  let has_unsafe_script = svg.contains("<script") || svg.contains("javascript:")
  let mut issues = 0
  if !has_title {
    issues = issues + 1
  }
  if !has_description {
    issues = issues + 1
  }
  if !has_aria_labelledby {
    issues = issues + 1
  }
  if !has_role_img {
    issues = issues + 1
  }
  if has_unsafe_script {
    issues = issues + 1
  }
  {
    has_title,
    has_description,
    has_aria_labelledby,
    has_role_img,
    has_unsafe_script,
    issue_count: issues,
  }
}

///|
/// Generates an accessible SVG report and a Markdown data fallback.
pub fn render_accessible_report(
  title : String,
  description : String,
  points : Array[DataPoint],
  trend : Array[Int],
  size? : ChartSize = ChartSize::new(760, 420, 32),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> ReportArtifact {
  let summary = ChartSummary::from_points(points)
  let svg = render_accessible_svg(
    title, description, points, trend, summary, size, theme,
  )
  let markdown = render_markdown_report(title, description, points, summary)
  let alt_text = "\{title}. \{description}. \{summary.count} categories, total \{summary.total}, average \{summary.average}, maximum \{summary.max}."
  { svg, markdown, alt_text, summary, audit: audit_svg(svg) }
}

///|
fn render_accessible_svg(
  title : String,
  description : String,
  points : Array[DataPoint],
  trend : Array[Int],
  summary : ChartSummary,
  size : ChartSize,
  theme : ChartTheme,
) -> String {
  let area = size.plot_area()
  let chart_top = area.y + 146
  let chart_height = normalize_positive(area.height - 166, 1)
  let left_width = area.width / 2
  let trend_left = area.x + left_width + 48
  let trend_width = normalize_positive(area.width - left_width - 48, 1)
  let max = normalize_positive(summary.max, 1)
  let buf = StringBuilder()
  buf.write_string(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\{size.width}\" height=\"\{size.height}\" viewBox=\"0 0 \{size.width} \{size.height}\" role=\"img\" aria-labelledby=\"moonchartkit-title moonchartkit-desc\" style=\"font-family:\{escape_xml(theme.font_family)}\">",
  )
  buf.write_string(
    "<title id=\"moonchartkit-title\">\{escape_xml(title)}</title>",
  )
  buf.write_string(
    "<desc id=\"moonchartkit-desc\">\{escape_xml(description)}</desc>",
  )
  buf.write_string(svg_background(size, theme))
  buf.write_string(svg_title(title, size, theme))
  write_kpi(buf, area.x, area.y + 34, "Total", summary.total.to_string(), theme)
  write_kpi(
    buf,
    area.x + 150,
    area.y + 34,
    "Average",
    summary.average.to_string(),
    theme,
  )
  write_kpi(
    buf,
    area.x + 300,
    area.y + 34,
    "Max",
    summary.max.to_string(),
    theme,
  )
  if points.length() > 0 {
    let slot = left_width / points.length()
    for i = 0; i < points.length(); i = i + 1 {
      let height = scale_value(points[i].value, max, chart_height)
      let width = normalize_positive(slot - 10, 1)
      let x = area.x + i * slot + 5
      let y = chart_top + chart_height - height
      let fill = if i % 2 == 0 { theme.accent } else { theme.accent_alt }
      buf.write_string(
        "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{width}\" height=\"\{height}\" rx=\"\{theme.radius}\" fill=\"\{fill}\"/>",
      )
      buf.write_string(
        "<text x=\"\{x + width / 2}\" y=\"\{chart_top + chart_height + 16}\" text-anchor=\"middle\" font-size=\"10\" fill=\"\{theme.foreground}\">\{escape_xml(points[i].label)}</text>",
      )
    }
  }
  write_trend_path(
    buf,
    trend,
    { x: trend_left, y: chart_top, width: trend_width, height: chart_height },
    theme,
  )
  buf.write_string("</svg>")
  buf.to_string()
}

///|
fn render_markdown_report(
  title : String,
  description : String,
  points : Array[DataPoint],
  summary : ChartSummary,
) -> String {
  let buf = StringBuilder()
  buf.write_string("## \{escape_markdown(title)}\n\n")
  buf.write_string("\{escape_markdown(description)}\n\n")
  buf.write_string(
    "Total: **\{summary.total}** | Average: **\{summary.average}** | Max: **\{summary.max}**\n\n",
  )
  buf.write_string("| Label | Value | Share |\n| --- | ---: | ---: |\n")
  for point in points {
    buf.write_string(
      "| \{escape_markdown(point.label)} | \{point.value} | \{percent_of(point.value, summary.total)}% |\n",
    )
  }
  buf.to_string()
}

///|
fn escape_markdown(value : String) -> String {
  value
  .replace(old="\\", new="\\\\")
  .replace(old="|", new="\\|")
  .replace(old="<", new="&lt;")
  .replace(old=">", new="&gt;")
}
