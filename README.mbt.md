# MoonChartKit

MoonChartKit 是一个面向 MoonBit 的轻量 SVG 报告组件与嵌入式可视化基础库。

项目聚焦报告型可视化组件、数据摘要、指标卡片、sparkline、进度条和 dashboard 拼装。核心库不依赖浏览器或文件系统，主要输出可嵌入网页、Markdown、文档或工具链的 SVG 字符串。

## 当前能力

- 柱状图 SVG：适合分类对比
- 折线图 SVG：适合趋势展示
- Sparkline：适合表格、仪表盘和小组件
- Metric Card：适合关键指标摘要
- Progress Bar：适合覆盖率、完成度和任务进度
- Dashboard：将 KPI、分类 breakdown 和趋势 sparkline 组合成单个 SVG 报告块
- ChartSummary：输出 count、total、max、average 摘要和 JSON
- 主题系统：内置 Atelier 与 Midnight 两套风格
- 数据工具：绘图区计算、最大值、总量、缩放
- 安全输出：标签和文本会进行 XML 转义
- CLI 演示：`moon run cmd/main` 可直接输出 SVG

## 与已有项目的关系

社区已有 `JunJunTnT/moonchart`，它是完整的 MoonBit SVG charting library，面向科学和统计绘图，公开 README 中覆盖 bar、line、scatter、box plot、error bars、多系列渲染、样式控制、WASM 使用和性能对比。

MoonChartKit 不把目标放在复刻完整统计图表库，而是补齐更轻量的“报告组件层”：

- 面向 README、CI 报告、Markdown 文档、课程材料和小型 dashboard 嵌入，而不是完整科研绘图库。
- 重点提供 metric card、sparkline、progress bar、dashboard、ChartSummary 等可组合报告块。
- 输出单个 SVG 字符串，方便贴进文档、Issue、PR 描述、静态站点和自动化报告。
- 后续重点是报告布局、SVG 快照测试、主题 token、嵌入规范和数据摘要，而不是 scatter、boxplot、error bars、WASM chart engine。

## 快速开始

```bash
moon test
moon run cmd/main
```

```moonbit nocheck
///|
let points = [
  @moonchartkit.DataPoint::new("Core", 32),
  @moonchartkit.DataPoint::new("Wasm", 48),
  @moonchartkit.DataPoint::new("Tools", 28),
]

///|
let svg = @moonchartkit.render_dashboard("MoonChartKit Demo", points, [
  12, 18, 16, 24, 28,
])
```

更多展示计划见 [examples/gallery.md](examples/gallery.md)。

## 设计原则

- 后端中立：核心库不依赖浏览器、Canvas、DOM 或文件系统
- 输出明确：以 SVG 字符串作为主要交付接口
- 风格统一：主题控制颜色、字体和圆角
- 可测试：布局、转义、图形输出都通过 MoonBit 测试覆盖
- 可追踪：功能路线、Issue、PR、CHANGELOG 和 CI 都围绕公开仓库维护
