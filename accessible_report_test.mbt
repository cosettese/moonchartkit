///|
test "accessible report emits labelled SVG and Markdown fallback" {
  let artifact = @moonchartkit.render_accessible_report(
    "Build Health",
    "CI status by target",
    [
      @moonchartkit.DataPoint::new("Native", 12),
      @moonchartkit.DataPoint::new("Wasm", 18),
    ],
    [10, 12, 15, 18],
  )
  assert_true(artifact.svg.contains("<title id=\"moonchartkit-title\">"))
  assert_true(artifact.svg.contains("<desc id=\"moonchartkit-desc\">"))
  assert_true(artifact.svg.contains("aria-labelledby="))
  assert_true(artifact.markdown.contains("| Native | 12 | 40% |"))
  assert_true(artifact.alt_text.contains("2 categories"))
  assert_true(artifact.audit.passed())
}

///|
test "report escapes untrusted SVG and Markdown content" {
  let artifact = @moonchartkit.render_accessible_report(
    "<Build>",
    "A&B <script>alert(1)</script>",
    [@moonchartkit.DataPoint::new("A|B <x>", 5)],
    [5],
  )
  assert_false(artifact.svg.contains("<script>"))
  assert_true(artifact.svg.contains("&lt;script&gt;"))
  assert_true(artifact.svg.contains("A&amp;B"))
  assert_true(artifact.markdown.contains("A\\|B &lt;x&gt;"))
  assert_true(artifact.audit.passed())
}

///|
test "SVG audit reports missing semantics and unsafe scripts" {
  let audit = @moonchartkit.audit_svg(
    "<svg role=\"img\"><script>bad()</script></svg>",
  )
  assert_false(audit.passed())
  assert_false(audit.has_title)
  assert_false(audit.has_description)
  assert_true(audit.has_unsafe_script)
  assert_eq(audit.issue_count, 4)
}

///|
test "empty accessible report remains valid" {
  let artifact = @moonchartkit.render_accessible_report(
    "Empty",
    "No observations",
    [],
    [],
  )
  assert_eq(artifact.summary.count, 0)
  assert_true(artifact.audit.passed())
  assert_true(artifact.markdown.contains("| Label | Value | Share |"))
}
