///|
fn main {
  let points = [
    @chart.DataPoint::new("Core", 32),
    @chart.DataPoint::new("Wasm", 48),
    @chart.DataPoint::new("Tools", 28),
    @chart.DataPoint::new("Apps", 40),
  ]
  println(
    @chart.render_dashboard("MoonChartKit Report", points, [12, 18, 16, 24, 28]),
  )
}
