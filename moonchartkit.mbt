///|
pub(all) struct ChartSize {
  width : Int
  height : Int
  padding : Int
} derive(Eq, Debug)

///|
pub(all) struct DataPoint {
  label : String
  value : Int
} derive(Eq, Debug)

///|
pub fn ChartSize::new(width : Int, height : Int, padding : Int) -> ChartSize {
  {
    width: normalize_positive(width, 640),
    height: normalize_positive(height, 360),
    padding: normalize_positive(padding, 32),
  }
}

///|
pub fn DataPoint::new(label : String, value : Int) -> DataPoint {
  { label, value }
}

///|
fn normalize_positive(value : Int, fallback : Int) -> Int {
  if value > 0 {
    value
  } else {
    fallback
  }
}
