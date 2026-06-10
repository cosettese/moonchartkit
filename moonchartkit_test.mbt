///|
test "chart size normalizes invalid dimensions" {
  let size = @moonchartkit.ChartSize::new(0, -1, 0)
  assert_eq(size.width, 640)
  assert_eq(size.height, 360)
  assert_eq(size.padding, 32)
}

///|
test "data point stores label and value" {
  let point = @moonchartkit.DataPoint::new("MoonBit", 42)
  assert_eq(point.label, "MoonBit")
  assert_eq(point.value, 42)
}

///|
test "atelier theme provides polished defaults" {
  let theme = @moonchartkit.ChartTheme::atelier()
  assert_eq(theme.background, "#fbfaf7")
  assert_eq(theme.accent, "#2f80ed")
  assert_eq(theme.radius, 6)
}

///|
test "midnight theme uses dark background" {
  let theme = @moonchartkit.ChartTheme::midnight()
  assert_eq(theme.background, "#111827")
  assert_eq(theme.foreground, "#f9fafb")
}

///|
test "plot area respects chart padding" {
  let area = @moonchartkit.ChartSize::new(400, 240, 24).plot_area()
  assert_eq(area.x, 24)
  assert_eq(area.y, 24)
  assert_eq(area.width, 352)
  assert_eq(area.height, 192)
}

///|
test "dataset helpers compute max and total" {
  let points = [
    @moonchartkit.DataPoint::new("A", 10),
    @moonchartkit.DataPoint::new("B", 30),
    @moonchartkit.DataPoint::new("C", 20),
  ]
  assert_eq(@moonchartkit.max_value(points), 30)
  assert_eq(@moonchartkit.total_value(points), 60)
}

///|
test "labels are escaped for svg output" {
  assert_eq(@moonchartkit.escape_label("A&B <Q>"), "A&amp;B &lt;Q&gt;")
}

///|
test "bar chart renders svg with bars and title" {
  let points = [
    @moonchartkit.DataPoint::new("Core", 30),
    @moonchartkit.DataPoint::new("Web", 20),
  ]
  let svg = @moonchartkit.render_bar_chart(points, title="MoonBit Usage")
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("MoonBit Usage"))
  assert_true(svg.contains("<rect"))
  assert_true(svg.contains("Core"))
}

///|
test "bar chart escapes labels" {
  let points = [@moonchartkit.DataPoint::new("A&B", 10)]
  let svg = @moonchartkit.render_bar_chart(points)
  assert_true(svg.contains("A&amp;B"))
}

///|
test "line chart renders path and point markers" {
  let points = [
    @moonchartkit.DataPoint::new("Jan", 10),
    @moonchartkit.DataPoint::new("Feb", 30),
    @moonchartkit.DataPoint::new("Mar", 20),
  ]
  let svg = @moonchartkit.render_line_chart(points, title="Trend")
  assert_true(svg.contains("<path"))
  assert_true(svg.contains("<circle"))
  assert_true(svg.contains("Trend"))
}
