///|
/// Inclusive numeric domain used by axes and continuous chart encodings.
pub(all) struct NumericDomain {
  min : Int
  max : Int
} derive(Eq, Debug)

///|
/// Maps integer values from a numeric domain into a pixel interval.
pub(all) struct LinearScale {
  domain : NumericDomain
  range_start : Int
  range_end : Int
} derive(Eq, Debug)

///|
/// Discrete positions for bars, categorical points, and labels.
pub(all) struct BandScale {
  start : Int
  end : Int
  count : Int
  inner_padding : Int
} derive(Eq, Debug)

///|
/// Tick labels generated for a numeric axis.
pub(all) struct TickSet {
  values : Array[Int]
  step : Int
} derive(Eq, Debug)

///|
pub fn NumericDomain::new(minimum : Int, maximum : Int) -> NumericDomain {
  if minimum < maximum {
    { min: minimum, max: maximum }
  } else if minimum > maximum {
    { min: maximum, max: minimum }
  } else {
    { min: minimum - 1, max: maximum + 1 }
  }
}

///|
pub fn NumericDomain::from_points(points : Array[DataPoint]) -> NumericDomain {
  if points.length() == 0 {
    return NumericDomain::new(0, 1)
  }
  let mut low = points[0].value
  let mut high = points[0].value
  for i = 1; i < points.length(); i = i + 1 {
    let value = points[i].value
    if value < low {
      low = value
    }
    if value > high {
      high = value
    }
  }
  NumericDomain::new(low, high)
}

///|
/// Extends a domain to include zero, suitable for bars and area charts.
pub fn NumericDomain::include_zero(self : NumericDomain) -> NumericDomain {
  NumericDomain::new(
    if self.min < 0 {
      self.min
    } else {
      0
    },
    if self.max > 0 {
      self.max
    } else {
      0
    },
  )
}

///|
pub fn NumericDomain::span(self : NumericDomain) -> Int {
  self.max - self.min
}

///|
pub fn LinearScale::new(
  domain : NumericDomain,
  range_start : Int,
  range_end : Int,
) -> LinearScale {
  { domain, range_start, range_end }
}

///|
pub fn LinearScale::map(self : LinearScale, value : Int) -> Int {
  let span = self.domain.span()
  if span <= 0 {
    return self.range_start
  }
  let clamped = if value < self.domain.min {
    self.domain.min
  } else if value > self.domain.max {
    self.domain.max
  } else {
    value
  }
  self.range_start +
  (clamped - self.domain.min) * (self.range_end - self.range_start) / span
}

///|
pub fn LinearScale::ticks(self : LinearScale, desired_count : Int) -> TickSet {
  let desired = if desired_count < 2 { 2 } else { desired_count }
  let step = nice_tick_step(self.domain.span(), desired - 1)
  let first = floor_to_step(self.domain.min, step)
  let values : Array[Int] = []
  let mut value = first
  let limit = self.domain.max + step
  while value <= limit {
    if value >= self.domain.min && value <= self.domain.max {
      values.push(value)
    }
    value = value + step
  }
  if values.length() == 0 {
    values.push(self.domain.min)
    values.push(self.domain.max)
  }
  { values, step }
}

///|
pub fn BandScale::new(
  start : Int,
  end : Int,
  count : Int,
  inner_padding? : Int = 8,
) -> BandScale {
  {
    start,
    end: if end >= start {
      end
    } else {
      start
    },
    count: if count > 0 {
      count
    } else {
      0
    },
    inner_padding: if inner_padding >= 0 {
      inner_padding
    } else {
      0
    },
  }
}

///|
pub fn BandScale::slot_width(self : BandScale) -> Int {
  if self.count <= 0 {
    0
  } else {
    (self.end - self.start) / self.count
  }
}

///|
pub fn BandScale::band_width(self : BandScale) -> Int {
  let width = self.slot_width() - self.inner_padding
  if width > 1 {
    width
  } else {
    1
  }
}

///|
pub fn BandScale::x_for(self : BandScale, index : Int) -> Int {
  self.start + index * self.slot_width() + self.inner_padding / 2
}

///|
pub fn BandScale::center_for(self : BandScale, index : Int) -> Int {
  self.x_for(index) + self.band_width() / 2
}

///|
fn nice_tick_step(span : Int, target_steps : Int) -> Int {
  if span <= 0 || target_steps <= 0 {
    return 1
  }
  let raw = (span + target_steps - 1) / target_steps
  let magnitude = power_of_ten(raw)
  let normalized = (raw + magnitude - 1) / magnitude
  let multiplier = if normalized <= 1 {
    1
  } else if normalized <= 2 {
    2
  } else if normalized <= 5 {
    5
  } else {
    10
  }
  multiplier * magnitude
}

///|
fn power_of_ten(value : Int) -> Int {
  let mut power = 1
  let mut remaining = if value > 0 { value } else { 1 }
  while remaining >= 10 {
    power = power * 10
    remaining = remaining / 10
  }
  power
}

///|
fn floor_to_step(value : Int, step : Int) -> Int {
  if value >= 0 {
    value / step * step
  } else {
    -((-value + step - 1) / step * step)
  }
}
