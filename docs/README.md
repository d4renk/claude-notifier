# Claude Notifier 文档中心

## 快速导航

### 新手入门
- **[快速开始](QUICK_START.md)** - 5 分钟快速配置指南 ⭐ 推荐首选

### MCP Notify Hook
- **[使用指南](MCP_NOTIFY_HOOK.md)** - 完整的 MCP Notify Hook 使用文档
  - 安装配置
  - 路由规则详解
  - 支持的渠道
  - 故障排查
  - 常见问题

### 平台专属
- **[macOS 版本](../claude-notifier-macos/README.md)** - Swift 实现的 macOS 原生通知
- **[Windows 版本](../claude-notifier-windows/README.md)** - Rust 实现的 Windows 通知（开发中）

## 文档结构

```
docs/
├── README.md              # 本文档（文档导航）
├── QUICK_START.md         # 快速入门指南
├── MCP_NOTIFY_HOOK.md     # MCP Hook 完整文档
└── (未来计划)
    ├── ADVANCED.md        # 高级配置指南
    ├── API.md             # API 文档
    └── TROUBLESHOOTING.md # 故障排查详解
```

## 推荐阅读路径

### 路径 1：快速上手（新手）
1. [快速开始](QUICK_START.md) - 了解基本概念和快速配置
2. [MCP Notify Hook](MCP_NOTIFY_HOOK.md) - 深入了解路由规则
3. 根据平台选择 [macOS](../claude-notifier-macos/README.md) 或 [Windows](../claude-notifier-windows/README.md)

### 路径 2：深度定制（进阶）
1. [MCP Notify Hook](MCP_NOTIFY_HOOK.md) - 完整功能清单
2. 查看 [config.sample.sh](../config.sample.sh) - 所有支持的环境变量
3. 查看 [scripts/mcp-notify.js](../scripts/mcp-notify.js) - 了解源码实现

### 路径 3：企业部署
1. [MCP Notify Hook](MCP_NOTIFY_HOOK.md#支持的渠道) - 企业渠道配置（钉钉/飞书/企微）
2. [config.sample.sh](../config.sample.sh) - 企业渠道环境变量说明
3. 配置路由规则实现分级推送

## 主要特性

### 🔔 智能通知路由
根据事件类型和级别自动选择推送渠道：
- 成功 → ntfy, bark（轻量推送）
- 错误 → telegram, dingtalk, feishu, ntfy（全渠道告警）
- 需关注 → telegram, bark, dingtalk, feishu（重要通知）

### 🎯 多场景支持
- **个人开发者**：ntfy / Bark 快速配置
- **团队协作**：钉钉 / 飞书 / 企业微信集成
- **跨平台**：同时推送到手机 + 电脑

### ⚡ 高性能
- 多渠道并行推送，互不阻塞
- 自动过滤未配置渠道
- 消息智能截断，避免超长

## 核心概念

### Hook 事件类型
- `Stop`: 主任务完成
- `SubagentStop`: 子任务完成
- `Notification`: 需要用户确认
- `PreToolUse`: 工具执行前
- `PostToolUse`: 工具执行后
- `PreCompact`: 上下文压缩前

### 路由优先级
```
事件级路由 > 级别级路由 > 默认路由 > 内置默认
```

### 级别分类
- `success`: 任务成功完成
- `error`: 执行失败或错误
- `attention`: 需要用户关注
- `warn`: 警告信息
- `info`: 一般信息

## 示例配置

### 最小配置（仅 ntfy）
```bash
export NTFY_TOPIC="your-topic"
```

### 推荐配置（iOS + 跨平台）
```bash
export BARK_PUSH="your-device-key"
export NTFY_TOPIC="your-topic"
```

### 企业配置（全渠道）
```bash
export BARK_PUSH="device-key"
export TG_BOT_TOKEN="bot-token"
export TG_USER_ID="chat-id"
export DD_BOT_TOKEN="dd-token"
export DD_BOT_SECRET="dd-secret"
export FSKEY="fs-webhook-key"
```

## 获取帮助

- 📖 查阅文档：优先查看本文档中心
- 🐛 问题反馈：[GitHub Issues](https://github.com/zengwenliang416/claude-notifier/issues)
- 💬 讨论交流：[GitHub Discussions](https://github.com/zengwenliang416/claude-notifier/discussions)
- ⭐ Star 项目：支持项目发展

## 贡献文档

欢迎改进文档！提交 PR 时请：
1. 保持格式一致
2. 添加清晰的示例
3. 更新相关索引
4. 测试代码块的准确性

## 许可证

本项目文档采用 [MIT License](../LICENSE)
