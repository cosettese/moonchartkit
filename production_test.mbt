///|
test "numeric domain handles negative and positive chart values" {
  let domain = NumericDomain::from_points([
    DataPoint::new("loss", -12),
    DataPoint::new("gain", 24),
  ])
  assert_eq(domain.min, -12)
  assert_eq(domain.max, 24)
  assert_true(domain.include_zero().min <= 0)
  assert_true(domain.include_zero().max >= 0)
}

///|
test "linear scale clamps values and generates readable ticks" {
  let scale = LinearScale::new(NumericDomain::new(-10, 30), 200, 0)
  assert_eq(scale.map(-100), 200)
  assert_eq(scale.map(100), 0)
  let ticks = scale.ticks(5)
  assert_true(ticks.values.length() >= 2)
  assert_true(ticks.step > 0)
}

///|
test "band scale keeps positive bar widths in dense charts" {
  let bands = BandScale::new(10, 40, 20, inner_padding=12)
  assert_eq(bands.slot_width(), 1)
  assert_eq(bands.band_width(), 1)
  assert_true(bands.center_for(3) > bands.center_for(2))
}

///|
test "grid layout calculates deterministic dashboard panel bounds" {
  let grid = GridLayout::new(2, gap=16)
  let rect = grid.cell_rect(
    ChartSize::new(800, 600, 20),
    GridPlacement::new(1, 0),
    2,
  )
  assert_true(rect.x > 20)
  assert_true(rect.width > 0)
  assert_true(rect.height > 0)
}

///|
test "long labels are shortened without dropping a usable suffix marker" {
  assert_eq(truncate_label("very-long-label", 8), "very-...")
  assert_eq(truncate_label("ok", 8), "ok")
  assert_eq(truncate_label("x", 0), "")
}

///|
test "spec renderer emits audited accessible bar chart and data fallback" {
  let spec = ChartSpec::new(
    "CI health",
    "Target status for a release candidate",
    Bar,
    [
      ChartSeries::new("Passing", [DataPoint::new("Wasm", 18)]),
      ChartSeries::new("Warnings", [DataPoint::new("Wasm", 2)]),
    ],
  )
  let artifact = render_chart(spec)
  assert_true(artifact.audit.passed())
  assert_true(artifact.svg.contains("aria-labelledby"))
  assert_true(artifact.svg.contains("<rect"))
  assert_true(artifact.markdown.contains("| Passing | Wasm | 18 |"))
}

///|
test "line area and scatter specs use distinct SVG marks" {
  let series = [
    ChartSeries::new("Latency", [
      DataPoint::new("Mon", 3),
      DataPoint::new("Tue", 8),
    ]),
  ]
  let line = render_chart(ChartSpec::new("Line", "d", Line, series))
  let area = render_chart(ChartSpec::new("Area", "d", Area, series))
  let scatter = render_chart(ChartSpec::new("Scatter", "d", Scatter, series))
  assert_true(line.svg.contains("stroke-width=\"3\""))
  assert_true(area.svg.contains("opacity=\"0.20\""))
  assert_true(scatter.svg.contains("r=\"6\""))
}

///|
test "spec renderer escapes long untrusted labels in SVG and markdown" {
  let spec = ChartSpec::new("<unsafe>", "A&B <script>", Scatter, [
    ChartSeries::new("S|1", [DataPoint::new("<x>|", -5)]),
  ])
  let artifact = render_chart(spec)
  assert_false(artifact.svg.contains("<script>"))
  assert_true(artifact.svg.contains("&lt;script&gt;"))
  assert_true(artifact.markdown.contains("S\\|1"))
  assert_true(artifact.audit.passed())
}

///|
test "empty chart specification remains an accessible artifact" {
  let artifact = render_chart(ChartSpec::new("Empty", "none", Line, []))
  assert_true(artifact.audit.passed())
  assert_true(artifact.svg.contains("<svg"))
  assert_true(artifact.markdown.contains("| Series | Label | Value |"))
}
