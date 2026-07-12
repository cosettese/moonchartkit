///|
/// Supported Cartesian encodings in the composable chart renderer.
pub(all) enum ChartKind {
  Bar
  Line
  Area
  Scatter
} derive(Eq, Debug)

///|
/// A named series with deterministic point order.
pub(all) struct ChartSeries {
  name : String
  points : Array[DataPoint]
  color : String
} derive(Eq, Debug)

///|
/// Declarative chart description shared by renderers, exports, and dashboards.
pub(all) struct ChartSpec {
  title : String
  description : String
  kind : ChartKind
  series : Array[ChartSeries]
  size : ChartSize
  margins : ChartMargins
  theme : ChartTheme
  show_legend : Bool
  show_grid : Bool
} derive(Eq, Debug)

///|
/// A fully rendered chart plus accessible non-visual fallbacks.
pub(all) struct ChartArtifact {
  svg : String
  markdown : String
  alt_text : String
  audit : SvgAudit
} derive(Eq, Debug)

///|
pub fn ChartSeries::new(
  name : String,
  points : Array[DataPoint],
  color? : String = "",
) -> ChartSeries {
  { name, points, color }
}

///|
pub fn ChartSpec::new(
  title : String,
  description : String,
  kind : ChartKind,
  series : Array[ChartSeries],
  size? : ChartSize = ChartSize::new(760, 440, 28),
  margins? : ChartMargins = ChartMargins::standard(),
  theme? : ChartTheme = ChartTheme::atelier(),
) -> ChartSpec {
  {
    title,
    description,
    kind,
    series,
    size,
    margins,
    theme,
    show_legend: true,
    show_grid: true,
  }
}

///|
pub fn ChartSpec::with_legend(self : ChartSpec, visible : Bool) -> ChartSpec {
  {
    title: self.title,
    description: self.description,
    kind: self.kind,
    series: self.series,
    size: self.size,
    margins: self.margins,
    theme: self.theme,
    show_legend: visible,
    show_grid: self.show_grid,
  }
}

///|
pub fn ChartSpec::with_grid(self : ChartSpec, visible : Bool) -> ChartSpec {
  {
    title: self.title,
    description: self.description,
    kind: self.kind,
    series: self.series,
    size: self.size,
    margins: self.margins,
    theme: self.theme,
    show_legend: self.show_legend,
    show_grid: visible,
  }
}

///|
pub fn ChartSpec::all_points(self : ChartSpec) -> Array[DataPoint] {
  let result : Array[DataPoint] = []
  for series in self.series {
    for point in series.points {
      result.push(point)
    }
  }
  result
}

///|
pub fn ChartSpec::category_count(self : ChartSpec) -> Int {
  if self.series.length() == 0 {
    0
  } else {
    self.series[0].points.length()
  }
}

///|
fn chart_series_color(
  series : ChartSeries,
  index : Int,
  theme : ChartTheme,
) -> String {
  if series.color != "" {
    series.color
  } else if index % 4 == 0 {
    theme.accent
  } else if index % 4 == 1 {
    theme.accent_alt
  } else if index % 4 == 2 {
    "#22c55e"
  } else {
    "#a855f7"
  }
}
