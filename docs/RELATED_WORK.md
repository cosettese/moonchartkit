# 相关项目差异说明

本文件用于回应报名初审中关于 MoonChartKit 与社区已有 `JunJunTnT/moonchart` 项目关系的疑问。

## 社区已有项目

`JunJunTnT/moonchart` 是一个用 MoonBit 编写的 SVG 图表库。其 README 说明它面向科学和统计绘图，可输出 SVG 字符串，支持 bar charts、line charts、scatter plots、box plots、error bars、多系列渲染、样式控制和 WASM 使用，并提供性能对比。

## MoonChartKit 的差异

MoonChartKit 不定位为完整统计图表库，也不计划复刻 scatter、box plot、error bars、多系列科研绘图和 WASM chart engine。它定位为轻量 SVG 报告组件与嵌入式可视化基础库。

- `ChartSummary`：提供 count、total、max、average 摘要和 JSON 输出，适合自动化报告。
- `render_metric_card`：输出单个指标卡片，适合 README、CI 报告和文档嵌入。
- `render_sparkline`：输出小型趋势线，适合表格、仪表盘和紧凑型状态展示。
- `render_progress_bar`：输出覆盖率、完成度、任务进度等进度组件。
- `render_dashboard`：把 KPI、分类 breakdown 和趋势图组合成单个 SVG 报告块。
- 核心目标是安全 SVG 字符串、报告布局、主题 token、快照测试和 Markdown/HTML 嵌入。

## 独立价值

MoonChartKit 更适合用作工具链输出层：测试报告、提交摘要、项目 README、课程材料、Issue/PR 描述、静态文档站点和小型 dashboard。它不是要替代 `moonchart` 的完整图表能力，而是补齐 MoonBit 生态中“数据摘要到可嵌入 SVG 报告块”的轻量组件层。
