///|
fn main {
  let points = [
    @chart.DataPoint::new("Core", 32),
    @chart.DataPoint::new("Wasm", 48),
    @chart.DataPoint::new("Tools", 28),
    @chart.DataPoint::new("Apps", 40),
  ]
  println(@chart.render_bar_chart(points, title="MoonChartKit Demo"))
}
