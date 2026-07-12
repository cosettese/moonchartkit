///|
/// Deterministic data transforms used before chart rendering.
pub(all) struct SeriesStatistics {
  count : Int
  min : Int
  max : Int
  total : Int
  average : Int
} derive(Eq, Debug)

///|
pub fn series_statistics(points : Array[DataPoint]) -> SeriesStatistics {
  if points.length() == 0 {
    return { count: 0, min: 0, max: 0, total: 0, average: 0 }
  }
  let mut low = points[0].value
  let mut high = points[0].value
  let mut total = 0
  for point in points {
    total = total + point.value
    if point.value < low {
      low = point.value
    }
    if point.value > high {
      high = point.value
    }
  }
  {
    count: points.length(),
    min: low,
    max: high,
    total,
    average: total / points.length(),
  }
}

///|
/// Produces a running total while preserving category labels.
pub fn cumulative_series(points : Array[DataPoint]) -> Array[DataPoint] {
  let result : Array[DataPoint] = []
  let mut total = 0
  for point in points {
    total = total + point.value
    result.push(DataPoint::new(point.label, total))
  }
  result
}

///|
/// Computes a trailing integer moving average. A non-positive window becomes 1.
pub fn moving_average_series(
  points : Array[DataPoint],
  window : Int,
) -> Array[DataPoint] {
  let result : Array[DataPoint] = []
  let width = if window > 0 { window } else { 1 }
  let mut rolling = 0
  for i = 0; i < points.length(); i = i + 1 {
    rolling = rolling + points[i].value
    if i >= width {
      rolling = rolling - points[i - width].value
    }
    let denominator = if i + 1 < width { i + 1 } else { width }
    result.push(DataPoint::new(points[i].label, rolling / denominator))
  }
  result
}

///|
/// Converts values into integer percentages that sum approximately to 100.
pub fn percent_series(points : Array[DataPoint]) -> Array[DataPoint] {
  let result : Array[DataPoint] = []
  let total = total_value(points)
  for point in points {
    result.push(DataPoint::new(point.label, percent_of(point.value, total)))
  }
  result
}

///|
/// Clamps each value to a declared visual domain without mutating input data.
pub fn clamp_series(
  points : Array[DataPoint],
  domain : NumericDomain,
) -> Array[DataPoint] {
  let result : Array[DataPoint] = []
  for point in points {
    let value = if point.value < domain.min {
      domain.min
    } else if point.value > domain.max {
      domain.max
    } else {
      point.value
    }
    result.push(DataPoint::new(point.label, value))
  }
  result
}

///|
/// Calculates point-to-point deltas; the first point is anchored at zero.
pub fn delta_series(points : Array[DataPoint]) -> Array[DataPoint] {
  let result : Array[DataPoint] = []
  for i = 0; i < points.length(); i = i + 1 {
    let previous = if i == 0 { points[i].value } else { points[i - 1].value }
    result.push(DataPoint::new(points[i].label, points[i].value - previous))
  }
  result
}
