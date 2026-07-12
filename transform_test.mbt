///|
test "series transforms retain labels and deterministic integer values" {
  let points = [
    DataPoint::new("A", 2),
    DataPoint::new("B", 4),
    DataPoint::new("C", 8),
  ]
  let stats = series_statistics(points)
  assert_eq(stats.total, 14)
  assert_eq(stats.average, 4)
  assert_true(
    cumulative_series(points) ==
    [DataPoint::new("A", 2), DataPoint::new("B", 6), DataPoint::new("C", 14)],
  )
  assert_true(
    moving_average_series(points, 2) ==
    [DataPoint::new("A", 2), DataPoint::new("B", 3), DataPoint::new("C", 6)],
  )
  assert_true(
    delta_series(points) ==
    [DataPoint::new("A", 0), DataPoint::new("B", 2), DataPoint::new("C", 4)],
  )
}

///|
test "percent and clamp transforms handle empty and out of domain data" {
  assert_true(percent_series([]) == [])
  let points = [DataPoint::new("Low", -4), DataPoint::new("High", 18)]
  assert_true(
    clamp_series(points, NumericDomain::new(0, 10)) ==
    [DataPoint::new("Low", 0), DataPoint::new("High", 10)],
  )
}
