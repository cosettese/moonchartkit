# MoonChartKit Gallery

运行基础 Dashboard：

```bash
moon run cmd/main
```

生成具备 SVG、Markdown 和替代文本的报告工件：

```moonbit
let points = [
  DataPoint::new("Core", 32),
  DataPoint::new("Wasm", 48),
  DataPoint::new("Tools", 28),
  DataPoint::new("Apps", 40),
]

let artifact = render_accessible_report(
  "MoonChartKit Report",
  "Package activity by area",
  points,
  [12, 18, 16, 24, 28],
)

assert_true(artifact.audit.passed())
```

建议将 `artifact.svg` 嵌入网页或文档，并在不支持 SVG 的环境中使用
`artifact.markdown` 或 `artifact.alt_text`。
