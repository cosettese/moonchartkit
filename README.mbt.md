# MoonChartKit

MoonChartKit 是一个面向 MoonBit 的轻量图表与 SVG 可视化基础库。

项目聚焦数据可视化基础设施，和 MoonNavKit、MoonSketchKit、MoonLexKit 分别处在不同方向。核心库不依赖浏览器或文件系统，主要输出可嵌入网页、文档或工具链的 SVG 字符串。

## 当前能力

- 柱状图 SVG：适合分类对比
- 折线图 SVG：适合趋势展示
- Sparkline：适合表格、仪表盘和小组件
- Metric Card：适合关键指标摘要
- 主题系统：内置 Atelier 与 Midnight 两套风格
- 数据工具：绘图区计算、最大值、总量、缩放
- 安全输出：标签和文本会进行 XML 转义
- CLI 演示：`moon run cmd/main` 可直接输出 SVG

## 快速开始

```bash
moon test
moon run cmd/main
```

```moonbit
let points = [
  @moonchartkit.DataPoint::new("Core", 32),
  @moonchartkit.DataPoint::new("Wasm", 48),
  @moonchartkit.DataPoint::new("Tools", 28),
]

let svg = @moonchartkit.render_bar_chart(points, title="MoonChartKit Demo")
```

## 设计原则

- 后端中立：核心库不依赖浏览器、Canvas、DOM 或文件系统
- 输出明确：以 SVG 字符串作为主要交付接口
- 风格统一：主题控制颜色、字体和圆角
- 可测试：布局、转义、图形输出都通过 MoonBit 测试覆盖
- 可追踪：功能路线、Issue、PR、CHANGELOG 和 CI 都围绕公开仓库维护
