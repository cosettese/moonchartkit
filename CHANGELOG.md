# Changelog

## 0.1.1 - 2026-06-17

- 补充与 `JunJunTnT/moonchart` 的关系说明，明确项目定位为轻量 SVG 报告组件层。
- 新增 `ChartSummary`，支持 count、total、max、average 摘要和 JSON 输出。
- 新增 `percent_of` 与 `render_progress_bar`，支持覆盖率、完成度和任务进度组件。
- 新增 `render_dashboard`，将 KPI、分类 breakdown 和趋势图组合为单个 SVG 报告块。
- 更新 CLI 演示与测试，当前 MoonBit 测试扩展到 14 个。

## 0.1.0 - 2026-06-10

- 初始化 MoonChartKit 项目结构
- 添加图表尺寸、数据点和主题模型
- 添加绘图区计算、最大值、总量和缩放辅助
- 添加 SVG 画布基础设施和 XML 转义
- 实现柱状图、折线图、sparkline 和指标卡片
- 添加 CLI SVG 演示
- 添加 MoonBit 测试、CI、Issue 模板和 PR 模板
