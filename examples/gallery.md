# MoonChartKit Gallery

本目录用于收集可复制的 SVG 图表示例。当前 CLI 示例：

```bash
moon run cmd/main
```

会输出一个带主题、标题、圆角条形、标签和安全 XML 转义能力的 SVG 柱状图。

## 示例数据

```moonbit
let points = [
  @chart.DataPoint::new("Core", 32),
  @chart.DataPoint::new("Wasm", 48),
  @chart.DataPoint::new("Tools", 28),
  @chart.DataPoint::new("Apps", 40),
]
```

## 后续画廊计划

- `bar-basic.svg`
- `line-trend.svg`
- `sparkline-compact.svg`
- `metric-card.svg`
