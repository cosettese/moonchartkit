# MoonChartKit

MoonChartKit 是面向 MoonBit 的无障碍 SVG 报告工件与文档可视化基础库。它服务于
README、CI 报告、Issue、PR、静态文档和小型状态面板，不试图替代完整统计绘图库。

## 核心价值

- **多表示交付**：一次生成 SVG、替代文本和 Markdown 数据表。
- **无障碍语义**：SVG 包含 `<title>`、`<desc>`、`role="img"` 和 ARIA 关联。
- **结构化审计**：自动检查可访问名称、描述、ARIA 与脚本风险。
- **安全嵌入**：标题、描述、标签和主题文本统一转义。
- **后端中立**：输出纯字符串，不依赖浏览器、DOM、Canvas 或文件系统。

## 无障碍报告工件

```mbt nocheck
///|
test {
  let artifact = render_accessible_report(
    "Build Health",
    "CI status by target",
    [DataPoint::new("Native", 12), DataPoint::new("Wasm", 18)],
    [10, 12, 15, 18],
  )

  assert_true(artifact.audit.passed())
  assert_true(artifact.svg.contains("aria-labelledby="))
  assert_true(artifact.markdown.contains("| Native |"))
}
```

`ReportArtifact` 包含：

- `svg`：可直接嵌入 HTML 或文档的无障碍图形；
- `markdown`：对屏幕阅读器、纯文本环境和代码评审友好的数据表；
- `alt_text`：紧凑的自然语言摘要；
- `summary`：结构化统计；
- `audit`：可自动纳入 CI 的质量检查。

## 其他组件

- 柱状图、折线图和 sparkline
- Metric Card、Progress Bar
- 组合 Dashboard
- Atelier 和 Midnight 主题
- XML 转义与图表摘要 JSON

## 运行与验收

```bash
moon check --target all
moon test --target wasm
moon run cmd/main
moon run cmd/bench
```

详见 [验收证据](docs/ACCEPTANCE.md)、
[相关工作](docs/RELATED_WORK.md) 和 [路线图](ROADMAP.md)。
