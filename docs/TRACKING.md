# 公开开发跟踪

MoonChartKit 按公开仓库持续开发方式推进，核心证据包括提交记录、Issue、Pull Request、CHANGELOG、ROADMAP 和 CI。

## 当前提交主题

- 基础骨架与仓库元数据
- 主题系统
- 图表布局与数据统计
- SVG 画布基础设施
- 柱状图 SVG
- 折线图 SVG
- Sparkline
- Metric Card
- Progress Bar
- Dashboard 报告拼板
- ChartSummary 数据摘要
- 与 JunJunTnT/moonchart 的关系说明
- CLI SVG 演示
- CI 与协作模板
- README、路线图和更新日志

## 与已有项目的差异证据

- `JunJunTnT/moonchart` 是完整 SVG 图表库，公开 README 覆盖 bar、line、scatter、box plot、error bars、多系列、样式控制、WASM 和性能对比。
- MoonChartKit 当前聚焦轻量报告组件：Metric Card、Sparkline、Progress Bar、Dashboard、ChartSummary 和安全 SVG 嵌入。
- MoonChartKit 的目标使用场景是 README/Markdown、CI 报告、课程材料、Issue/PR 描述和小型 dashboard，而不是替代完整科学统计绘图库。

## 后续工单建议

1. 增加 SVG 快照测试工具
2. 增加 Markdown/HTML 嵌入示例
3. 增加报告布局模板
4. 增加主题 token 和紧凑模式

## 合并请求建议

- `test/svg-snapshot`
- `docs/embed-report`
- `feat/report-layout`
- `feat/theme-token`
