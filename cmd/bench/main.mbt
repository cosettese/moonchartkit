///|
fn main {
  let mut passed = 0
  let mut svg_chars = 0
  let mut markdown_chars = 0
  let mut alt_chars = 0
  for report = 0; report < 100; report = report + 1 {
    let points : Array[@chart.DataPoint] = []
    let trend : Array[Int] = []
    for i = 0; i < 20; i = i + 1 {
      points.push(@chart.DataPoint::new("T\{i}", (report * 13 + i * 17) % 101))
      trend.push((report * 7 + i * 11) % 101)
    }
    let artifact = @chart.render_accessible_report(
      "CI Report \{report}",
      "Deterministic build metrics",
      points,
      trend,
    )
    if artifact.audit.passed() {
      passed = passed + 1
    }
    svg_chars = svg_chars + artifact.svg.length()
    markdown_chars = markdown_chars + artifact.markdown.length()
    alt_chars = alt_chars + artifact.alt_text.length()
  }
  println("reports,audits_passed,svg_chars,markdown_chars,alt_chars")
  println("\{100},\{passed},\{svg_chars},\{markdown_chars},\{alt_chars}")
}
