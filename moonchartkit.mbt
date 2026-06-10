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
pub(all) struct ChartTheme {
  background : String
  foreground : String
  accent : String
  accent_alt : String
  grid : String
  font_family : String
  radius : Int
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
pub fn ChartTheme::atelier() -> ChartTheme {
  {
    background: "#fbfaf7",
    foreground: "#243b53",
    accent: "#2f80ed",
    accent_alt: "#f2994a",
    grid: "#d9e2ec",
    font_family: "Inter, Segoe UI, sans-serif",
    radius: 6,
  }
}

///|
pub fn ChartTheme::midnight() -> ChartTheme {
  {
    background: "#111827",
    foreground: "#f9fafb",
    accent: "#38bdf8",
    accent_alt: "#f472b6",
    grid: "#374151",
    font_family: "Inter, Segoe UI, sans-serif",
    radius: 6,
  }
}

///|
fn normalize_positive(value : Int, fallback : Int) -> Int {
  if value > 0 {
    value
  } else {
    fallback
  }
}
