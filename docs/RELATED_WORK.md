# 相关工作与项目边界

检索日期：2026-07-06。

- [`JunJunTnT/moonchart`](https://github.com/JunJunTnT/moonchart) 是完整 SVG
  统计图表库，覆盖柱状图、折线图、散点图、箱线图、误差线和多系列绘制。
- MoonChartKit 不复制科研绘图类型，而位于“报告交付层”：把摘要数据转换为可访问
  SVG、Markdown 表格、替代文本和可自动审计的报告工件。

两者可以组合使用：`moonchart` 负责复杂统计图形，MoonChartKit 负责 CI、README、
Issue/PR 和静态文档中的报告包装、后备表示与质量门禁。

当前社区检索没有发现同时生成无障碍 SVG、Markdown 数据表、替代文本和结构化审计
结果的 MoonBit 报告组件包。
