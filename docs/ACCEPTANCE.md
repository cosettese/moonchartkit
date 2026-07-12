# 验收证据

## 工具链与 CI

CI 在 Native、JavaScript、Wasm 与 Wasm-GC 四个目标上分别执行：

```bash
moon check --target <target>
moon fmt --check
moon test --target <target>
moon info
git diff --exit-code -- '*.mbti'
```

当前支持的 Moon CLI 不接受 `moon fmt --deny-warn` 或
`moon info --deny-warn`；这两个参数会在验证前直接报错。项目因此使用 CLI
支持的、无副作用的等价门禁，并在工作流中明确固定，避免验收脚本与工具链版本脱节。

## 正确性与安全

- SVG 包含 `<title>`、`<desc>`、`role="img"` 和 `aria-labelledby`。
- Markdown 表格提供非图形数据后备。
- 标题、描述和数据标签的 XML/Markdown 注入均有测试。
- 审计器覆盖缺失语义与 `<script>`、`javascript:` 风险。
- 空数据报告仍能输出有效工件。

## 批量工件基准

运行 `moon run cmd/bench` 会生成 100 份包含 20 个数据点的报告，并统计：

- 审计通过数量；
- SVG 总字符数；
- Markdown 总字符数；
- 替代文本总字符数。

每份报告都必须通过 `SvgAudit`，并同时具备图形和非图形表示。

当前确定性输出：

| 报告数 | 审计通过 | SVG 字符 | Markdown 字符 | 替代文本字符 |
| ---: | ---: | ---: | ---: | ---: |
| 100 | 100 | 439929 | 49123 | 9261 |

## 可移植性

GitHub Actions 在 Native、JavaScript、Wasm 和 Wasm-GC 分别执行检查与测试。
