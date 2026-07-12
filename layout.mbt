///|
/// Explicit margins reserved for titles, legends, axes, and labels.
pub(all) struct ChartMargins {
  top : Int
  right : Int
  bottom : Int
  left : Int
} derive(Eq, Debug)

///|
/// A rectangle in SVG user-space coordinates.
pub(all) struct ChartRect {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Eq, Debug)

///|
/// Grid configuration for composing dashboard panels.
pub(all) struct GridLayout {
  columns : Int
  gap : Int
  margins : ChartMargins
} derive(Eq, Debug)

///|
/// Position and span of one panel inside a grid layout.
pub(all) struct GridPlacement {
  column : Int
  row : Int
  column_span : Int
  row_span : Int
} derive(Eq, Debug)

///|
pub fn ChartMargins::new(
  top : Int,
  right : Int,
  bottom : Int,
  left : Int,
) -> ChartMargins {
  {
    top: non_negative_margin(top),
    right: non_negative_margin(right),
    bottom: non_negative_margin(bottom),
    left: non_negative_margin(left),
  }
}

///|
pub fn ChartMargins::standard() -> ChartMargins {
  ChartMargins::new(48, 28, 52, 60)
}

///|
pub fn ChartRect::new(x : Int, y : Int, width : Int, height : Int) -> ChartRect {
  {
    x,
    y,
    width: if width > 1 {
      width
    } else {
      1
    },
    height: if height > 1 {
      height
    } else {
      1
    },
  }
}

///|
pub fn ChartRect::inset(self : ChartRect, margins : ChartMargins) -> ChartRect {
  ChartRect::new(
    self.x + margins.left,
    self.y + margins.top,
    self.width - margins.left - margins.right,
    self.height - margins.top - margins.bottom,
  )
}

///|
pub fn ChartRect::right(self : ChartRect) -> Int {
  self.x + self.width
}

///|
pub fn ChartRect::bottom(self : ChartRect) -> Int {
  self.y + self.height
}

///|
pub fn GridLayout::new(
  columns : Int,
  gap? : Int = 16,
  margins? : ChartMargins = ChartMargins::new(24, 24, 24, 24),
) -> GridLayout {
  {
    columns: if columns > 0 {
      columns
    } else {
      1
    },
    gap: if gap >= 0 {
      gap
    } else {
      0
    },
    margins,
  }
}

///|
pub fn GridPlacement::new(
  column : Int,
  row : Int,
  column_span? : Int = 1,
  row_span? : Int = 1,
) -> GridPlacement {
  {
    column: if column >= 0 {
      column
    } else {
      0
    },
    row: if row >= 0 {
      row
    } else {
      0
    },
    column_span: if column_span > 0 {
      column_span
    } else {
      1
    },
    row_span: if row_span > 0 {
      row_span
    } else {
      1
    },
  }
}

///|
pub fn GridLayout::cell_rect(
  self : GridLayout,
  size : ChartSize,
  placement : GridPlacement,
  row_count : Int,
) -> ChartRect {
  let outer = ChartRect::new(0, 0, size.width, size.height).inset(self.margins)
  let safe_rows = if row_count > 0 { row_count } else { 1 }
  let cell_width = (outer.width - (self.columns - 1) * self.gap) / self.columns
  let cell_height = (outer.height - (safe_rows - 1) * self.gap) / safe_rows
  let start_column = if placement.column < self.columns {
    placement.column
  } else {
    self.columns - 1
  }
  let width_span = if start_column + placement.column_span <= self.columns {
    placement.column_span
  } else {
    self.columns - start_column
  }
  ChartRect::new(
    outer.x + start_column * (cell_width + self.gap),
    outer.y + placement.row * (cell_height + self.gap),
    cell_width * width_span + self.gap * (width_span - 1),
    cell_height * placement.row_span + self.gap * (placement.row_span - 1),
  )
}

///|
/// Returns a deterministic shortened label for narrow chart panels.
pub fn truncate_label(value : String, max_chars : Int) -> String {
  if max_chars <= 0 {
    return ""
  }
  if value.length() <= max_chars {
    value
  } else if max_chars <= 3 {
    "..."
  } else {
    value[:max_chars - 3].to_owned() + "..."
  }
}

///|
fn non_negative_margin(value : Int) -> Int {
  if value >= 0 {
    value
  } else {
    0
  }
}
