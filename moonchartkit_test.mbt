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
